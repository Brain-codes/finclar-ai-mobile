import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../providers/income_setup_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/spending_card.dart';
import '../widgets/budget_section.dart';
import '../widgets/income_expense_chart_section.dart';
import '../widgets/recent_expenses_section.dart';
import '../widgets/clara_card.dart';
import '../widgets/income_setup_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasIncome = ref.read(incomeSetupProvider).hasIncome;
      if (!hasIncome && mounted) {
        showIncomeSetupModal(context);
      }
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final hasIncome = ref.watch(incomeSetupProvider).hasIncome;
    final isEmpty = false;
    // final isEmpty = !hasIncome;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.base,
                ),
                child: HomeHeader(userName: 'Chinasa', greeting: _greeting()),
              ),
              const SizedBox(height: AppSpacing.base),
              BalanceCard(balance: isEmpty ? '₦00.00' : '₦1,850,000.00'),
              const SizedBox(height: AppSpacing.base),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  children: [
                    SpendingCard(isEmpty: isEmpty),
                    const SizedBox(height: AppSpacing.base),
                    BudgetSection(isEmpty: isEmpty),
                    const SizedBox(height: AppSpacing.base),
                    IncomeExpenseChartSection(isEmpty: isEmpty),
                    const SizedBox(height: AppSpacing.base),
                    RecentExpensesSection(isEmpty: isEmpty),
                    const SizedBox(height: AppSpacing.base),
                    ClaraCard(isEmpty: isEmpty),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
