import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';

const _categories = [
  ('Food', AppIcons.categoryFood, AppColors.categoryFood),
  ('Transport', AppIcons.categoryTransport, AppColors.categoryTransport),
  ('Health', AppIcons.categoryHealth, AppColors.categoryHealth),
  ('Shopping', AppIcons.categoryShopping, AppColors.categoryShopping),
  ('Entertainment', AppIcons.wallet, AppColors.primary),
  ('Bills', AppIcons.wallet, AppColors.categoryTransport),
  ('Education', AppIcons.wallet, AppColors.categoryHealth),
  ('Others', AppIcons.wallet, AppColors.textSecondary),
];

Future<String?> showExpenseCategorySheet(
  BuildContext context, {
  String? selected,
}) {
  return showAppSheet<String>(
    context,
    title: 'Select category',
    children: [_CategoryContent(selected: selected)],
  );
}

class _CategoryContent extends StatelessWidget {
  final String? selected;
  const _CategoryContent({this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _categories.map((cat) {
        final (name, icon, color) = cat;
        final isSelected = selected == name;
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(name),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _bgColor(name),
                    borderRadius: AppRadius.radiusCard,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    name,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(AppIcons.check, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

Color _bgColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return AppColors.categoryFoodBg;
    case 'transport':
      return AppColors.categoryTransportBg;
    case 'health':
      return AppColors.categoryHealthBg;
    case 'shopping':
      return AppColors.categoryShoppingBg;
    default:
      return AppColors.primaryMuted;
  }
}
