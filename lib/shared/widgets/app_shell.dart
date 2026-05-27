import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../icons/app_icons.dart';
import '../../app/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/expenses/presentation/widgets/bank_integration_modal.dart';
import 'app_sheet.dart';

class AppShell extends StatelessWidget {
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

  void _onAddTap(BuildContext context) {
    showAppSheet(
      context,
      title: 'Add expense',
      children: [
        _AddOption(
          icon: AppIcons.cameraFill,
          iconColor: AppColors.categoryPurple,
          title: 'Scan receipt',
          subtitle: 'Snap and categorize your expense',
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            context.push(RouteNames.addExpenseOcr);
          },
        ),
        _AddOption(
          icon: AppIcons.editFill,
          iconColor: AppColors.primary,
          title: 'Type expense',
          subtitle: 'Manually type in expense',
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            context.push(RouteNames.addExpense);
          },
        ),
        _AddOption(
          icon: AppIcons.wallet,
          iconColor: AppColors.categoryTransport,
          title: 'Account integration',
          subtitle: 'Integrate your account to Finclar',
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            showBankIntegrationModal(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: _FinclarBottomNav(
        currentIndex: currentIndex,
        onTap: (i) => i == 2 ? _onAddTap(context) : _onTabTap(context, i),
      ),
    );
  }
}

class _FinclarBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FinclarBottomNav({required this.currentIndex, required this.onTap});

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
                icon: AppIcons.expenses,
                activeIcon: AppIcons.expensesActive,
                label: AppStrings.expenses,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _AddButton(onTap: () => onTap(2)),
              _NavItem(
                icon: AppIcons.budget,
                activeIcon: AppIcons.budgetActive,
                label: AppStrings.budget,
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
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

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = context.textSecondary;

    return Expanded(
      child: InkWell(
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
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
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
    );
  }
}

class _AddOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _AddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? context.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    fontVariations: const [FontVariation('wght', 500)],
                    color: context.textPrimary,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    fontVariations: const [FontVariation('wght', 400)],
                    color: context.textSecondary,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
