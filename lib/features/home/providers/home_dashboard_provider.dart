import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../expenses/data/models/expense_summary_model.dart';
import '../../expenses/providers/expense_providers.dart';

final homeSummaryProvider = FutureProvider<ExpenseSummaryModel>((ref) {
  return ref.watch(expenseRepositoryProvider).getSummary();
});

final homeInsightProvider = FutureProvider<String>((ref) {
  return ref.watch(expenseRepositoryProvider).getHomeInsight();
});

/// Selected month (1–12) for the spending screen's month filter.
final spendingMonthProvider = StateProvider<int>((ref) => DateTime.now().month);

/// Spending screen summary, scoped to the [spendingMonthProvider] selection.
final spendingSummaryProvider = FutureProvider<ExpenseSummaryModel>((ref) {
  final month = ref.watch(spendingMonthProvider);
  return ref.watch(expenseRepositoryProvider).getSummary(
        year: DateTime.now().year,
        month: month,
      );
});
