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
    heightFactor: 0.7,
    children: [_CategoryContent(selectedId: selectedId)],
    footer: const _AddCategoryButton(),
  );
}

class _CategoryContent extends ConsumerStatefulWidget {
  final String? selectedId;
  const _CategoryContent({this.selectedId});

  @override
  ConsumerState<_CategoryContent> createState() => _CategoryContentState();
}

class _CategoryContentState extends ConsumerState<_CategoryContent> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      ref.read(categoryPageProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryPageProvider);
    final syncedColors = ref.watch(categoryColorSyncProvider).valueOrNull;

    // The sheet's own scroll view is unbounded, so the paged list needs an
    // explicit height to scroll (and to report its extent) on its own.
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: categoriesAsync.when(
        loading: () => const _CategorySkeletonList(),
        error: (_, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: GestureDetector(
            onTap: () => ref.invalidate(categoryPageProvider),
            child: Center(
              child: Text(
                'Failed to load categories. Tap to retry.',
                style: AppTypography.bodyMedium
                    .copyWith(color: context.textSecondary),
              ),
            ),
          ),
        ),
        data: (state) => ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          itemCount: state.items.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  children: [
                    AppSkeleton.circle(size: 36),
                    SizedBox(width: AppSpacing.md),
                    AppSkeleton.text(width: 120),
                  ],
                ),
              );
            }
            final cat = state.items[index];
            return _CategoryRow(
              category: cat,
              isSelected: widget.selectedId == cat.id,
              syncedColors: syncedColors,
              onTap: () => Navigator.of(context).pop(cat),
            );
          },
        ),
      ),
    );
  }
}

class _CategorySkeletonList extends StatelessWidget {
  const _CategorySkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: List.generate(
        8,
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
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final Map<String, Color>? syncedColors;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.category,
    required this.isSelected,
    required this.syncedColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  name: category.name,
                  icon: category.icon,
                  categoryId: category.id,
                  syncedColors: syncedColors,
                ),
                borderRadius: AppRadius.radiusCard,
              ),
              child: Icon(
                categoryIconFor(name: category.name, icon: category.icon),
                size: 18,
                color: categoryColorFor(
                  name: category.name,
                  icon: category.icon,
                  categoryId: category.id,
                  syncedColors: syncedColors,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                category.name,
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
  }
}

class _AddCategoryButton extends StatelessWidget {
  const _AddCategoryButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final created = await showExpenseAddCategorySheet(context);
        if (created != null && context.mounted) {
          Navigator.of(context).pop(created);
        }
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
