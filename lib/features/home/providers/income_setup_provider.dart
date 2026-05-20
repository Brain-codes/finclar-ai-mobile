import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncomeSetupState {
  final bool hasIncome;

  const IncomeSetupState({this.hasIncome = false});

  IncomeSetupState copyWith({bool? hasIncome}) =>
      IncomeSetupState(hasIncome: hasIncome ?? this.hasIncome);
}

class IncomeSetupNotifier extends Notifier<IncomeSetupState> {
  @override
  IncomeSetupState build() => const IncomeSetupState();

  // Called after the user successfully sets income
  void markIncomeSet() => state = state.copyWith(hasIncome: true);
}

final incomeSetupProvider =
    NotifierProvider<IncomeSetupNotifier, IncomeSetupState>(
  IncomeSetupNotifier.new,
);
