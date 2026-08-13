import 'package:finclar_ai/shared/icons/app_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../budget/data/models/budget_model.dart';
import '../../../budget/providers/budget_providers.dart';
import '../../../expenses/presentation/widgets/expense_category_utils.dart';
import '../../../expenses/providers/category_color_sync_provider.dart';

class BudgetCategory {
  final String name;
  final Color color;
  final double spent;
  final double total;

  const BudgetCategory({
    required this.name,
    required this.color,
    required this.spent,
    required this.total,
  });

  double get percentage => total > 0 ? (spent / total).clamp(0.0, 1.0) : 0;

  @override
  bool operator ==(Object other) =>
      other is BudgetCategory &&
      other.name == name &&
      other.spent == spent &&
      other.total == total;

  @override
  int get hashCode => Object.hash(name, spent, total);
}

class BudgetSection extends ConsumerWidget {
  final VoidCallback? onBreakdownTap;

  const BudgetSection({super.key, this.onBreakdownTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final budget = ref.watch(budgetProvider);
    final syncedColors = ref.watch(categoryColorSyncProvider).valueOrNull;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.budgetLabel,
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          budget.when(
            loading: () => const _BudgetSkeleton(),
            error: (_, _) => _empty(context),
            data: (s) => (s.budget == null || s.budget!.allocations.isEmpty)
                ? _empty(context)
                : _BudgetContent(
                    categories: _toCategories(s.budget!, syncedColors),
                    symbol: symbol,
                    onBreakdownTap: onBreakdownTap,
                  ),
          ),
        ],
      ),
    );
  }

  static List<BudgetCategory> _toCategories(
    BudgetModel b,
    Map<String, Color>? syncedColors,
  ) => b.allocations
      .map(
        (a) => BudgetCategory(
          name: a.categoryName,
          color: categoryColorFor(
            name: a.categoryName,
            icon: a.categoryIcon,
            categoryId: a.categoryId,
            syncedColors: syncedColors,
          ),
          spent: a.spent,
          total: a.amountAllocated,
        ),
      )
      .toList();

  Widget _empty(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.budget, size: 20, color: context.textSecondary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your budget will be listed here',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
}

const int _collapsedCategoryCount = 5;

class _BudgetContent extends StatefulWidget {
  final List<BudgetCategory> categories;
  final String symbol;
  final VoidCallback? onBreakdownTap;

  const _BudgetContent({
    required this.categories,
    required this.symbol,
    this.onBreakdownTap,
  });

  @override
  State<_BudgetContent> createState() => _BudgetContentState();
}

class _BudgetContentState extends State<_BudgetContent> {
  bool _expanded = false;
  BudgetCategory? _selected;

  void _toggleSelected(BudgetCategory category) {
    setState(() => _selected = _selected == category ? null : category);
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;
    final hasOverflow = categories.length > _collapsedCategoryCount;
    final visible = !hasOverflow || _expanded
        ? categories
        : categories.take(_collapsedCategoryCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BudgetDonutChart(
          categories: categories,
          symbol: widget.symbol,
          selected: _selected,
          onSectionTap: _toggleSelected,
        ),
        const SizedBox(height: AppSpacing.base),
        _AnimatedLegend(
          visible: visible,
          symbol: widget.symbol,
          selected: _selected,
          onTap: _toggleSelected,
        ),
        if (hasOverflow) ...[
          const SizedBox(height: AppSpacing.base),
          Divider(height: 1, color: context.borderColor),
          const SizedBox(height: AppSpacing.base),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _expanded
                      ? 'Show less'
                      : 'Show ${categories.length - _collapsedCategoryCount} more',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  _expanded ? AppIcons.chevronUp : AppIcons.chevronDown,
                  size: 16,
                  color: context.textSecondary,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.base),
        AppButton(
          label: AppStrings.seeBreakdown,
          onTap: widget.onBreakdownTap ?? () {},
          variant: AppButtonVariant.ghost,
          height: 44,
        ),
      ],
    );
  }
}

class _AnimatedLegend extends StatelessWidget {
  final List<BudgetCategory> visible;
  final String symbol;
  final BudgetCategory? selected;
  final ValueChanged<BudgetCategory> onTap;

  const _AnimatedLegend({
    required this.visible,
    required this.symbol,
    required this.selected,
    required this.onTap,
  });

  static const double _rowHeight = 52;

