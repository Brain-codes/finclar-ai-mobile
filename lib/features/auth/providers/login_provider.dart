import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  final bool isLoading;
  final bool hasError;
  final String? errorText;

  const LoginState({
    this.isLoading = false,
    this.hasError = false,
    this.errorText,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorText,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorText: clearError ? null : (errorText ?? this.errorText),
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void clearError() => state = state.copyWith(clearError: true);

  Future<bool> login(String passcode) async {
    if (passcode.length < 6) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // TODO: call ApiClient to authenticate with passcode
      await Future.delayed(const Duration(milliseconds: 1000));
      if (passcode != '123456') {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorText: 'Incorrect passcode. Please try again.',
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

  Future<bool> loginWithBiometrics() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // TODO: call BiometricService.authenticate() then ApiClient
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorText: 'Biometric authentication failed.',
      );
      return false;
    }
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
