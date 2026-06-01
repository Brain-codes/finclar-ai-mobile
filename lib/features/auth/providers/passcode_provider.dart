import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/logger_service.dart';
import 'auth_repository_provider.dart';
import 'sign_up_provider.dart';

enum PasscodePhase { create, confirm }

class PasscodeState {
  final PasscodePhase phase;
  final String passcode;
  final bool hasError;
  final String? errorText;
  final bool isLoading;
  final bool completed;
  final String? apiError;

  const PasscodeState({
    this.phase = PasscodePhase.create,
    this.passcode = '',
    this.hasError = false,
    this.errorText,
    this.isLoading = false,
    this.completed = false,
    this.apiError,
  });

  PasscodeState copyWith({
    PasscodePhase? phase,
    String? passcode,
    bool? hasError,
    String? errorText,
    bool? isLoading,
    bool? completed,
    String? apiError,
    bool clearError = false,
    bool clearApiError = false,
  }) {
    return PasscodeState(
      phase: phase ?? this.phase,
      passcode: passcode ?? this.passcode,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorText: clearError ? null : (errorText ?? this.errorText),
      isLoading: isLoading ?? this.isLoading,
      completed: completed ?? this.completed,
      apiError: clearApiError ? null : (apiError ?? this.apiError),
    );
  }
}

class PasscodeNotifier extends Notifier<PasscodeState> {
  @override
  PasscodeState build() => const PasscodeState();

  void clearError() => state = state.copyWith(clearError: true);
  void clearApiError() => state = state.copyWith(clearApiError: true);

  void onPasscodeCreated(String passcode) {
    state = state.copyWith(
      passcode: passcode,
      phase: PasscodePhase.confirm,
      clearError: true,
    );
  }

  Future<bool> onPasscodeConfirmed(String confirmation) async {
    if (confirmation != state.passcode) {
      state = state.copyWith(
        hasError: true,
        errorText: AppStrings.passcodeDoNotMatch,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final signUpState = ref.read(signUpProvider);
      await ref.read(authRepositoryProvider).register(
            email: signUpState.email,
            username: signUpState.username,
            passcode: state.passcode,
          );
      state = state.copyWith(isLoading: false, completed: true);
      return true;
    } on ConflictException catch (e) {
      state = state.copyWith(isLoading: false, apiError: e.message);
      return false;
    } on AppException catch (e) {
      Log.e('Register failed', error: e);
      state = state.copyWith(
        isLoading: false,
        apiError: AppStrings.somethingWentWrong,
      );
      return false;
    }
  }

  void backToCreate() {
    state = const PasscodeState();
  }
}

final passcodeProvider =
    NotifierProvider<PasscodeNotifier, PasscodeState>(PasscodeNotifier.new);
