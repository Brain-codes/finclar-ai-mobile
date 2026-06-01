import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/auth_state_service.dart';
import '../../../core/services/logger_service.dart';
import 'auth_repository_provider.dart';

class VerifyEmailState {
  final bool isLoading;
  final bool hasError;
  final String? errorText;
  final int resendSeconds;
  final bool verified;
  final bool isResending;
  final String? snackbarError;

  const VerifyEmailState({
    this.isLoading = false,
    this.hasError = false,
    this.errorText,
    this.resendSeconds = 45,
    this.verified = false,
    this.isResending = false,
    this.snackbarError,
  });

  bool get canResend => resendSeconds == 0 && !isResending;

  VerifyEmailState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorText,
    int? resendSeconds,
    bool? verified,
    bool? isResending,
    String? snackbarError,
    bool clearError = false,
    bool clearSnackbarError = false,
  }) {
    return VerifyEmailState(
      isLoading: isLoading ?? this.isLoading,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorText: clearError ? null : (errorText ?? this.errorText),
      resendSeconds: resendSeconds ?? this.resendSeconds,
      verified: verified ?? this.verified,
      isResending: isResending ?? this.isResending,
      snackbarError: clearSnackbarError ? null : (snackbarError ?? this.snackbarError),
    );
  }
}

class VerifyEmailNotifier extends Notifier<VerifyEmailState> {
  Timer? _resendTimer;

  @override
  VerifyEmailState build() {
    ref.onDispose(() => _resendTimer?.cancel());
    _startCountdown(45);
    return const VerifyEmailState(resendSeconds: 45);
  }

  void _startCountdown(int seconds) {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final remaining = state.resendSeconds - 1;
      if (remaining <= 0) {
        t.cancel();
        state = state.copyWith(resendSeconds: 0);
      } else {
        state = state.copyWith(resendSeconds: remaining);
      }
    });
  }

  void _startTimer(int seconds) {
    state = state.copyWith(resendSeconds: seconds);
    _startCountdown(seconds);
  }

  void clearError() => state = state.copyWith(clearError: true);
  void clearSnackbarError() => state = state.copyWith(clearSnackbarError: true);

  Future<bool> verify(String email, String code) async {
    if (code.length < 6) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tokens = await ref.read(authRepositoryProvider).verifyEmail(
            email: email,
            code: code,
          );
      await authStateService.logIn(tokens.accessToken, tokens.refreshToken, isNewUser: true);
      state = state.copyWith(isLoading: false, verified: true);
      return true;
    } on AppException catch (e) {
      Log.e('Verify email failed', error: e);
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorText: e.message,
      );
      return false;
    }
  }

  Future<void> resend(String email) async {
    if (!state.canResend || state.isResending) return;
    state = state.copyWith(isResending: true);
    try {
      await ref.read(authRepositoryProvider).resendOtp(email: email);
      _startTimer(45);
    } on AppException catch (e) {
      Log.e('Resend OTP failed', error: e);
      state = state.copyWith(snackbarError: e.message);
    } finally {
      state = state.copyWith(isResending: false);
    }
  }
}

final verifyEmailProvider =
    NotifierProvider<VerifyEmailNotifier, VerifyEmailState>(
  VerifyEmailNotifier.new,
);
