import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/logger_service.dart';
import '../data/models/clara_message_model.dart';
import '../data/repositories/clara_repository.dart';
import 'clara_audio_provider.dart';

const _claraToneAsset = 'audio/clara_tone.MP3';

final claraRepositoryProvider = Provider<ClaraRepository>((ref) {
  return ClaraRepository(ref.watch(apiClientProvider));
});

class ClaraChatState {
  final List<ClaraMessageModel> messages;
  final bool isTyping;
  final bool isLoadingHistory;
  final bool hasError;

  /// Id of the one assistant text bubble that should play the typewriter reveal
  /// (only ever the just-received reply — never history).
  final String? animateMessageId;

  /// Id of the just-received reply's insight card (if any) — fades/rises in
  /// after the text finishes typing.
  final String? animateInsightId;

  const ClaraChatState({
    this.messages = const [],
    this.isTyping = false,
    this.isLoadingHistory = false,
    this.hasError = false,
    this.animateMessageId,
    this.animateInsightId,
  });

  ClaraChatState copyWith({
    List<ClaraMessageModel>? messages,
    bool? isTyping,
    bool? isLoadingHistory,
    bool? hasError,
    String? animateMessageId,
    String? animateInsightId,
  }) =>
      ClaraChatState(
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
        isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
        hasError: hasError ?? this.hasError,
        animateMessageId: animateMessageId ?? this.animateMessageId,
        animateInsightId: animateInsightId ?? this.animateInsightId,
      );
}

final claraChatProvider =
    NotifierProvider<ClaraChatNotifier, ClaraChatState>(ClaraChatNotifier.new);

/// Conversational Clara chat backed by `POST /clara/chat` (OpenAI tool-calling
/// over the user's expense data) with history from `GET /clara/messages`.
class ClaraChatNotifier extends Notifier<ClaraChatState> {
  ClaraRepository get _repo => ref.read(claraRepositoryProvider);
  int _counter = 0;

  @override
  ClaraChatState build() {
    _loadHistory();
    return const ClaraChatState(isLoadingHistory: true);
  }

  String _localId() =>
      'local_${DateTime.now().microsecondsSinceEpoch}_${_counter++}';

  Future<void> _loadHistory() async {
    try {
      final history = await _repo.getHistory();
      state = state.copyWith(
        messages: history,
        isLoadingHistory: false,
        hasError: false,
      );
    } on AppException catch (e) {
      Log.e('Clara history load failed', error: e);
      state = state.copyWith(isLoadingHistory: false, hasError: true);
    }
  }

  Future<void> retryHistory() async {
    state = state.copyWith(isLoadingHistory: true, hasError: false);
    await _loadHistory();
  }

  /// Sends [text] to Clara and appends the reply. Rethrows [AppException] so the
  /// screen can surface a snackbar; the typing indicator is always cleared.
  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isTyping) return;

    Analytics.claraMessageSent();

    final userMsg = ClaraMessageModel(
      id: _localId(),
      role: ClaraRole.user,
      text: trimmed,
      sentAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    try {
      final reply = await _repo.sendMessage(trimmed);
      // Animate only this reply: the text bubble typewrites, the insight card
      // (if any) fades/rises in afterward.
      String? animateId;
      String? insightId;
      for (final m in reply) {
        if (m.role != ClaraRole.assistant) continue;
        if (m.isInsight) {
          insightId ??= m.id;
        } else {
          animateId ??= m.id;
        }
      }
      state = state.copyWith(
        messages: [...state.messages, ...reply],
        isTyping: false,
        animateMessageId: animateId,
        animateInsightId: insightId,
      );
      if (ref.read(claraAudioEnabledProvider)) {
        AudioService.playOnce(_claraToneAsset);
      }
    } on AppException catch (e) {
      Log.e('Clara send failed', error: e);
      state = state.copyWith(isTyping: false);
      rethrow;
    }
  }

  void clear() => state = const ClaraChatState();
}
