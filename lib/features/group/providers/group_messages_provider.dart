import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/group_chat_hub_service.dart';
import '../../../core/services/group_chat_socket_service.dart';
import '../../../core/services/logger_service.dart';
import 'group_chat_hub_provider.dart';
import '../data/models/group_message_model.dart';
import 'group_providers.dart';

/// Live chat messages for a group, keyed by group id. Held ascending (oldest
/// first). History is loaded via REST; new messages arrive over the shared
/// [GroupChatHubService] socket (the hub owns the connection — this notifier
/// only observes it, so opening/closing this screen never creates a second
/// socket for the same group).
///
/// The backend broadcasts every text message to all members **including the
/// sender**, so outgoing text is NOT appended optimistically — it lands via
/// the hub event and is deduped by id. Attachments are REST-only; the backend
/// also broadcasts those (as of backend commit `ba27006`), so the local
/// append from the REST response and the broadcast echo are deduped the same
/// way.
class GroupMessagesNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<GroupMessageModel>, String> {
  StreamSubscription<GroupChatHubEvent>? _sub;

  @override
  Future<List<GroupMessageModel>> build(String groupId) async {
    ref.onDispose(_teardown);

    // Mark this chat as "on screen" so the notification banner skips it.
    // Deferred to a microtask: this chat screen's top bar and message list
    // both watch providers that build in the same Flutter frame, so mutating
    // `activeGroupChatIdProvider` synchronously here — while THIS provider's
    // own build is still in flight — hits Riverpod's "cannot modify a
    // provider while it's being initialized" guard and throws, aborting
    // build() before it ever reaches the messages fetch below (symptom: the
    // GET /messages request never fires on first open, only after a manual
    // retry, which runs outside the build phase).
    Future.microtask(() {
      ref.read(activeGroupChatIdProvider.notifier).state = groupId;
    });
    ref.onDispose(() {
      if (ref.read(activeGroupChatIdProvider) == groupId) {
        ref.read(activeGroupChatIdProvider.notifier).state = null;
      }
    });

    final hub = ref.read(groupChatHubProvider);
    unawaited(hub.connectTo(groupId));
    _sub = hub.events
        .where((e) => e.groupId == groupId)
        .listen(_onHubEvent);

    final history = await _fetchHistoryWithRetry(groupId);
    return _sorted(history);
  }

  /// The very first fetch for a freshly-opened chat can race with the socket
  /// handshake / a just-refreshed token settling, causing a spurious one-off
  /// failure that a manual retry then succeeds at. Absorb that here instead of
  /// showing an error the user has to dismiss by hand.
  Future<List<GroupMessageModel>> _fetchHistoryWithRetry(
    String groupId,
  ) async {
    try {
      return await ref.read(groupRepositoryProvider).getMessages(groupId);
    } catch (e, st) {
      Log.w(
        'Initial message load failed for $groupId, retrying once',
        error: e,
        stackTrace: st,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        return await ref.read(groupRepositoryProvider).getMessages(groupId);
      } catch (e, st) {
        Log.e(
          'Message load retry also failed for $groupId',
          error: e,
          stackTrace: st,
        );
        rethrow;
      }
    }
  }

  void _onHubEvent(GroupChatHubEvent hubEvent) {
    if (hubEvent.event is GroupChatIncomingMessage) {
      _append((hubEvent.event as GroupChatIncomingMessage).message);
    }
  }

  void _teardown() {
    _sub?.cancel();
  }

  // ─── Sending ───────────────────────────────────────────────────────────────

  Future<void> sendText(String content) async {
    final hub = ref.read(groupChatHubProvider);
    if (hub.isConnected(arg)) {
      // Broadcast echoes it back to us → appended via _onHubEvent (deduped).
      hub.sendText(arg, content);
      return;
    }
    // Socket down: fall back to REST so the message is still delivered.
    final sent =
        await ref.read(groupRepositoryProvider).sendMessage(arg, content);
    _append(sent);
  }

  Future<void> sendAttachment(File file, {double? recordAmount}) async {
    final sent = await ref.read(groupRepositoryProvider).sendAttachment(
          arg,
          file: file,
          recordAmount: recordAmount,
        );
    // Appended locally for instant feedback; the backend also broadcasts this
    // same message back to us over the socket, deduped below by id.
    _append(sent);
    if (recordAmount != null) {
      ref.invalidate(groupDetailProvider(arg));
      ref.invalidate(groupSavingsProvider(arg));
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final messages =
          await ref.read(groupRepositoryProvider).getMessages(arg);
      return _sorted(messages);
    });
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  void _append(GroupMessageModel message) {
    final current = state.valueOrNull ?? [];
    if (current.any((m) => m.id == message.id)) return; // dedupe echoes
    state = AsyncData(_sorted([...current, message]));
  }

  List<GroupMessageModel> _sorted(List<GroupMessageModel> list) {
    final copy = [...list]..sort((a, b) => a.sentAtDate.compareTo(b.sentAtDate));
    return copy;
  }
}

final groupMessagesProvider = AsyncNotifierProvider.autoDispose
    .family<GroupMessagesNotifier, List<GroupMessageModel>, String>(
  GroupMessagesNotifier.new,
);
