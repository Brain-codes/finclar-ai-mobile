import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/notification_model.dart';

// Backend notifications endpoint is not live yet (see docs/API.md). This notifier
// serves mock data so the screen is fully functional; swap the body of `build`
// for an ApiClient call once GET /notifications ships.
final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  NotificationsNotifier.new,
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider).valueOrNull ?? [];
  return list.where((n) => !n.isRead).length;
});

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mock();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mock();
    });
  }

  void markAllRead() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([for (final n in current) n.copyWith(isRead: true)]);
  }

  void markRead(String id) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([
      for (final n in current) n.id == id ? n.copyWith(isRead: true) : n,
    ]);
  }

  List<NotificationModel> _mock() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: 'Budget limit warning',
        body: "You've used 85% of your Food budget this month.",
        type: NotificationType.budget,
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
      NotificationModel(
        id: '2',
        title: 'New transaction',
        body: 'A debit of ₦4,500 was logged from your linked account.',
        type: NotificationType.transaction,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: '3',
        title: 'Clara insight',
        body: 'Your spending on Transport dropped 12% compared to last week.',
        type: NotificationType.insight,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      NotificationModel(
        id: '4',
        title: 'Group activity',
        body: 'Tunde added a new expense to "Lagos Trip".',
        type: NotificationType.group,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
