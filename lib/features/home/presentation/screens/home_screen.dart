import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_constants.dart';
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
import '../../../gamification/presentation/widgets/challenge_prompts.dart';
import '../../../onboarding/presentation/widgets/quick_start_card.dart';
import '../../../onboarding/providers/tour_provider.dart';
import '../../../../shared/widgets/app_coachmark.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _modalShown = false;
  bool _tourStarted = false;

  @override
  void dispose() {
    // Leaving home while the tour runs would leave the overlay painting over
    // the next screen.
    if (_tourStarted) dismissAppCoachmarks();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Log.d('[HomeScreen] initState — screen mounted');
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTour());
  }

  /// Runs at most one first-run interruption. The tour goes first for a brand
  /// new user; the challenge prompt only gets its turn once the tour is done,
  /// so the two can never stack.
  Future<void> _maybeStartTour() async {
    if (_tourStarted) return;
    if (!ref.read(tourProvider)) return _maybePromptChallenge();

    // Wait for income to resolve so the tour can't open behind the income
    // setup modal, which takes priority for a brand new user.
    try {
      if (await ref.read(incomeProvider.future) == null) return;
    } catch (_) {
      return;
    }
    if (!mounted || _modalShown) return;

    // The tour points at the shell's nav bar and this screen's balance card.
    // If home isn't the visible route, the overlay would paint over whatever
    // is — which is exactly the "sitting between two screens" bug.
    if (!_isHomeCurrentRoute) return;

    // Let the incoming route's transition finish. Starting during the push
    // animation is what made the spotlight land in the wrong place.
    await Future.delayed(AppConstants.animSlow);
    if (!mounted || !_isHomeCurrentRoute) return;

    // Consumed before it runs — dismissing must never bring it back.
    _tourStarted = true;
    await ref.read(tourProvider.notifier).consume();
    if (!mounted) return;
    startAppCoachmarks(ref.read(tourProvider.notifier).orderedKeys);
  }

  bool get _isHomeCurrentRoute {
    final route = ModalRoute.of(context);
    return route?.isCurrent ?? false;
  }

  /// Waits on income first so this never stacks on top of the income setup
  /// modal, which takes priority for a brand new user.
  Future<void> _maybePromptChallenge() async {
    try {
      if (await ref.read(incomeProvider.future) == null) return;
    } catch (_) {
      return;
    }
    if (!mounted || _modalShown) return;
    await maybeShowChallengePrompts(
      context,
      ProviderScope.containerOf(context),
    );
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

    ref.watch(homeWidgetSyncProvider);

    // Settings sits on top of the shell, so returning to home via
    // "Replay app tour" never remounts HomeScreen and initState's
    // _maybeStartTour never re-fires. Watch the flag directly so a tour
    // queued while home is already alive still starts.
    ref.listen(tourProvider, (prev, next) {
      if (next && !(prev ?? false)) _maybeStartTour();
    });

    ref.listen(incomeProvider, (prev, next) {
      Log.d('[HomeScreen] incomeProvider changed: $prev → $next');
      if (!_modalShown && next is AsyncData && next.value == null && mounted) {
        Log.d('[HomeScreen] no income found — showing setup modal');
        _modalShown = true;
        showIncomeSetupModal(context);
      }
    });

    final username =
        ref.watch(userProfileProvider).valueOrNull?.displayName ?? '';
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
                profileIcon: ref.watch(userProfileProvider).valueOrNull?.profileIcon,
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
                      AppCoachmark(
                        coachKey: ref
                            .read(tourProvider.notifier)
                            .keys[TourStep.balance]!,
                        title: 'Your money at a glance',
                        description:
                            'What you have left after everything you have '
                            'logged this month.',
                        child: const BalanceCard(),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding,
                        ),
                        child: Column(
                          children: [
                            const QuickStartCard(),
                            const SizedBox(height: AppSpacing.base),
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
