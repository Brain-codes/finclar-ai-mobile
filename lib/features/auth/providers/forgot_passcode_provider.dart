import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/logger_service.dart';
import 'auth_repository_provider.dart';

class ForgotPasscodeState {
  final bool isLoading;
  final bool hasError;
  final String? errorText;

  const ForgotPasscodeState({
    this.isLoading = false,
    this.hasError = false,
    this.errorText,
  });

  ForgotPasscodeState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorText,
    bool clearError = false,
  }) {
    return ForgotPasscodeState(
      isLoading: isLoading ?? this.isLoading,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorText: clearError ? null : (errorText ?? this.errorText),
    );
  }
}

class ForgotPasscodeNotifier extends Notifier<ForgotPasscodeState> {
  @override
  ForgotPasscodeState build() => const ForgotPasscodeState();

  void clearError() => state = state.copyWith(clearError: true);

  Future<bool> sendCode(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(hasError: true, errorText: 'Email address is required');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).forgotPasscode(email: trimmed);
      state = state.copyWith(isLoading: false);
      return true;
    } on AppException catch (e) {
      Log.e('Forgot passcode failed', error: e);
      state = state.copyWith(isLoading: false, hasError: true, errorText: e.message);
      return false;
    }
  }
}

final forgotPasscodeProvider =
    NotifierProvider<ForgotPasscodeNotifier, ForgotPasscodeState>(
  ForgotPasscodeNotifier.new,
);
