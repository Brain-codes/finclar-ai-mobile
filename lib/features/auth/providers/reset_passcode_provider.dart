import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/storage_service.dart';
import 'auth_repository_provider.dart';

enum ResetPasscodePhase { otp, create, confirm }

class ResetPasscodeState {
  final ResetPasscodePhase phase;
  final String otp;
  final String passcode;
  final bool hasError;
  final String? errorText;
  final bool isLoading;
  final bool isSendingOtp;
  final String? snackbarError;

  const ResetPasscodeState({
    this.phase = ResetPasscodePhase.otp,
    this.otp = '',
    this.passcode = '',
    this.hasError = false,
    this.errorText,
    this.isLoading = false,
    this.isSendingOtp = false,
    this.snackbarError,
  });

  ResetPasscodeState copyWith({
    ResetPasscodePhase? phase,
    String? otp,
    String? passcode,
    bool? hasError,
    String? errorText,
    bool? isLoading,
    bool? isSendingOtp,
    String? snackbarError,
    bool clearError = false,
    bool clearSnackbarError = false,
  }) {
    return ResetPasscodeState(
      phase: phase ?? this.phase,
      otp: otp ?? this.otp,
      passcode: passcode ?? this.passcode,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorText: clearError ? null : (errorText ?? this.errorText),
      isLoading: isLoading ?? this.isLoading,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      snackbarError: clearSnackbarError ? null : (snackbarError ?? this.snackbarError),
    );
  }
}

class ResetPasscodeNotifier extends AutoDisposeNotifier<ResetPasscodeState> {
  @override
  ResetPasscodeState build() => const ResetPasscodeState();

  void clearError() => state = state.copyWith(clearError: true);
  void clearSnackbarError() => state = state.copyWith(clearSnackbarError: true);

  Future<void> sendOtp(String email) async {
    state = state.copyWith(isSendingOtp: true);
    try {
      await ref.read(authRepositoryProvider).forgotPasscode(email: email);
      state = state.copyWith(isSendingOtp: false);
    } on AppException catch (e) {
      Log.e('Forgot passcode OTP failed', error: e);
      state = state.copyWith(isSendingOtp: false, snackbarError: e.message);
    }
  }

  void onOtpEntered(String code) {
    state = state.copyWith(otp: code, phase: ResetPasscodePhase.create, clearError: true);
  }

  void onPasscodeCreated(String passcode) {
    state = state.copyWith(passcode: passcode, phase: ResetPasscodePhase.confirm, clearError: true);
  }

  Future<bool> onPasscodeConfirmed(String email, String confirmation) async {
    if (confirmation != state.passcode) {
      state = state.copyWith(hasError: true, errorText: AppStrings.passcodeDoNotMatch);
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tokens = await ref.read(authRepositoryProvider).resetPasscode(
            email: email,
            code: state.otp,
            newPasscode: state.passcode,
          );
      // Save fresh tokens so logoutAll (called from the sheet) is authenticated.
      await StorageService.saveTokens(
        access: tokens.accessToken,
        refresh: tokens.refreshToken,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on AppException catch (e) {
      Log.e('Reset passcode failed', error: e);
      state = state.copyWith(isLoading: false, snackbarError: e.message);
      return false;
    }
  }

  void backToOtp() => state = const ResetPasscodeState(phase: ResetPasscodePhase.otp);
  void backToCreate() => state = state.copyWith(phase: ResetPasscodePhase.create, clearError: true);
}

final resetPasscodeProvider =
    NotifierProvider.autoDispose<ResetPasscodeNotifier, ResetPasscodeState>(
  ResetPasscodeNotifier.new,
);
