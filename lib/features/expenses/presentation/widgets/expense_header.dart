import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

class ExpenseHeader extends StatelessWidget {
  final VoidCallback onFilter;

  /// Number of narrowing filters in play — drives the badge on the icon.
  final int activeFilterCount;

  const ExpenseHeader({
    super.key,
    required this.onFilter,
    this.activeFilterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.base,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Expense',
            style: AppTypography.headingMedium.copyWith(
              color: context.textPrimary,
              fontSize: 24,
            ),
          ),
          Semantics(
            button: true,
            label: activeFilterCount > 0
                ? 'Filter expenses, $activeFilterCount filters active'
                : 'Filter expenses',
            child: GestureDetector(
              onTap: onFilter,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: activeFilterCount > 0
                            ? AppColors.primaryMuted
                            : context.surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activeFilterCount > 0
                              ? AppColors.primary
                              : context.borderColor,
                        ),
                      ),
                      child: Icon(
                        AppIcons.filter,
                        size: 20,
                        color: activeFilterCount > 0
                            ? AppColors.primary
                            : context.textQuaternary,
                      ),
                    ),
                    // Count, not just a dot — colour alone shouldn't carry it.
                    if (activeFilterCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.scaffoldColor,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$activeFilterCount',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white,
                              fontSize: 10,
                              height: 1,
                              fontVariations: const [FontVariation('wght', 600)],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
