import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/auth_state_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/storage_service.dart';
import 'auth_repository_provider.dart';

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

  const LoginState({
    this.initialized = false,
    this.phase = LoginPhase.email,
    this.email = '',
    this.savedEmail,
    this.isLoading = false,
    this.emailError,
    this.snackbarError,
    this.emailNotVerified = false,
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
    state = state.copyWith(
      initialized: true,
      savedEmail: saved,
      email: saved ?? '',
      phase: saved != null ? LoginPhase.passcode : LoginPhase.email,
    );
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
      await authStateService.logIn(tokens.accessToken, tokens.refreshToken, isNewUser: false);
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

  /// "Not my account" — clears saved email and returns to email phase.
  Future<void> clearSavedEmail() async {
    await StorageService.clearLastEmail();
    state = state.copyWith(
      clearSavedEmail: true,
      phase: LoginPhase.email,
      email: '',
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
