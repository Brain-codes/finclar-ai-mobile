import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncomeSetupState {
  final bool hasIncome;
  final List<String> sources;

  const IncomeSetupState({
    this.hasIncome = false,
    this.sources = const ['Salary', 'Freelance', 'Business', 'Investment'],
  });

  IncomeSetupState copyWith({bool? hasIncome, List<String>? sources}) =>
      IncomeSetupState(
        hasIncome: hasIncome ?? this.hasIncome,
        sources: sources ?? this.sources,
      );
}

class IncomeSetupNotifier extends Notifier<IncomeSetupState> {
  @override
  IncomeSetupState build() => const IncomeSetupState();

  void markIncomeSet() => state = state.copyWith(hasIncome: true);

  void addSource(String source) {
    final trimmed = source.trim();
    if (trimmed.isEmpty || state.sources.contains(trimmed)) return;
    state = state.copyWith(sources: [...state.sources, trimmed]);
  }
}

final incomeSetupProvider =
    NotifierProvider<IncomeSetupNotifier, IncomeSetupState>(
  IncomeSetupNotifier.new,
);
