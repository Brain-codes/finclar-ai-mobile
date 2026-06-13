import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/services/logger_service.dart';
import '../../providers/income_setup_provider.dart';
import '../../../auth/providers/user_profile_provider.dart';
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
  bool _modalShown = false;

  @override
  void initState() {
    super.initState();
    Log.d('[HomeScreen] initState — screen mounted');
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final incomeAsync = ref.watch(incomeProvider);
    Log.d('[HomeScreen] incomeProvider state: $incomeAsync');

    ref.listen(incomeProvider, (prev, next) {
      Log.d('[HomeScreen] incomeProvider changed: $prev → $next');
      if (!_modalShown && next is AsyncData && next.value == null && mounted) {
        Log.d('[HomeScreen] no income found — showing setup modal');
        _modalShown = true;
        showIncomeSetupModal(context);
      }
    });

    final income = incomeAsync.valueOrNull;
    final isEmpty = !incomeAsync.isLoading && income == null;
    final symbol = ref.watch(currencySymbolProvider);
    final username = ref.watch(userProfileProvider).valueOrNull?.username ?? '';

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.base,
              ),
              child: HomeHeader(
                userName: username,
                greeting: _greeting(),
                onAvatarTap: () => context.push(RouteNames.settings),
                isLoading: incomeAsync.isLoading,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.base),
                    BalanceCard(
                      balance: isEmpty
                          ? '${symbol}0.00'
                          : formatCurrency(1850000, symbol,
                              abbreviate: false, withCommas: true),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                      ),
                      child: Column(
                        children: [
                          SpendingCard(
                            isEmpty: isEmpty,
                            onTap: () => context.push(RouteNames.spending),
                          ),
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
          ],
        ),
      ),
    );
  }
}
