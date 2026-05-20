import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpFormState {
  final bool isLoading;
  final String? emailError;
  final String? usernameError;

  const SignUpFormState({
    this.isLoading = false,
    this.emailError,
    this.usernameError,
  });

  SignUpFormState copyWith({
    bool? isLoading,
    String? emailError,
    String? usernameError,
    bool clearEmailError = false,
    bool clearUsernameError = false,
  }) {
    return SignUpFormState(
      isLoading: isLoading ?? this.isLoading,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      usernameError: clearUsernameError ? null : (usernameError ?? this.usernameError),
    );
  }
}

class SignUpNotifier extends Notifier<SignUpFormState> {
  @override
  SignUpFormState build() => const SignUpFormState();

  void clearEmailError() => state = state.copyWith(clearEmailError: true);
  void clearUsernameError() => state = state.copyWith(clearUsernameError: true);

  // Returns true if validation passes and screen should navigate forward.
  Future<bool> submit(String email, String username) async {
    final emailErr = _validateEmail(email);
    final usernameErr = _validateUsername(username);

    if (emailErr != null || usernameErr != null) {
      state = state.copyWith(
        emailError: emailErr,
        usernameError: usernameErr,
      );
      return false;
    }

    state = state.copyWith(isLoading: true);
    try {
      // TODO: call ApiClient to check email availability / initiate signup
      await Future.delayed(const Duration(milliseconds: 1200));
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        emailError: 'Something went wrong. Please try again.',
      );
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

  String? _validateUsername(String value) {
    final trimmed = value.trim();
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
