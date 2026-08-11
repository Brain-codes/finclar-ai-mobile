import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../../../core/services/logger_service.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

const int _pageSize = 20;

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  NotificationsNotifier.new,
);

/// Whether the server reports another page after the one currently loaded.
final notificationsHasMoreProvider = StateProvider<bool>((ref) => false);

/// Drives the inline footer loader during a "load more" fetch.
final notificationsLoadingMoreProvider = StateProvider<bool>((ref) => false);

/// Server-authoritative unread badge. Falls back to counting the loaded page so
/// the badge still reacts instantly to a local mark-read before the refetch lands.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final server = ref.watch(unreadNotificationCountAsyncProvider).valueOrNull;
  if (server != null) return server;
  final list = ref.watch(notificationsProvider).valueOrNull ?? [];
  return list.where((n) => !n.isRead).length;
});

final unreadNotificationCountAsyncProvider =
    AsyncNotifierProvider<UnreadNotificationCountNotifier, int>(
  UnreadNotificationCountNotifier.new,
);

class UnreadNotificationCountNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() =>
      ref.watch(notificationRepositoryProvider).getUnreadCount();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).getUnreadCount(),
    );
  }

  /// Keeps the badge in step with an optimistic mark-read without a round trip.
  void decrementBy(int amount) {
    final current = state.valueOrNull;
    if (current == null || amount <= 0) return;
    state = AsyncData((current - amount).clamp(0, current));
  }

  void clear() => state = const AsyncData(0);
}

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  int _page = 1;

  @override
  Future<List<NotificationModel>> build() async {
    final response = await ref
        .watch(notificationRepositoryProvider)
        .getNotifications(page: 1, pageSize: _pageSize);
    _page = response.page;
    _setHasMore(response.hasNext);
    return response.items;
  }

  // build() runs while the container is still mounting the provider, so the
  // flag has to be written after the current frame's state update settles.
  void _setHasMore(bool value) {
    Future.microtask(
      () => ref.read(notificationsHasMoreProvider.notifier).state = value,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(notificationRepositoryProvider)
          .getNotifications(page: 1, pageSize: _pageSize);
      _page = response.page;
      _setHasMore(response.hasNext);
      return response.items;
    });
    ref.read(unreadNotificationCountAsyncProvider.notifier).refresh();
  }

  Future<void> loadMore() async {
    if (ref.read(notificationsLoadingMoreProvider) ||
        !ref.read(notificationsHasMoreProvider)) {
      return;
    }
    final current = state.valueOrNull;
    if (current == null) return;

    ref.read(notificationsLoadingMoreProvider.notifier).state = true;
    try {
      final response = await ref
          .read(notificationRepositoryProvider)
          .getNotifications(page: _page + 1, pageSize: _pageSize);
      _page = response.page;
      ref.read(notificationsHasMoreProvider.notifier).state = response.hasNext;
      state = AsyncData([...current, ...response.items]);
    } catch (e, st) {
      // A failed page must not blank the rows already on screen.
      Log.e('Failed to load more notifications', error: e, stackTrace: st);
    } finally {
      ref.read(notificationsLoadingMoreProvider.notifier).state = false;
    }
  }

  Future<void> markRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final target = current.where((n) => n.id == id).firstOrNull;
    if (target == null || target.isRead) return;

    state = AsyncData([
      for (final n in current)
        n.id == id ? n.copyWith(isRead: true, readAt: DateTime.now()) : n,
    ]);
    ref.read(unreadNotificationCountAsyncProvider.notifier).decrementBy(1);

    try {
      await ref.read(notificationRepositoryProvider).markRead(id);
    } catch (e, st) {
      Log.e('Failed to mark notification read', error: e, stackTrace: st);
      state = AsyncData(current);
      ref.read(unreadNotificationCountAsyncProvider.notifier).refresh();
    }
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final now = DateTime.now();
    state = AsyncData([
      for (final n in current)
        n.isRead ? n : n.copyWith(isRead: true, readAt: now),
    ]);
    ref.read(unreadNotificationCountAsyncProvider.notifier).clear();

    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
    } catch (e, st) {
      Log.e('Failed to mark all notifications read', error: e, stackTrace: st);
      state = AsyncData(current);
      ref.read(unreadNotificationCountAsyncProvider.notifier).refresh();
    }
  }
}