  @override
  Widget build(BuildContext context) {
    // Selected item floats to the top of the stack; everything else keeps
    // its original relative order beneath it.
    final ordered = [...visible];
    if (selected != null && ordered.contains(selected)) {
      ordered
        ..remove(selected)
        ..insert(0, selected!);
    }

    return AnimatedContainer(
      duration: AppConstants.animSlow,
      curve: Curves.easeInOutCubic,
      height: _rowHeight * visible.length,
      child: Stack(
        children: [
          for (final category in visible)
            AnimatedPositioned(
              key: ValueKey(category.name),
              duration: AppConstants.animSlow,
              curve: Curves.easeInOutCubic,
              top: ordered.indexOf(category) * _rowHeight,
              left: 0,
              right: 0,
              height: _rowHeight,
              child: _AnimatedLegendItem(
                category: category,
                symbol: symbol,
                selected: selected,
                showDivider: category != visible.last,
                onTap: () => onTap(category),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedLegendItem extends StatelessWidget {
  final BudgetCategory category;
  final String symbol;
  final BudgetCategory? selected;
  final bool showDivider;
  final VoidCallback onTap;

  const _AnimatedLegendItem({
    required this.category,
    required this.symbol,
    required this.selected,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == category;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            // The zoom happens on top of the reposition already handled by
            // the enclosing AnimatedPositioned, giving the "grow then glide
            // to the top" feel instead of a flat slide.
            child: AnimatedScale(
              duration: AppConstants.animBase,
              curve: isSelected ? Curves.easeOutBack : Curves.easeInOut,
              scale: isSelected ? 1.04 : 1.0,
              child: _BudgetItemRow(
                category: category,
                symbol: symbol,
                selected: selected,
                onTap: onTap,
              ),
            ),
          ),
        ),
        if (showDivider)
          AnimatedOpacity(
            duration: AppConstants.animBase,
            opacity: isSelected ? 0 : 1,
            child: Divider(height: 1, color: context.borderColor),
          ),
      ],
    );
  }
}

class _BudgetSkeleton extends StatelessWidget {
  const _BudgetSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppSkeleton.circle(size: 120),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                AppSkeleton.circle(size: 10),
                SizedBox(width: AppSpacing.xs),
                AppSkeleton.text(width: 90),
                Spacer(),
                AppSkeleton.text(width: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetDonutChart extends StatelessWidget {
  final List<BudgetCategory> categories;
  final String symbol;
  final BudgetCategory? selected;
  final ValueChanged<BudgetCategory> onSectionTap;

  const _BudgetDonutChart({
    required this.categories,
    required this.symbol,
    required this.selected,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedAmount = selected?.spent;
    final totalSpent = selectedAmount ??
        categories.fold<double>(0, (sum, c) => sum + c.spent);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final baseRingRadius = size * 0.18;
        final centerRadius = size * 0.28;

        final spentCategories =
            categories.where((c) => c.spent > 0).toList();

        final sections = spentCategories
            .map(
              (c) {
                final isSelected = selected == c;
                final isDimmed = selected != null && !isSelected;
                return PieChartSectionData(
                  color: isDimmed
                      ? c.color.withValues(alpha: 0.3)
                      : c.color,
                  value: c.spent,
                  title: '',
                  radius: isSelected
                      ? baseRingRadius * 1.15
                      : isDimmed
                          ? baseRingRadius * 0.8
                          : baseRingRadius,
                  showTitle: false,
                );
              },
            )
            .toList();

        if (sections.isEmpty) {
          sections.add(
            PieChartSectionData(
              color: context.borderColor,
              value: 1,
              title: '',
              radius: baseRingRadius,
              showTitle: false,
            ),
          );
        }

        return AspectRatio(
          aspectRatio: 1,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: centerRadius,
                  sections: sections,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    enabled: spentCategories.isNotEmpty,
                    touchCallback: (event, response) {
                      if (event is! FlTapUpEvent) return;
                      final index = response?.touchedSection?.touchedSectionIndex;
                      if (index == null || index < 0 ||
                          index >= spentCategories.length) {
                        return;
                      }
                      onSectionTap(spentCategories[index]);
                    },
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatAmount(totalSpent),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textPrimary,
                      fontVariations: const [FontVariation('wght', 600)],
                      fontSize: size * 0.045,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    selected != null ? selected!.name : 'spent',
                    style: AppTypography.labelXSmall.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '$symbol${(amount / 1000000).toStringAsFixed(1)}m';
    if (amount >= 1000) return '$symbol${(amount / 1000).toStringAsFixed(0)}k';
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}

class _BudgetItemRow extends StatelessWidget {
  final BudgetCategory category;
  final String symbol;
  final BudgetCategory? selected;
  final VoidCallback onTap;

  const _BudgetItemRow({
    required this.category,
    required this.symbol,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == category;
    final isDimmed = selected != null && !isSelected;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: AppConstants.animFast,
        opacity: isDimmed ? 0.4 : 1,
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? AppSpacing.xs : 0,
            vertical: isSelected ? 2 : 0,
          ),
          decoration: BoxDecoration(
            color: isSelected ? category.color.withValues(alpha: 0.08) : null,
            borderRadius: AppRadius.radiusXs,
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: AppRadius.radiusXs,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  category.name,
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected
                        ? context.textPrimary
                        : context.textSecondary,
                    fontVariations: isSelected
                        ? const [FontVariation('wght', 600)]
                        : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$symbol${_format(category.spent)} / $symbol${_format(category.total)}',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textPrimary,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(double v) => formatAmount(v);
}
