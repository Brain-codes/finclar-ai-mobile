import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/expenses/presentation/widgets/bank_integration_modal.dart';
import '../../features/expenses/presentation/widgets/edit_expense_sheet.dart';
import '../../features/gamification/presentation/widgets/streak_card_modal.dart';
import '../../features/home/providers/income_setup_provider.dart';
import '../icons/app_icons.dart';
import 'app_sheet.dart';

Future<void> _onTypeExpense(BuildContext context, WidgetRef ref) async {
  final created = await showEditExpenseSheet(context);
  if (created == null || !context.mounted) return;
  await maybeShowStreakModal(context, ref);
}

/// The single "Add" sheet with every way to log income/expenses — shared by
/// the shell's FAB and any other entry point that promises "multiple ways to
/// log an expense" instead of jumping straight to one of them.
///
/// [showIncomeOption] hides the income row for entry points that already have
/// their own dedicated income shortcut next to this one (e.g. the "Get set
/// up" checklist), so the sheet doesn't offer the same action twice.
void showAddOptionsSheet(
  BuildContext context,
  WidgetRef ref, {
  bool showIncomeOption = true,
}) {
  final hasIncome = ref.read(incomeProvider).valueOrNull != null;

  showAppSheet(
    context,
    title: 'Add',
    children: [
      if (showIncomeOption)
        _AddOption(
          icon: AppIcons.income,
          iconColor: AppColors.success,
          title: hasIncome ? 'Update income' : 'Add income',
          subtitle:
              hasIncome ? 'Change what you earn' : 'Tell Clara what you earn',
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            context.push(RouteNames.incomeSetup);
          },
        ),
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
          _onTypeExpense(context, ref);
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
