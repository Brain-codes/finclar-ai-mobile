import 'dart:async';
import 'group_chat_socket_service.dart';
import 'logger_service.dart';

/// A socket event tagged with the group it came from.
class GroupChatHubEvent {
  final String groupId;
  final GroupChatSocketEvent event;
  const GroupChatHubEvent({required this.groupId, required this.event});
}

/// Owns **one** [GroupChatSocketService] per group for the whole app session —
/// not just the group whose chat screen happens to be open. This lets incoming
/// messages be observed (for in-app notifications) even while the user is on a
/// different screen.
///
/// Single-owner rule: the backend's connection manager keys a socket by
/// `(group_id, user_id)`, so a *second* simultaneous connection for the same
/// group from this device would silently replace the first in the server's
/// broadcast map — the first socket would stop receiving events without ever
/// erroring. To avoid that, nothing else in the app should open a
/// `GroupChatSocketService` directly; always go through this hub.
class GroupChatHubService {
  final Future<String?> Function() _tokenProvider;

  final Map<String, GroupChatSocketService> _sockets = {};
  final Map<String, StreamSubscription> _subs = {};
  final Map<String, Timer> _reconnectTimers = {};
  final Map<String, int> _reconnectAttempts = {};
  final Set<String> _wanted = {};
  final _events = StreamController<GroupChatHubEvent>.broadcast();
  bool _disposed = false;

  static const _maxReconnectDelay = 30; // seconds

  GroupChatHubService({required Future<String?> Function() tokenProvider})
      : _tokenProvider = tokenProvider;

  Stream<GroupChatHubEvent> get events => _events.stream;

  bool isConnected(String groupId) => _sockets[groupId]?.isConnected ?? false;

  /// Registers persistent interest in [groupId]'s chat and opens the socket if
  /// not already connected. Idempotent — safe to call repeatedly (e.g. once per
  /// group on every `groupsProvider` refresh, and again when its chat screen
  /// opens).
  Future<void> connectTo(String groupId) async {
    _wanted.add(groupId);
    if (_disposed || _sockets.containsKey(groupId)) return;
    await _open(groupId);
  }

  void sendText(String groupId, String content) {
    _sockets[groupId]?.sendText(content);
  }

  /// Drops interest in [groupId] (e.g. the user left/deleted the group) and
  /// closes its socket.
  Future<void> disconnectFrom(String groupId) async {
    _wanted.remove(groupId);
    _reconnectTimers.remove(groupId)?.cancel();
    _reconnectAttempts.remove(groupId);
    await _subs.remove(groupId)?.cancel();
    await _sockets.remove(groupId)?.dispose();
  }

  Future<void> disposeAll() async {
    _disposed = true;
    for (final timer in _reconnectTimers.values) {
      timer.cancel();
    }
    _reconnectTimers.clear();
    _reconnectAttempts.clear();
    for (final groupId in _sockets.keys.toList()) {
      await _subs.remove(groupId)?.cancel();
      await _sockets.remove(groupId)?.dispose();
    }
    _wanted.clear();
    if (!_events.isClosed) await _events.close();
  }

  Future<void> _open(String groupId) async {
    if (_disposed || !_wanted.contains(groupId)) return;
    final token = await _tokenProvider();
    if (token == null || _disposed || !_wanted.contains(groupId)) return;

    final socket = GroupChatSocketService(groupId: groupId, token: token);
    _sockets[groupId] = socket;
    _subs[groupId] = socket.events.listen(
      (event) {
        if (event is GroupChatConnected) _reconnectAttempts[groupId] = 0;
        if (!_events.isClosed) {
          _events.add(GroupChatHubEvent(groupId: groupId, event: event));
        }
      },
      onDone: () => _scheduleReconnect(groupId),
      onError: (_) => _scheduleReconnect(groupId),
      cancelOnError: false,
    );

    try {
      await socket.connect();
      _reconnectAttempts[groupId] = 0;
    } catch (e) {
      Log.w('Hub: WS connect failed for $groupId, will retry', error: e);
      _scheduleReconnect(groupId);
    }
  }

  /// Exponential backoff (3s → 6s → 12s … capped at 30s) per group.
  void _scheduleReconnect(String groupId) {
    if (_disposed || !_wanted.contains(groupId)) return;
    _reconnectTimers[groupId]?.cancel();
    final attempts = _reconnectAttempts[groupId] ?? 0;
    final delay = (3 * (1 << attempts)).clamp(3, _maxReconnectDelay);
    _reconnectAttempts[groupId] = attempts + 1;
    _reconnectTimers[groupId] = Timer(Duration(seconds: delay), () {
      _sockets.remove(groupId);
      if (!_disposed && _wanted.contains(groupId)) unawaited(_open(groupId));
    });
  }
}
