import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/auth_state_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/session_reset.dart';
import '../../../core/services/storage_service.dart';
import 'auth_repository_provider.dart';
import 'user_profile_provider.dart';

enum LoginPhase { email, passcode }

class LoginState {
  final bool initialized;
  final LoginPhase phase;
  final String email;
  final String? savedEmail;
  final bool isLoading;
  final String? emailError;
  final String? snackbarError;
  final bool emailNotVerified;
  final bool canUseBiometrics;

  const LoginState({
    this.initialized = false,
    this.phase = LoginPhase.email,
    this.email = '',
    this.savedEmail,
    this.isLoading = false,
    this.emailError,
    this.snackbarError,
    this.emailNotVerified = false,
    this.canUseBiometrics = false,
  });

  bool get isReturningUser => initialized && savedEmail != null;

  LoginState copyWith({
    bool? initialized,
    LoginPhase? phase,
    String? email,
    String? savedEmail,
    bool? isLoading,
    String? emailError,
    String? snackbarError,
    bool? emailNotVerified,
    bool? canUseBiometrics,
    bool clearEmailError = false,
    bool clearSnackbarError = false,
    bool clearSavedEmail = false,
  }) {
    return LoginState(
      initialized: initialized ?? this.initialized,
      phase: phase ?? this.phase,
      email: email ?? this.email,
      savedEmail: clearSavedEmail ? null : (savedEmail ?? this.savedEmail),
      isLoading: isLoading ?? this.isLoading,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      snackbarError: clearSnackbarError ? null : (snackbarError ?? this.snackbarError),
      emailNotVerified: emailNotVerified ?? this.emailNotVerified,
      canUseBiometrics: canUseBiometrics ?? this.canUseBiometrics,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() {
    _loadSavedEmail();
    return const LoginState();
  }

  Future<void> _loadSavedEmail() async {
    final saved = await StorageService.getLastEmail();
    final canUseBiometrics = saved != null && await _biometricsReady();
    state = state.copyWith(
      initialized: true,
      savedEmail: saved,
      email: saved ?? '',
      phase: saved != null ? LoginPhase.passcode : LoginPhase.email,
      canUseBiometrics: canUseBiometrics,
    );
  }

  Future<bool> _biometricsReady() async {
    if (!await BiometricService.isEnabled()) return false;
    final passcode = await StorageService.getBiometricPasscode();
    if (passcode == null) return false;
    return BiometricService.isAvailable();
  }

  void clearEmailError() => state = state.copyWith(clearEmailError: true);
  void clearSnackbarError() => state = state.copyWith(clearSnackbarError: true);
  void clearEmailNotVerified() => state = state.copyWith(emailNotVerified: false);

  /// Step 1 — validates email and advances to the passcode phase.
  void continueWithEmail(String email) {
    final err = _validateEmail(email);
    if (err != null) {
      state = state.copyWith(emailError: err);
      return;
    }
    state = state.copyWith(
      email: email.trim(),
      phase: LoginPhase.passcode,
      clearEmailError: true,
    );
  }

  /// Step 2 — submits the passcode against the stored/entered email.
  Future<void> submitPasscode(String passcode) async {
    if (passcode.length < 6) return;
    state = state.copyWith(isLoading: true);
    try {
      final tokens = await ref.read(authRepositoryProvider).login(
            email: state.email,
            passcode: passcode,
          );
      await StorageService.saveLastEmail(state.email);
      if (await BiometricService.isEnabled()) {
        await StorageService.saveBiometricPasscode(passcode);
      }
      // Clear the previous user's cached data BEFORE logging in — logIn()
      // notifies the router synchronously, so the new home screen must not be
      // able to read stale providers.
      clearUserScopedDataRef(ref);
      await authStateService.logIn(tokens.accessToken, tokens.refreshToken, isNewUser: false);
      ref.read(userProfileProvider.notifier).fetch();
      Analytics.login(method: 'passcode');
      state = state.copyWith(isLoading: false);
    } on ForbiddenException catch (e) {
      final isNotVerified = e.message.toLowerCase().contains('not verified');
      if (isNotVerified) {
        state = state.copyWith(isLoading: false, emailNotVerified: true);
      } else {
        state = state.copyWith(isLoading: false, snackbarError: e.message);
      }
    } on AppException catch (e) {
      Log.e('Login failed', error: e);
      state = state.copyWith(isLoading: false, snackbarError: e.message);
    }
  }

  /// Biometric login — verifies identity, then replays the stored passcode.
  Future<void> loginWithBiometrics() async {
    if (!state.canUseBiometrics || state.isLoading) return;
    final result = await BiometricService.authenticate(
      reason: 'Log in to Finclar AI',
    );
    if (result == BiometricResult.cancelled) return;
    if (result != BiometricResult.success) {
      state = state.copyWith(snackbarError: 'Could not verify biometrics');
      return;
    }
    final passcode = await StorageService.getBiometricPasscode();
    if (passcode == null) {
      state = state.copyWith(canUseBiometrics: false);
      return;
    }
    await submitPasscode(passcode);
  }

  /// "Not my account" — clears saved email and returns to email phase.
  Future<void> clearSavedEmail() async {
    await StorageService.clearLastEmail();
    await StorageService.clearBiometricPasscode();
    await StorageService.setBiometricEnabled(false);
    state = state.copyWith(
      clearSavedEmail: true,
      phase: LoginPhase.email,
      email: '',
      canUseBiometrics: false,
    );
  }

  /// Goes back from passcode phase to email phase.
  void backToEmail() {
    state = state.copyWith(phase: LoginPhase.email, clearEmailError: true);
  }

  /// Resends OTP for unverified email (called from the 403 bottom sheet).
  Future<bool> resendVerification() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).resendOtp(email: state.email);
      return true;
    } on AppException catch (e) {
      Log.e('Resend OTP failed', error: e);
      state = state.copyWith(snackbarError: e.message);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Email address is required';
    final emailRegex = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
