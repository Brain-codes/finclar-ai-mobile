import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/logger_service.dart';
import 'auth_repository_provider.dart';

enum UsernameStatus { idle, checking, available, taken, error }

class SignUpFormState {
  final bool isLoading;
  final String? emailError;
  final String? usernameError;
  final String email;
  final String username;
  final UsernameStatus usernameStatus;

  const SignUpFormState({
    this.isLoading = false,
    this.emailError,
    this.usernameError,
    this.email = '',
    this.username = '',
    this.usernameStatus = UsernameStatus.idle,
  });

  SignUpFormState copyWith({
    bool? isLoading,
    String? emailError,
    String? usernameError,
    String? email,
    String? username,
    UsernameStatus? usernameStatus,
    bool clearEmailError = false,
    bool clearUsernameError = false,
  }) {
    return SignUpFormState(
      isLoading: isLoading ?? this.isLoading,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      usernameError: clearUsernameError ? null : (usernameError ?? this.usernameError),
      email: email ?? this.email,
      username: username ?? this.username,
      usernameStatus: usernameStatus ?? this.usernameStatus,
    );
  }
}

class SignUpNotifier extends Notifier<SignUpFormState> {
  Timer? _debounce;

  @override
  SignUpFormState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SignUpFormState();
  }

  void clearEmailError() => state = state.copyWith(clearEmailError: true);

  void clearUsernameError() => state = state.copyWith(clearUsernameError: true);

  void onUsernameChanged(String value) {
    _debounce?.cancel();
    state = state.copyWith(
      clearUsernameError: true,
      usernameStatus: UsernameStatus.idle,
    );

    final trimmed = value.trim();
    if (trimmed.length < 3) return;

    final validationErr = _validateUsernameFormat(trimmed);
    if (validationErr != null) return;

    state = state.copyWith(usernameStatus: UsernameStatus.checking);
    _debounce = Timer(const Duration(milliseconds: 600), () => _checkUsername(trimmed));
  }

  Future<void> _checkUsername(String username) async {
    try {
      final available = await ref
          .read(authRepositoryProvider)
          .checkUsernameAvailable(username);
      state = state.copyWith(
        usernameStatus: available ? UsernameStatus.available : UsernameStatus.taken,
        usernameError: available ? null : 'Username is already taken',
      );
    } on AppException catch (e) {
      Log.e('Username check failed', error: e);
      state = state.copyWith(usernameStatus: UsernameStatus.error);
    }
  }

  bool submit(String email, String username) {
    final emailErr = _validateEmail(email);
    final usernameErr = _validateUsernameFormat(username.trim());

    if (emailErr != null || usernameErr != null) {
      state = state.copyWith(
        emailError: emailErr,
        usernameError: usernameErr,
      );
      return false;
    }

    if (state.usernameStatus == UsernameStatus.taken) {
      state = state.copyWith(usernameError: 'Username is already taken');
      return false;
    }

    if (state.usernameStatus == UsernameStatus.checking) {
      return false;
    }

    state = state.copyWith(
      email: email.trim(),
      username: username.trim(),
      clearEmailError: true,
      clearUsernameError: true,
    );
    return true;
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Email address is required';
    final emailRegex = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  String? _validateUsernameFormat(String trimmed) {
    if (trimmed.isEmpty) return 'Username is required';
    if (trimmed.length < 3) return 'Username must be at least 3 characters';
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(trimmed)) {
      return 'Only letters, numbers and underscores allowed';
    }
    return null;
  }
}

final signUpProvider = NotifierProvider<SignUpNotifier, SignUpFormState>(
  SignUpNotifier.new,
);
