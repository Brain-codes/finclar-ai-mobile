import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    if (email.trim().isEmpty) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // TODO: call ApiClient to send reset OTP to email
      await Future.delayed(const Duration(milliseconds: 1000));
      // Simulate unknown email for dev
      if (!email.contains('@')) {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorText: 'This email does not exist',
        );
        return false;
      }
      state = state.copyWith(isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorText: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }
}

final forgotPasscodeProvider =
    NotifierProvider<ForgotPasscodeNotifier, ForgotPasscodeState>(
  ForgotPasscodeNotifier.new,
);
