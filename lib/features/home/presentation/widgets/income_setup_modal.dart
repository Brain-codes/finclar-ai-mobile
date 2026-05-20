import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

Future<void> showIncomeSetupModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: const Color(0xFFEFEFED).withValues(alpha: 0.67),
    barrierDismissible: false,
    builder: (_) => const _IncomeSetupModal(),
  );
}

class _IncomeSetupModal extends StatelessWidget {
  const _IncomeSetupModal();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xxxl,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CloseRow(onClose: () => Navigator.of(context).pop()),
            const SizedBox(height: AppSpacing.base),
            const _Header(),
            const SizedBox(height: AppSpacing.xl),
            const _FeatureList(),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: AppStrings.addIncome,
              onTap: () {
                Navigator.of(context).pop();
                context.push(RouteNames.incomeSetup);
              },
              fullWidth: false,
              height: 48,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ─── Close row ───────────────────────────────────────────────────────────────

class _CloseRow extends StatelessWidget {
  final VoidCallback onClose;
  const _CloseRow({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(AppIcons.close, size: 16, color: context.textSecondary),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('🚀', style: TextStyle(fontSize: 64)),
        const SizedBox(height: AppSpacing.base),
        Text(
          AppStrings.connectYourAccount,
          style: AppTypography.headingSmall.copyWith(
            fontVariations: const [FontVariation('wght', 600)],
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.connectSubtitle,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Feature list ────────────────────────────────────────────────────────────

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    const items = [
      (AppIcons.income, AppStrings.addYourIncome, AppStrings.addIncomeDesc),
      (AppIcons.expenses, AppStrings.addYourExpenses, AppStrings.addExpensesDesc),
      (AppIcons.budget, AppStrings.addYourBudget, AppStrings.addBudgetDesc),
      (AppIcons.notification, AppStrings.turnOnReminders, AppStrings.remindersDesc),
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _FeatureRow(
            icon: items[i].$1,
            title: items[i].$2,
            description: items[i].$3,
          ),
          if (i < items.length - 1)
            Divider(
              height: AppSpacing.base,
              thickness: 1,
              color: AppColors.border,
            ),
        ],
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusCard,
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Icon(icon, size: 20, color: context.textQuaternary),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: context.textQuaternary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
