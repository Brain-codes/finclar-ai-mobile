import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

class ExpenseHeader extends StatelessWidget {
  final VoidCallback onFilter;
  const ExpenseHeader({super.key, required this.onFilter});

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
          GestureDetector(
            onTap: onFilter,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: context.borderColor),
              ),
              child: Icon(
                AppIcons.filter,
                size: 20,
                color: context.textQuaternary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
