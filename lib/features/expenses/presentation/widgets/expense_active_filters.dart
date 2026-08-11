import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/expense_filter.dart';
import '../../providers/expense_providers.dart';

/// Applied filters live in a sheet the user has already dismissed, so without
/// this row a filtered list just looks like missing data.
class ExpenseActiveFilters extends ConsumerWidget {
  final ExpenseFilter filter;
  final ValueChanged<ExpenseFilter> onChanged;
  final VoidCallback onClearAll;

  const ExpenseActiveFilters({
    super.key,
    required this.filter,
    required this.onChanged,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!filter.isActive) return const SizedBox.shrink();

    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final categoryName = filter.categoryId == null
        ? null
        : categories
            .where((c) => c.id == filter.categoryId)
            .map((c) => c.name)
            .firstOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.base,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (filter.search != null && filter.search!.isNotEmpty)
            _ActiveChip(
              label: '"${filter.search}"',
              onRemove: () => onChanged(filter.copyWith(clearSearch: true)),
            ),
          if (filter.categoryId != null)
            _ActiveChip(
              label: categoryName ?? 'Category',
              onRemove: () => onChanged(filter.copyWith(clearCategory: true)),
            ),
          if (filter.hasDateRange)
            _ActiveChip(
              label: filter.dateLabel,
              onRemove: () => onChanged(filter.copyWith(clearDates: true)),
            ),
          if (filter.source != null)
            _ActiveChip(
              label: 'Source: ${ExpenseFilter.sourceLabel(filter.source!)}',
              onRemove: () => onChanged(filter.copyWith(clearSource: true)),
            ),
          if (filter.isSorted)
            _ActiveChip(
              label:
                  'Sort: ${ExpenseFilter.orderLabel(filter.orderBy, filter.orderDir)}',
              onRemove: () => onChanged(
                filter.copyWith(
                  orderBy: ExpenseFilter.defaultOrderBy,
                  orderDir: ExpenseFilter.defaultOrderDir,
                ),
              ),
            ),
          GestureDetector(
            onTap: onClearAll,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                'Clear all',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Remove filter $label',
      child: GestureDetector(
        onTap: onRemove,
        behavior: HitTestBehavior.opaque,
        // Visual chip stays 32; the padding lifts the tap area to 44.
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          height: 32,
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            borderRadius: AppRadius.radiusFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(AppIcons.close, size: 14, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
