import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../icons/app_icons.dart';
import '../../app/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/group/presentation/widgets/invite_link_listener.dart';
import '../../features/onboarding/providers/tour_provider.dart';
import 'app_coachmark.dart';
import '../../features/group/providers/group_chat_hub_provider.dart';
import 'add_options_sheet.dart';
import 'clara_fab.dart';
import 'widget_link_listener.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(RouteNames.home)) return 0;
    if (location.startsWith(RouteNames.expenses)) return 1;
    if (location.startsWith(RouteNames.budget)) return 3;
    if (location.startsWith(RouteNames.group)) return 4;
    return 0;
  }

  void _onTabTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
      case 1:
        context.go(RouteNames.expenses);
      case 3:
        context.go(RouteNames.budget);
      case 4:
        context.go(RouteNames.group);
    }
  }

  void _onAddTap(BuildContext context, WidgetRef ref) {
    showAddOptionsSheet(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bootstraps the group-chat notification hub for the whole session — see
    // group_chat_hub_provider.dart. Reading it once here is enough; it is not
    // autoDispose, so it persists across navigation until logout resets it.
    ref.watch(groupChatNotificationsProvider);

    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);
    final tourKeys = ref.read(tourProvider.notifier).keys;

    // The coachmark scope must wrap everything the tour points at, including
    // the bottom nav — so it sits above the Scaffold, not inside its body.
    return AppCoachmarkScope(
      // The queued flag is already consumed before the tour starts; this is a
      // belt-and-braces clear in case it was started some other way.
      onFinish: () => ref.read(tourProvider.notifier).consume(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: WidgetLinkListener(
                child: InviteLinkListener(child: child),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: AppCoachmark(
                coachKey: tourKeys[TourStep.clara]!,
                title: 'Ask Clara',
                description:
                    'Your AI money assistant. Ask about your spending, '
                    'budgets or anything else.',
                circular: true,
                child: const ClaraFab(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _FinclarBottomNav(
          tourKeys: tourKeys,
          currentIndex: currentIndex,
          onTap: (i) => i == 2 ? _onAddTap(context, ref) : _onTabTap(context, i),
        ),
      ),
    );
  }
}

class _FinclarBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Map<TourStep, GlobalKey> tourKeys;

  const _FinclarBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.tourKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor, width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: AppIcons.home,
                activeIcon: AppIcons.homeActive,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                coachKey: tourKeys[TourStep.expenses],
                coachTitle: 'Every expense, in one place',
                coachDescription:
                    'Scanned, typed or synced from your bank — they all land here.',
                icon: AppIcons.expenses,
                activeIcon: AppIcons.expensesActive,
                label: AppStrings.expenses,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _AddButton(
                coachKey: tourKeys[TourStep.add]!,
                onTap: () => onTap(2),
              ),
              _NavItem(
                coachKey: tourKeys[TourStep.budget],
                coachTitle: 'Set your limits',
                coachDescription:
                    'Create budgets per category and watch them as you spend.',
                icon: AppIcons.budget,
                activeIcon: AppIcons.budgetActive,
                label: AppStrings.budget,
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                coachKey: tourKeys[TourStep.groups],
                coachTitle: 'Save together',
                coachDescription:
                    'Add friends, split costs and run shared savings goals.',
                icon: AppIcons.group,
                activeIcon: AppIcons.groupActive,
                label: AppStrings.groups,
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final GlobalKey? coachKey;
  final String? coachTitle;
  final String? coachDescription;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.coachKey,
    this.coachTitle,
    this.coachDescription,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = context.textSecondary;

    final item = InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? AppColors.primary : inactiveColor,
              ),
            ),
          ],
        ),
    );

    if (coachKey == null) return Expanded(child: item);
    return Expanded(
      child: AppCoachmark(
        coachKey: coachKey!,
        title: coachTitle ?? label,
        description: coachDescription ?? '',
        child: item,
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final GlobalKey coachKey;

  const _AddButton({required this.onTap, required this.coachKey});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          child: AppCoachmark(
            coachKey: coachKey,
            title: 'Add income or expenses',
            description:
                'Set what you earn, scan a receipt, or type an expense in.',
            circular: true,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.add, color: AppColors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
