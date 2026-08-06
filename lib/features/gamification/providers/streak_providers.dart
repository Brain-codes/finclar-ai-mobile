import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../data/models/expense_streak_model.dart';
import '../data/repositories/streak_repository.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(ref.watch(apiClientProvider));
});

/// Daily expense-logging streak. Invalidated whenever an expense is created so
/// the count reflects the log that just happened.
final expenseStreakProvider = FutureProvider<ExpenseStreakModel>((ref) {
  return ref.watch(streakRepositoryProvider).getStreak();
});
