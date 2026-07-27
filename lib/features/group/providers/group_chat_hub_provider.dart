import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
import '../../../app/routes/app_router.dart';
import '../../../app/routes/route_names.dart';
import '../../../core/services/group_chat_hub_service.dart';
import '../../../core/services/group_chat_socket_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/icons/app_icons.dart';
import '../../auth/providers/user_profile_provider.dart';
import '../data/models/group_model.dart';
import 'group_providers.dart';

/// The id of the group chat currently on screen, if any. Set/cleared by
/// [GroupMessagesNotifier] as its chat screen mounts/unmounts. The
/// notifications controller uses this to skip a banner for the chat you're
/// already looking at.
final activeGroupChatIdProvider = StateProvider<String?>((ref) => null);

/// App-session-scoped connection manager — the single owner of every group
/// chat socket. Never construct [GroupChatSocketService] directly elsewhere.
final groupChatHubProvider = Provider<GroupChatHubService>((ref) {
  final hub = GroupChatHubService(tokenProvider: StorageService.getAccessToken);
  ref.onDispose(() => hub.disposeAll());
  return hub;
});

/// Keeps a socket open (via the hub) for every group the user belongs to, and
/// shows a tap-to-open banner for messages that arrive while that group's
/// chat isn't the active screen. Bootstrapped once by `AppShell` after login;
/// stays alive for the whole session (see `session_reset.dart` for teardown
/// on logout).
final groupChatNotificationsProvider = Provider<GroupChatNotificationsController>((ref) {
  final controller = GroupChatNotificationsController(ref);
  ref.onDispose(controller.dispose);
  controller.start();
  return controller;
});

class GroupChatNotificationsController {
  final Ref _ref;
  StreamSubscription<GroupChatHubEvent>? _sub;
  ProviderSubscription<AsyncValue<List<GroupModel>>>? _groupsSub;

  GroupChatNotificationsController(this._ref);

  void start() {
    final hub = _ref.read(groupChatHubProvider);
    _sub = hub.events.listen(_onHubEvent);

    // Connect to every group as soon as (and whenever) the list loads/changes.
    _groupsSub = _ref.listen<AsyncValue<List<GroupModel>>>(
      groupsProvider,
      (previous, next) {
        for (final group in next.valueOrNull ?? const <GroupModel>[]) {
          unawaited(hub.connectTo(group.id));
        }
      },
      fireImmediately: true,
    );
  }

  void _onHubEvent(GroupChatHubEvent hubEvent) {
    final event = hubEvent.event;
    if (event is! GroupChatIncomingMessage) return;
    final message = event.message;

    final currentUserId = _ref.read(userProfileProvider).valueOrNull?.id;
    if (currentUserId != null && message.senderId == currentUserId) return;

    if (_ref.read(activeGroupChatIdProvider) == hubEvent.groupId) return;

    final group = _findGroup(hubEvent.groupId);
    _showBanner(
      groupId: hubEvent.groupId,
      groupName: group?.name ?? 'Group chat',
      senderName: message.senderUsername ?? 'Someone',
      body: message.isImage ? 'Sent an attachment' : (message.content ?? ''),
    );
  }

  GroupModel? _findGroup(String groupId) {
    final groups = _ref.read(groupsProvider).valueOrNull ?? const [];
    for (final g in groups) {
      if (g.id == groupId) return g;
    }
    return null;
  }

  void _showBanner({
    required String groupId,
    required String groupName,
    required String senderName,
    required String body,
  }) {
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(
        groupName,
        style: AppTypography.labelLarge.copyWith(color: AppColors.white),
      ),
      description: Text(
        '$senderName: $body',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.white.withValues(alpha: 0.75),
        ),
      ),
      icon: const Icon(AppIcons.message, color: AppColors.primary, size: 20),
      primaryColor: AppColors.primary,
      backgroundColor: AppColors.textPrimary,
      foregroundColor: AppColors.white,
      borderRadius: AppRadius.radiusCard,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.topCenter,
      dragToClose: true,
      applyBlurEffect: true,
      animationBuilder: (context, animation, alignment, child) =>
          FadeTransition(opacity: animation, child: child),
      callbacks: ToastificationCallbacks(
        onTap: (_) => unawaited(_navigateToGroup(groupId)),
      ),
    );
  }

  Future<void> _navigateToGroup(String groupId) async {
    var group = _findGroup(groupId);
    if (group == null) {
      try {
        group = await _ref.read(groupRepositoryProvider).getGroup(groupId);
      } catch (e) {
        Log.w('Could not open group $groupId from notification', error: e);
        return;
      }
    }
    appRouter.push(RouteNames.groupChat, extra: group);
  }

  void dispose() {
    _sub?.cancel();
    _groupsSub?.close();
  }
}
