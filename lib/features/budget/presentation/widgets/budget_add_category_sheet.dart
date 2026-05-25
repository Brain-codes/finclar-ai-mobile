import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_text_field.dart';

Future<void> showBudgetAddCategorySheet(BuildContext context) {
  return showAppSheet(
    context,
    title: 'Add category',
    avoidKeyboard: true,
    children: [const _AddCategoryContent()],
  );
}

class _AddCategoryContent extends StatefulWidget {
  const _AddCategoryContent();

  @override
  State<_AddCategoryContent> createState() => _AddCategoryContentState();
}

class _AddCategoryContentState extends State<_AddCategoryContent> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canCreate => _nameController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon picker circle + label
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.radiusSheet,
            border: Border.all(color: context.borderColor),
          ),
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.borderColor),
                ),
                child: Icon(AppIcons.addCircle, size: 24, color: context.textSecondary),
              ),
              const SizedBox(width: AppSpacing.base),
              Text(
                'Add an icon',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        AppTextField(
          label: 'Category',
          hint: 'Enter category name',
          controller: _nameController,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: GestureDetector(
            onTap: _canCreate ? () => Navigator.of(context).pop() : null,
            child: Container(
              decoration: BoxDecoration(
                color: _canCreate ? AppColors.primary : context.surfaceVariant,
                borderRadius: AppRadius.radiusFull,
              ),
              alignment: Alignment.center,
              child: Text(
                'Create',
                style: AppTypography.bodyMedium.copyWith(
                  color: _canCreate ? AppColors.white : context.textSecondary,
                  fontSize: 16,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
