import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';

class ExpenseEmptyState extends StatelessWidget {
  /// When the month has expenses but the active filters match none of them, the
  /// "log your first expense" copy is wrong — say so and offer a way out.
  final VoidCallback? onClearFilters;

  const ExpenseEmptyState({super.key, this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.base,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusSheet,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/empty-expenses.png',
                width: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                onClearFilters != null
                    ? 'No matching expenses'
                    : 'No expenses yet',
                style: AppTypography.headingSmall.copyWith(
                  color: context.textPrimary,
                  fontSize: 20,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  onClearFilters != null
                      ? 'Nothing in this month matches your filters. Try widening them.'
                      : "You've not logged an expense yet. Tap on the plus button to log an expense",
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              if (onClearFilters != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Clear filters',
                  variant: AppButtonVariant.secondary,
                  fullWidth: false,
                  onTap: onClearFilters,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
