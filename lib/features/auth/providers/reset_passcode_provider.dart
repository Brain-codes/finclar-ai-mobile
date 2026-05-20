import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ResetPasscodePhase { create, confirm }

class ResetPasscodeState {
  final ResetPasscodePhase phase;
  final String passcode;
  final bool hasError;
  final String? errorText;
  final bool isLoading;

  const ResetPasscodeState({
    this.phase = ResetPasscodePhase.create,
    this.passcode = '',
    this.hasError = false,
    this.errorText,
    this.isLoading = false,
  });

  ResetPasscodeState copyWith({
    ResetPasscodePhase? phase,
    String? passcode,
    bool? hasError,
    String? errorText,
    bool? isLoading,
    bool clearError = false,
  }) {
    return ResetPasscodeState(
      phase: phase ?? this.phase,
      passcode: passcode ?? this.passcode,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorText: clearError ? null : (errorText ?? this.errorText),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ResetPasscodeNotifier extends Notifier<ResetPasscodeState> {
  @override
  ResetPasscodeState build() => const ResetPasscodeState();

  void clearError() => state = state.copyWith(clearError: true);

  void onPasscodeCreated(String passcode) {
    state = state.copyWith(
      passcode: passcode,
      phase: ResetPasscodePhase.confirm,
      clearError: true,
    );
  }

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
      await Future.delayed(const Duration(milliseconds: 800));
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

  void backToCreate() => state = const ResetPasscodeState();
}

final resetPasscodeProvider =
    NotifierProvider<ResetPasscodeNotifier, ResetPasscodeState>(
  ResetPasscodeNotifier.new,
);
