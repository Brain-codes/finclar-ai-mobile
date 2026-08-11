import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/logger_service.dart';
import '../models/clara_message_model.dart';

class ClaraRepository {
  final ApiClient _api;

  ClaraRepository(this._api);

  /// Full chat history (oldest → newest). Each backend message expands into a
  /// text bubble plus, for assistant messages with a summary payload, an
  /// insight card — see [ClaraMessageModel.listFromBackend].
  Future<List<ClaraMessageModel>> getHistory() async {
    Log.api('GET', ApiEndpoints.claraMessages);
    // Track the most recent user message as we walk the history in order so
    // an assistant reply's insight card can tell what was actually asked.
    String? lastUserText;
    final items = await _api.getAllPaginated<List<ClaraMessageModel>>(
      ApiEndpoints.claraMessages,
      fromItem: (json) {
        final parsed = ClaraMessageModel.listFromBackend(
          json,
          precedingUserText: lastUserText,
        );
        if (json["role"] == "user") {
          lastUserText = (json["content"] as String?)?.trim();
        }
        return parsed;
      },
    );
    return items.expand((e) => e).toList();
  }

  /// Sends a message and returns the assistant's reply as 1–2 UI messages
  /// (text bubble + optional insight card). The backend persists both the
  /// user message and the reply, so we only append the reply locally.
  Future<List<ClaraMessageModel>> sendMessage(String message) async {
    Log.api('POST', ApiEndpoints.claraChat, body: {'message': message});
    final response = await _api.post<List<ClaraMessageModel>>(
      ApiEndpoints.claraChat,
      body: {'message': message},
      fromData: (data) {
        final map = data as Map<String, dynamic>;
        final createdAt = DateTime.now();
        final reply = (map['reply'] as String?)?.trim() ?? '';
        final baseId = '${createdAt.microsecondsSinceEpoch}_assistant';
        final result = <ClaraMessageModel>[];
        if (reply.isNotEmpty) {
          result.add(ClaraMessageModel(
            id: '${baseId}_t',
            role: ClaraRole.assistant,
            text: reply,
            sentAt: createdAt,
          ));
        }
        final summary = map['data'];
        if (summary is Map<String, dynamic>) {
          final insight = ClaraInsightModel.fromSummary(
            summary,
            questionText: message,
            replyText: reply,
          );
          if (insight != null) {
            result.add(ClaraMessageModel(
              id: '${baseId}_i',
              role: ClaraRole.assistant,
              type: ClaraMessageType.insight,
              insight: insight,
              sentAt: createdAt,
            ));
          }
        }
        return result;
      },
    );
    return response.data ?? [];
  }
}
