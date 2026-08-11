import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/expense_filter.dart';
import '../../providers/category_color_sync_provider.dart';
import '../../providers/expense_providers.dart';
import 'expense_category_utils.dart';
import 'expense_date_sheet.dart';
import 'expense_filter_option_sheet.dart';

/// The draft lives here rather than inside the content widget so the pinned
/// footer can read and commit it without the two being nested.
Future<ExpenseFilter?> showExpenseFilterSheet(
  BuildContext context, {
  required ExpenseFilter current,
}) {
  final draft = ValueNotifier<ExpenseFilter>(current);
  final searchController = TextEditingController(text: current.search ?? '');

  ExpenseFilter resolve() {
    final search = searchController.text.trim();
    return search.isEmpty
        ? draft.value.copyWith(clearSearch: true)
        : draft.value.copyWith(search: search);
  }

  return showAppSheet<ExpenseFilter>(
    context,
    title: 'Filter expenses',
    avoidKeyboard: true,
    children: [
      _FilterContent(draft: draft, searchController: searchController),
    ],
    footer: _FilterActions(
      draft: draft,
      searchController: searchController,
      resolve: resolve,
    ),
  ).whenComplete(() {
    draft.dispose();
    searchController.dispose();
  });
}

class _FilterContent extends ConsumerWidget {
  final ValueNotifier<ExpenseFilter> draft;
  final TextEditingController searchController;

  const _FilterContent({required this.draft, required this.searchController});

  Future<void> _pickCategory(BuildContext context, WidgetRef ref) async {
    final categories = ref.read(categoriesProvider).valueOrNull ?? const [];
    final syncedColors = ref.read(categoryColorSyncProvider).valueOrNull;
    final picked = await showFilterOptionSheet<String>(
      context,
      title: 'Category',
      selected: draft.value.categoryId,
      options: [
        const FilterOption(
          value: null,
          label: 'All categories',
          icon: AppIcons.categoryGrid,
        ),
        for (final category in categories)
          FilterOption(
            value: category.id,
            label: category.name,
            icon: categoryIconFor(name: category.name, icon: category.icon),
            iconColor: categoryColorFor(
              name: category.name,
              icon: category.icon,
              categoryId: category.id,
              syncedColors: syncedColors,
            ),
            iconBgColor: categoryBgColorFor(
              name: category.name,
              icon: category.icon,
              categoryId: category.id,
              syncedColors: syncedColors,
            ),
          ),
      ],
    );
    if (picked == null) return;
    draft.value = picked.value == null
        ? draft.value.copyWith(clearCategory: true)
        : draft.value.copyWith(categoryId: picked.value);
  }

  Future<void> _pickSource(BuildContext context) async {
    final picked = await showFilterOptionSheet<String>(
      context,
      title: 'Source',
      selected: draft.value.source,
      options: [
        const FilterOption(value: null, label: 'All sources'),
        for (final source in ExpenseFilter.sources)
          FilterOption(
            value: source,
            label: ExpenseFilter.sourceLabel(source),
          ),
      ],
    );
    if (picked == null) return;
    draft.value = picked.value == null
        ? draft.value.copyWith(clearSource: true)
        : draft.value.copyWith(source: picked.value);
  }

  /// The concrete dates are what's stored, so the tick has to be derived by
  /// matching them back against each preset.
  String? _activePreset() {
    final filter = draft.value;
    if (!filter.hasDateRange) return null;
    final now = DateTime.now();
    bool matches(DateTime start, DateTime end) =>
        filter.startDate == _dayStart(start) && filter.endDate == _dayEnd(end);

    if (matches(now.subtract(const Duration(days: 6)), now)) return 'last7';
    if (matches(now.subtract(const Duration(days: 29)), now)) return 'last30';
    if (matches(DateTime(now.year, 1, 1), now)) return 'year';
    return 'custom';
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showFilterOptionSheet<String>(
      context,
      title: 'Date range',
      selected: _activePreset(),
      options: const [
        FilterOption(value: null, label: 'Selected month'),
        FilterOption(value: 'last7', label: 'Last 7 days'),
        FilterOption(value: 'last30', label: 'Last 30 days'),
        FilterOption(value: 'year', label: 'This year'),
        FilterOption(value: 'custom', label: 'Custom range…'),
      ],
    );
    if (picked == null) return;

    switch (picked.value) {
      case null:
        draft.value = draft.value.copyWith(clearDates: true);
      case 'last7':
        _setRange(now.subtract(const Duration(days: 6)), now);
      case 'last30':
        _setRange(now.subtract(const Duration(days: 29)), now);
      case 'year':
        _setRange(DateTime(now.year, 1, 1), now);
      case 'custom':
        if (context.mounted) await _pickCustomRange(context);
    }
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final start = await showExpenseDateSheet(
      context,
      initial: draft.value.startDate ?? DateTime.now(),
      title: 'Start date',
      subtitle: 'Step 1 of 2 — the first day to include in the range.',
      doneLabel: 'Next',
    );
    if (start == null || !context.mounted) return;

    final end = await showExpenseDateSheet(
      context,
      initial: draft.value.endDate ?? start,
      title: 'End date',
      subtitle:
          'Step 2 of 2 — the last day to include, from ${DateFormat('d MMM yyyy').format(start)}.',
      doneLabel: 'Apply range',
    );
    if (end == null) return;

    // Tolerate a backwards pick rather than rejecting it — the user clearly
    // meant the span between the two dates.
    final ordered = end.isBefore(start) ? (end, start) : (start, end);
    _setRange(ordered.$1, ordered.$2);
  }

