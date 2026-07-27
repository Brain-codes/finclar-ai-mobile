import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/auth_state_service.dart';
import '../../../core/services/logger_service.dart';
import '../data/models/financial_goal_model.dart';
import 'auth_repository_provider.dart';

final goalsProvider = FutureProvider<List<FinancialGoalModel>>((ref) {
  return ref.watch(authRepositoryProvider).getGoals();
});

class PreferenceState {
  final bool isLoading;
  final String? snackbarError;

  const PreferenceState({this.isLoading = false, this.snackbarError});

  PreferenceState copyWith({
    bool? isLoading,
    String? snackbarError,
    bool clearSnackbarError = false,
  }) {
    return PreferenceState(
      isLoading: isLoading ?? this.isLoading,
      snackbarError: clearSnackbarError ? null : (snackbarError ?? this.snackbarError),
    );
  }
}

class PreferenceNotifier extends Notifier<PreferenceState> {
  @override
  PreferenceState build() => const PreferenceState();

  void clearSnackbarError() => state = state.copyWith(clearSnackbarError: true);

  Future<void> saveGoals(List<String> goals) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).setGoals(goals);
      await authStateService.goalsCompleted();
    } on AppException catch (e) {
      Log.e('Set goals failed', error: e);
      state = state.copyWith(isLoading: false, snackbarError: e.message);
    }
  }

  Future<void> skipGoals() async {
    state = state.copyWith(isLoading: true);
    await authStateService.goalsSkipped();
  }
}

final preferenceProvider = NotifierProvider<PreferenceNotifier, PreferenceState>(
  PreferenceNotifier.new,
);
