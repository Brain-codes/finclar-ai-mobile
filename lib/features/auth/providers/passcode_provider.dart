import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PasscodePhase { create, confirm }

class PasscodeState {
  final PasscodePhase phase;
  final String passcode;
  final bool hasError;
  final String? errorText;
  final bool isLoading;
  final bool completed;

  const PasscodeState({
    this.phase = PasscodePhase.create,
    this.passcode = '',
    this.hasError = false,
    this.errorText,
    this.isLoading = false,
    this.completed = false,
  });

  PasscodeState copyWith({
    PasscodePhase? phase,
    String? passcode,
    bool? hasError,
    String? errorText,
    bool? isLoading,
    bool? completed,
    bool clearError = false,
  }) {
    return PasscodeState(
      phase: phase ?? this.phase,
      passcode: passcode ?? this.passcode,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorText: clearError ? null : (errorText ?? this.errorText),
      isLoading: isLoading ?? this.isLoading,
      completed: completed ?? this.completed,
    );
  }
}

class PasscodeNotifier extends Notifier<PasscodeState> {
  @override
  PasscodeState build() => const PasscodeState();

  void clearError() => state = state.copyWith(clearError: true);

  // Called when user completes entry in create phase.
  // Stores the passcode and moves to confirm phase.
  void onPasscodeCreated(String passcode) {
    state = state.copyWith(
      passcode: passcode,
      phase: PasscodePhase.confirm,
      clearError: true,
    );
  }

  // Called when user completes entry in confirm phase.
  // Returns true if they match and the flow should advance.
  Future<bool> onPasscodeConfirmed(String confirmation) async {
    if (confirmation != state.passcode) {
      state = state.copyWith(
        hasError: true,
        errorText: 'Passcodes do not match',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // TODO: call ApiClient to save passcode
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(isLoading: false, completed: true);
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

  // Let user go back from confirm phase to create phase
  void backToCreate() {
    state = const PasscodeState();
  }
}

final passcodeProvider =
    NotifierProvider<PasscodeNotifier, PasscodeState>(PasscodeNotifier.new);
