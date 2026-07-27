import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/services/logger_service.dart';
import '../../providers/income_setup_provider.dart';
import '../../providers/home_dashboard_provider.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../../expenses/providers/expense_providers.dart';
import '../../../budget/providers/budget_providers.dart';
import '../../../notifications/providers/notifications_provider.dart';
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

    final username = ref.watch(userProfileProvider).valueOrNull?.username ?? '';
    final unreadNotifications = ref.watch(unreadNotificationCountProvider) > 0;

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
                onNotificationTap: () =>
                    context.push(RouteNames.notifications),
                hasUnreadNotifications: unreadNotifications,
                isLoading: incomeAsync.isLoading,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(homeSummaryProvider);
                  ref.invalidate(homeInsightProvider);
                  ref.read(budgetProvider.notifier).refresh();
                  await ref.read(expenseListProvider.notifier).refresh();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.base),
                      const BalanceCard(),
                      const SizedBox(height: AppSpacing.base),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding,
                        ),
                        child: Column(
                          children: [
                            SpendingCard(
                              onTap: () => context.push(RouteNames.spending),
                            ),
                            const SizedBox(height: AppSpacing.base),
                            BudgetSection(
                              onBreakdownTap: () =>
                                  context.push(RouteNames.budget),
                            ),
                            const SizedBox(height: AppSpacing.base),
                            const IncomeExpenseChartSection(),
                            const SizedBox(height: AppSpacing.base),
                            RecentExpensesSection(
                              onViewAll: () => context.push(RouteNames.expenses),
                            ),
                            const SizedBox(height: AppSpacing.base),
                            const ClaraCard(),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
