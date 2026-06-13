import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../features/auth/providers/auth_repository_provider.dart';

enum ChangePasscodePhase { otp, create, confirm }

class ChangePasscodeState {
  final ChangePasscodePhase phase;
  final String otp;
  final String newPasscode;
  final bool hasError;
  final String? errorText;
  final bool isLoading;
  final bool isSendingOtp;
  final String? snackbarError;
  final String? snackbarSuccess;

  const ChangePasscodeState({
    this.phase = ChangePasscodePhase.otp,
    this.otp = '',
    this.newPasscode = '',
    this.hasError = false,
    this.errorText,
    this.isLoading = false,
    this.isSendingOtp = false,
    this.snackbarError,
    this.snackbarSuccess,
  });

  ChangePasscodeState copyWith({
    ChangePasscodePhase? phase,
    String? otp,
    String? newPasscode,
    bool? hasError,
    String? errorText,
    bool? isLoading,
    bool? isSendingOtp,
    String? snackbarError,
    String? snackbarSuccess,
    bool clearError = false,
    bool clearSnackbarError = false,
    bool clearSnackbarSuccess = false,
  }) {
    return ChangePasscodeState(
      phase: phase ?? this.phase,
      otp: otp ?? this.otp,
      newPasscode: newPasscode ?? this.newPasscode,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorText: clearError ? null : (errorText ?? this.errorText),
      isLoading: isLoading ?? this.isLoading,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      snackbarError: clearSnackbarError ? null : (snackbarError ?? this.snackbarError),
      snackbarSuccess: clearSnackbarSuccess ? null : (snackbarSuccess ?? this.snackbarSuccess),
    );
  }
}

class ChangePasscodeNotifier extends Notifier<ChangePasscodeState> {
  @override
  ChangePasscodeState build() {
    Future.microtask(_sendOtp);
    return const ChangePasscodeState(isSendingOtp: true);
  }

  Future<void> _sendOtp() async {
    try {
      final email = await StorageService.getLastEmail();
      if (email == null) {
        state = state.copyWith(isSendingOtp: false, snackbarError: 'Could not find your email. Please log out and log in again.');
        return;
      }
      await ref.read(authRepositoryProvider).forgotPasscode(email: email);
      state = state.copyWith(isSendingOtp: false);
    } on AppException catch (e) {
      Log.e('Send passcode change OTP failed', error: e);
      state = state.copyWith(isSendingOtp: false, snackbarError: e.message);
    }
  }

  Future<void> resendOtp() async {
    state = state.copyWith(isSendingOtp: true);
    await _sendOtp();
    state = state.copyWith(snackbarSuccess: 'A new code has been sent to your email');
  }

  void clearError() => state = state.copyWith(clearError: true);
  void clearSnackbarError() => state = state.copyWith(clearSnackbarError: true);
  void clearSnackbarSuccess() => state = state.copyWith(clearSnackbarSuccess: true);

  void onOtpEntered(String code) {
    state = state.copyWith(
      otp: code,
      phase: ChangePasscodePhase.create,
      clearError: true,
    );
  }

  void onNewPasscodeCreated(String passcode) {
    state = state.copyWith(
      newPasscode: passcode,
      phase: ChangePasscodePhase.confirm,
      clearError: true,
    );
  }

  Future<bool> onNewPasscodeConfirmed(String confirmation) async {
    if (confirmation != state.newPasscode) {
      state = state.copyWith(
        hasError: true,
        errorText: AppStrings.passcodeDoNotMatch,
      );
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final email = await StorageService.getLastEmail() ?? '';
      final tokens = await ref.read(authRepositoryProvider).resetPasscode(
            email: email,
            code: state.otp,
            newPasscode: state.newPasscode,
          );
      // Save fresh tokens so logoutAll (called from the sheet) is authenticated.
      await StorageService.saveTokens(
        access: tokens.accessToken,
        refresh: tokens.refreshToken,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on AppException catch (e) {
      Log.e('Change passcode failed', error: e);
      state = state.copyWith(isLoading: false, snackbarError: e.message);
      return false;
    }
  }

  void backToOtp() => state = state.copyWith(phase: ChangePasscodePhase.otp, clearError: true);
  void backToCreate() => state = state.copyWith(phase: ChangePasscodePhase.create, clearError: true);
}

final changePasscodeProvider =
    NotifierProvider<ChangePasscodeNotifier, ChangePasscodeState>(
  ChangePasscodeNotifier.new,
);
