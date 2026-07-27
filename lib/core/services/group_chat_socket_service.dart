import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../api/api_endpoints.dart';
import 'logger_service.dart';
import '../../features/group/data/models/group_message_model.dart';

/// Events emitted by the group chat socket.
sealed class GroupChatSocketEvent {
  const GroupChatSocketEvent();
}

class GroupChatConnected extends GroupChatSocketEvent {
  const GroupChatConnected();
}

class GroupChatIncomingMessage extends GroupChatSocketEvent {
  final GroupMessageModel message;
  const GroupChatIncomingMessage(this.message);
}

class GroupChatSocketError extends GroupChatSocketEvent {
  final String message;
  const GroupChatSocketError(this.message);
}

/// Thin wrapper around the group chat WebSocket. UI/providers talk to this,
/// never to `web_socket_channel` directly (same isolation as BankConnectService).
///
/// Wire protocol (from the FastAPI/Starlette backend):
/// - connect: `wss://.../groups/{id}/ws?token=<access_token>`
/// - server → `{"type":"connected", ...}` / `{"type":"message","data":{...}}`
///   / `{"type":"error","message":"..."}`
/// - client → `{"content":"..."}` (text only; attachments stay on REST)
class GroupChatSocketService {
  final String groupId;
  final String token;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  final _events = StreamController<GroupChatSocketEvent>.broadcast();
  bool _connected = false;
  bool _disposed = false;

  GroupChatSocketService({required this.groupId, required this.token});

  Stream<GroupChatSocketEvent> get events => _events.stream;
  bool get isConnected => _connected;

  /// Opens the socket. Completes once the handshake succeeds; throws on failure.
  Future<void> connect() async {
    if (_disposed) return;
    final uri = Uri.parse(ApiEndpoints.groupChatSocket(groupId, token));
    Log.d('WS connect groups/$groupId/ws');
    final channel = WebSocketChannel.connect(uri);
    await channel.ready; // throws if the handshake fails (e.g. 4001/4003)
    _channel = channel;
    _connected = true;
    _sub = channel.stream.listen(
      _onData,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: false,
    );
  }

  void sendText(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty || !_connected || _channel == null) return;
    _channel!.sink.add(jsonEncode({'content': trimmed}));
  }

  void _onData(dynamic raw) {
    try {
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      switch (map['type']) {
        case 'connected':
          Log.d('WS connected groups/$groupId');
          _events.add(const GroupChatConnected());
        case 'message':
          final data = map['data'];
          if (data is Map<String, dynamic>) {
            final message = GroupMessageModel.fromJson(data);
            Log.d(
              'WS message groups/$groupId ← ${message.senderUsername ?? message.senderId}: '
              '${message.content ?? '[${message.messageType.name}]'}',
            );
            _events.add(GroupChatIncomingMessage(message));
          }
        case 'error':
          final message = (map['message'] ?? 'Chat error').toString();
          Log.w('WS error groups/$groupId: $message');
          _events.add(GroupChatSocketError(message));
      }
    } catch (e, st) {
      Log.e('WS parse failed', error: e, stackTrace: st);
    }
  }

  void _onError(Object error, StackTrace st) {
    Log.e('WS error groups/$groupId', error: error, stackTrace: st);
    _connected = false;
    if (!_events.isClosed) _events.add(GroupChatSocketError(error.toString()));
  }

  void _onDone() {
    _connected = false;
    Log.d('WS closed groups/$groupId (code ${_channel?.closeCode})');
    if (!_events.isClosed) _events.close();
  }

  Future<void> dispose() async {
    _disposed = true;
    _connected = false;
    await _sub?.cancel();
    await _channel?.sink.close();
    if (!_events.isClosed) await _events.close();
  }
}
