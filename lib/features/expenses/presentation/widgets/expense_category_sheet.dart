import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../data/models/category_model.dart';
import '../../providers/category_color_sync_provider.dart';
import '../../providers/expense_providers.dart';
import 'expense_add_category_sheet.dart';
import 'expense_category_utils.dart';

Future<CategoryModel?> showExpenseCategorySheet(
  BuildContext context, {
  String? selectedId,
}) {
  return showAppSheet<CategoryModel>(
    context,
    title: 'Select category',
    children: [_CategoryContent(selectedId: selectedId)],
  );
}

class _CategoryContent extends ConsumerWidget {
  final String? selectedId;
  const _CategoryContent({this.selectedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final syncedColors = ref.watch(categoryColorSyncProvider).valueOrNull;

    return categoriesAsync.when(
      loading: () => Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          6,
          (_) => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                AppSkeleton.circle(size: 36),
                SizedBox(width: AppSpacing.md),
                AppSkeleton.text(width: 120),
              ],
            ),
          ),
        ),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: GestureDetector(
          onTap: () => ref.invalidate(categoriesProvider),
          child: Center(
            child: Text(
              'Failed to load categories. Tap to retry.',
              style: AppTypography.bodyMedium
                  .copyWith(color: context.textSecondary),
            ),
          ),
        ),
      ),
      data: (categories) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...categories.map((cat) {
          final isSelected = selectedId == cat.id;
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(cat),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: categoryBgColorFor(
                        name: cat.name,
                        icon: cat.icon,
                        categoryId: cat.id,
                        syncedColors: syncedColors,
                      ),
                      borderRadius: AppRadius.radiusCard,
                    ),
                    child: Icon(
                      categoryIconFor(name: cat.name, icon: cat.icon),
                      size: 18,
                      color: categoryColorFor(
                        name: cat.name,
                        icon: cat.icon,
                        categoryId: cat.id,
                        syncedColors: syncedColors,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      cat.name,
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
          }),
          const SizedBox(height: AppSpacing.sm),
          _AddCategoryButton(
            onCreated: (created) => Navigator.of(context).pop(created),
          ),
        ],
      ),
    );
  }
}

class _AddCategoryButton extends StatelessWidget {
  final ValueChanged<CategoryModel> onCreated;
  const _AddCategoryButton({required this.onCreated});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final created = await showExpenseAddCategorySheet(context);
        if (created != null && context.mounted) onCreated(created);
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: AppRadius.radiusFull,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.addCircle, size: 18, color: context.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Add category',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
                fontSize: 14,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
