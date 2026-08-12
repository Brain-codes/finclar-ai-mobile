import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../settings/presentation/widgets/avatar_color_row.dart';
import '../../data/models/category_model.dart';
import '../../providers/expense_providers.dart';
import 'expense_category_utils.dart';

Future<CategoryModel?> showExpenseAddCategorySheet(BuildContext context) {
  return showAppSheet<CategoryModel>(
    context,
    title: 'Add category',
    avoidKeyboard: true,
    children: [const _AddCategoryContent()],
  );
}

class _AddCategoryContent extends ConsumerStatefulWidget {
  const _AddCategoryContent();

  @override
  ConsumerState<_AddCategoryContent> createState() => _AddCategoryContentState();
}

class _AddCategoryContentState extends ConsumerState<_AddCategoryContent> {
  final _nameController = TextEditingController();
  String? _selectedIconKey;
  Color _selectedColor = AppColors.categoryPalette.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canCreate =>
      _nameController.text.trim().isNotEmpty && !_isSubmitting;

  Future<void> _onCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      // Pack icon + color into the single `icon` string field the backend
      // stores (same one-field-custom-encoding pattern as `profile_icon` for
      // avatars). Older categories only ever had a bare icon key here —
      // `decodeCategoryIcon` still reads those fine, they just have no color.
      final iconValue = _selectedIconKey != null
          ? encodeCategoryIcon(_selectedIconKey!, _selectedColor)
          : null;
      final created = await ref
          .read(expenseRepositoryProvider)
          .createCategory(name: name, icon: iconValue);
      ref.invalidate(categoriesProvider);
      ref.invalidate(categoryPageProvider);
      if (mounted) Navigator.of(context, rootNavigator: true).pop(created);
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackbar.error(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon picker
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.radiusSheet,
            border: Border.all(color: context.borderColor),
          ),
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Icon',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                children: categoryPickerIcons.map((entry) {
                  final key = entry.$1;
                  final icon = categoryIconFromString(key);
                  final isSelected = _selectedIconKey == key;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedIconKey = isSelected ? null : key;
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor
                            : context.surfaceVariant,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? null
                            : Border.all(color: context.borderColor),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isSelected
                            ? AppColors.white
                            : context.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.radiusSheet,
            border: Border.all(color: context.borderColor),
          ),
          padding: const EdgeInsets.all(AppSpacing.base),
          child: AvatarColorRow(
            label: 'Color',
            colors: AppColors.categoryPalette,
            selected: _selectedColor,
            onSelectedChanged: (color) => setState(() => _selectedColor = color),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        AppTextField(
          label: 'Category name',
          hint: 'Enter category name',
          controller: _nameController,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: GestureDetector(
            onTap: _canCreate ? _onCreate : null,
            child: Container(
              decoration: BoxDecoration(
                color: _canCreate ? AppColors.primary : context.surfaceVariant,
                borderRadius: AppRadius.radiusFull,
              ),
              alignment: Alignment.center,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
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