  void _setRange(DateTime start, DateTime end) {
    draft.value = draft.value.copyWith(
      startDate: _dayStart(start),
      endDate: _dayEnd(end),
    );
  }

  static DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _dayEnd(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59);

  Future<void> _pickSort(BuildContext context) async {
    final picked = await showFilterOptionSheet<String>(
      context,
      title: 'Sort by',
      selected: '${draft.value.orderBy}:${draft.value.orderDir}',
      options: [
        for (final (orderBy, orderDir) in ExpenseFilter.sortOptions)
          FilterOption(
            value: '$orderBy:$orderDir',
            label: ExpenseFilter.orderLabel(orderBy, orderDir),
          ),
      ],
    );
    if (picked?.value == null) return;
    final parts = picked!.value!.split(':');
    draft.value = draft.value.copyWith(orderBy: parts[0], orderDir: parts[1]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? const [];
    final syncedColors = ref.watch(categoryColorSyncProvider).valueOrNull;

    return ValueListenableBuilder<ExpenseFilter>(
      valueListenable: draft,
      builder: (context, filter, _) {
        final selectedCategory = filter.categoryId == null
            ? null
            : categories
                .where((c) => c.id == filter.categoryId)
                .firstOrNull;
        final categoryName = selectedCategory?.name;
        final categoryVisual = selectedCategory == null
            ? null
            : categoryVisualFor(
                name: selectedCategory.name,
                categoryId: selectedCategory.id,
                categoriesById: {for (final c in categories) c.id: c},
                syncedColors: syncedColors,
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Search',
              hint: 'Search by description',
              controller: searchController,
              textInputAction: TextInputAction.search,
              prefix: Icon(
                AppIcons.search,
                size: 18,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _FilterCard(
              children: [
                _FilterRow(
                  label: 'Category',
                  value: categoriesAsync.hasError
                      ? 'Tap to retry'
                      : categoryName ?? 'All categories',
                  isSet: filter.categoryId != null,
                  isLoading: categoriesAsync.isLoading,
                  leading: categoryVisual == null
                      ? null
                      : _CategoryDot(visual: categoryVisual),
                  onTap: categoriesAsync.hasError
                      ? () => ref.invalidate(categoriesProvider)
                      : () => _pickCategory(context, ref),
                ),
                const _RowDivider(),
                _FilterRow(
                  label: 'Date',
                  value: filter.dateLabel,
                  isSet: filter.hasDateRange,
                  onTap: () => _pickDate(context),
                ),
                const _RowDivider(),
                _FilterRow(
                  label: 'Source',
                  value: filter.source == null
                      ? 'All sources'
                      : ExpenseFilter.sourceLabel(filter.source!),
                  isSet: filter.source != null,
                  onTap: () => _pickSource(context),
                ),
                const _RowDivider(),
                _FilterRow(
                  label: 'Sort by',
                  value:
                      ExpenseFilter.orderLabel(filter.orderBy, filter.orderDir),
                  isSet: filter.isSorted,
                  onTap: () => _pickSort(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Filters apply within the month selected on the summary card.',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterCard extends StatelessWidget {
  final List<Widget> children;
  const _FilterCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusCard,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(children: children),
    );
  }
}

class _CategoryDot extends StatelessWidget {
  final CategoryVisual visual;
  const _CategoryDot({required this.visual});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: visual.bgColor,
        borderRadius: AppRadius.radiusXs,
      ),
      child: Icon(visual.icon, size: 14, color: visual.color),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: context.borderColor);
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final String value;

  /// Drives the accent — an untouched row reads as muted "All", a set one is
  /// the same orange as the header badge so both agree at a glance.
  final bool isSet;
  final bool isLoading;

  /// Sits immediately before the value — used for the selected category's icon.
  final Widget? leading;
  final VoidCallback onTap;

  const _FilterRow({
    required this.label,
    required this.value,
    required this.isSet,
    required this.onTap,
    this.isLoading = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, $value',
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.base,
          ),
          child: Row(
            children: [
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textPrimary,
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isLoading)
                      const AppSkeleton.text(width: 96)
                    else ...[
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Flexible(
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isSet
                                ? AppColors.primary
                                : context.textSecondary,
                            fontSize: 14,
                            fontVariations: [
                              FontVariation('wght', isSet ? 500 : 400),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      AppIcons.chevronRight,
                      size: 16,
                      color: context.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterActions extends StatelessWidget {
  final ValueNotifier<ExpenseFilter> draft;
  final TextEditingController searchController;
  final ExpenseFilter Function() resolve;

  const _FilterActions({
    required this.draft,
    required this.searchController,
    required this.resolve,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([draft, searchController]),
      builder: (context, _) {
        final canClear =
            draft.value.isActive || searchController.text.isNotEmpty;
        return Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Clear all',
                variant: AppButtonVariant.secondary,
                onTap: canClear
                    ? () {
                        searchController.clear();
                        draft.value = const ExpenseFilter();
                      }
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'Apply',
                onTap: () => Navigator.of(context).pop(resolve()),
              ),
            ),
          ],
        );
      },
    );
  }
}
