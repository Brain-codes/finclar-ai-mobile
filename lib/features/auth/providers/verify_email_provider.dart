import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyEmailState {
  final bool isLoading;
  final bool hasError;
  final String? errorText;
  final int resendSeconds; // 0 = can resend
  final bool verified;

  const VerifyEmailState({
    this.isLoading = false,
    this.hasError = false,
    this.errorText,
    this.resendSeconds = 45,
    this.verified = false,
  });

  bool get canResend => resendSeconds == 0;

  VerifyEmailState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorText,
    int? resendSeconds,
    bool? verified,
    bool clearError = false,
  }) {
    return VerifyEmailState(
      isLoading: isLoading ?? this.isLoading,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorText: clearError ? null : (errorText ?? this.errorText),
      resendSeconds: resendSeconds ?? this.resendSeconds,
      verified: verified ?? this.verified,
    );
  }
}

class VerifyEmailNotifier extends Notifier<VerifyEmailState> {
  Timer? _resendTimer;

  @override
  VerifyEmailState build() {
    ref.onDispose(() => _resendTimer?.cancel());
    _createTimer();
    return const VerifyEmailState();
  }

  void _createTimer() {
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

  void _startResendTimer() {
    _resendTimer?.cancel();
    state = state.copyWith(resendSeconds: 45);
    _createTimer();
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<bool> verify(String code) async {
    if (code.length < 6) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // TODO: call ApiClient to verify email OTP
      await Future.delayed(const Duration(milliseconds: 1000));
      // Simulate wrong code for non-"123456" codes in dev
      if (code != '123456') {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorText: 'The code you entered is incorrect',
        );
        return false;
      }
      state = state.copyWith(isLoading: false, verified: true);
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

  Future<void> resend() async {
    if (!state.canResend) return;
    // TODO: call ApiClient to resend OTP
    _startResendTimer();
  }
}

final verifyEmailProvider =
    NotifierProvider<VerifyEmailNotifier, VerifyEmailState>(
  VerifyEmailNotifier.new,
);
