import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_image_preview.dart';
import '../../../../shared/widgets/app_loading_overlay.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../gamification/presentation/widgets/streak_card_modal.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/scanned_receipt_model.dart';
import '../../providers/expense_providers.dart';
import '../widgets/delete_receipt_sheet.dart';
import '../widgets/edit_expense_sheet.dart';
import '../widgets/edit_scanned_item_sheet.dart';
import '../widgets/scanned_item_tile.dart';

class ScannedExpenseScreen extends ConsumerStatefulWidget {
  final ScannedReceiptModel receipt;

  const ScannedExpenseScreen({super.key, required this.receipt});

  @override
  ConsumerState<ScannedExpenseScreen> createState() =>
      _ScannedExpenseScreenState();
}

class _ScannedExpenseScreenState extends ConsumerState<ScannedExpenseScreen> {
  late ScannedReceiptModel _receipt;
  late double _originalTotal;
  late Map<String, ScannedItemModel> _originalItems;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _receipt = widget.receipt;
    _originalTotal = widget.receipt.totalAmount;
    _snapshotItems();
  }

  void _snapshotItems() {
    _originalItems = {
      for (final item in _receipt.items)
        if (item.serverId != null) item.serverId!: item,
    };
  }

  bool _itemChanged(ScannedItemModel item) {
    final original = _originalItems[item.serverId];
    if (original == null) return false;
    return original.name != item.name ||
        original.quantity != item.quantity ||
        (original.unitPrice - item.unitPrice).abs() > 0.001 ||
        original.categoryId != item.categoryId;
  }

  double get _total => _receipt.items.fold(0, (sum, item) => sum + item.amount);

  Future<void> _onEditItem(ScannedItemModel item) async {
    final updated = await showEditScannedItemSheet(context, item: item);
    if (updated == null) return;

    final items = _receipt.items
        .map((i) => i.id == updated.id ? updated : i)
        .toList();
    setState(() {
      _receipt = _receipt.copyWith(
        items: items,
        totalAmount: items.fold<double>(0.0, (s, i) => s + i.amount),
      );
    });
  }

  Future<void> _onEditExpense() async {
    final source = _receipt.sourceExpense;
    if (source == null) return;
    final result = await showEditExpenseSheet(
      context,
      expense: source,
      hasItems: source.items.isNotEmpty,
    );
    if (result == null || !mounted) return;

    // The PATCH response carries the authoritative item categories (the sheet
    // may have cascaded the parent category onto them). Merge just that field
    // back so any unsaved local name/qty/price edits survive.
    final serverItems = {
      for (final item in result.items)
        if (item.id != null) item.id!: item,
    };
    final mergedItems = [
      for (final item in _receipt.items)
        if (item.serverId != null && serverItems[item.serverId] != null)
          item.copyWith(categoryId: serverItems[item.serverId]!.categoryId)
        else
          item,
    ];

    setState(() {
      _receipt = _receipt.copyWith(
        merchantName: (result.description != null &&
                result.description!.trim().isNotEmpty)
            ? result.description
            : _receipt.merchantName,
        totalAmount: result.amount,
        items: mergedItems,
        sourceExpense: result,
      );
    });

    // Advance the baseline for category only — anything else the user changed
    // locally is still unsaved and must stay dirty for the Save button.
    _originalItems = {
      for (final entry in _originalItems.entries)
        entry.key: serverItems[entry.key] != null
            ? entry.value.copyWith(
                categoryId: serverItems[entry.key]!.categoryId,
              )
            : entry.value,
    };
  }

  Future<void> _onDelete() async {
    final confirmed = await showDeleteReceiptSheet(context);
    if (confirmed != true || !mounted) return;

    final expenseId = _receipt.expenseId;
    if (expenseId == null) {
      context.pop();
      return;
    }

    setState(() => _isDeleting = true);
    try {
      await ref.read(expenseListProvider.notifier).delete(expenseId);
      if (!mounted) return;
      AppSnackbar.success(context, 'Expense deleted');
      context.pop();
    } catch (e, st) {
      Log.e('[ScannedExpense] Failed to delete expense', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() => _isDeleting = false);
      AppSnackbar.error(
        context,
        e is AppException ? e.message : 'Could not delete expense',
      );
    }
  }

  Future<void> _onSave() async {
    final expenseId = _receipt.expenseId;
    final newTotal = _total;

    // Only items that came back from the backend carry a server id, and only
    // changed ones are worth sending.
    final itemUpdates = [
      for (final item in _receipt.items)
        if (item.serverId != null && _itemChanged(item))
          ExpenseItemUpdate(
            id: item.serverId!,
            name: item.name,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            categoryId: item.categoryId,
          ),
    ];
    final amountChanged = (newTotal - _originalTotal).abs() > 0.001;

    if (expenseId != null && (amountChanged || itemUpdates.isNotEmpty)) {
      setState(() => _isSaving = true);
      try {
        await ref.read(expenseListProvider.notifier).edit(
              expenseId,
              amount: amountChanged ? newTotal : null,
              items: itemUpdates.isEmpty ? null : itemUpdates,
            );
        _originalTotal = newTotal;
        _snapshotItems();
      } catch (e) {
        Log.e('[ScannedExpense] Failed to save expense changes', error: e);
        if (mounted) AppSnackbar.error(context, 'Failed to save changes');
        setState(() => _isSaving = false);
        return;
      }
      setState(() => _isSaving = false);
    }

    if (!mounted) return;
    // Celebrate before popping — once dismissed the snackbar lands on the
    // screen underneath.
    await maybeShowStreakModal(context, ref);
    if (!mounted) return;
    AppSnackbar.success(context, 'Expenses saved successfully');
    context.pop();
  }

  /// Items carry a `category_id`, not a name — resolve display names from the
  /// loaded category list so cascaded/edited categories actually show up.
  ScannedItemModel _withCategoryName(
    ScannedItemModel item,
    Map<String, String> names,
  ) {
    final resolved = names[item.categoryId];
    return resolved == null ? item : item.copyWith(category: resolved);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final categoryNames = {for (final c in categories) c.id: c.name};

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _ScannedTopBar(
                  title: _receipt.merchantName,
                  onBack: () => context.pop(),
                  onEdit: _receipt.sourceExpense != null ? _onEditExpense : null,
                  onDelete: _onDelete,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        _SummaryCard(total: _total),
                        const SizedBox(height: AppSpacing.md),
                        _ItemsCard(
                          receipt: _receipt,
                          resolveCategory: (item) =>
                              _withCategoryName(item, categoryNames),
                          onEditItem: _onEditItem,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                _SaveBar(onSave: _onSave, isLoading: _isSaving),
              ],
            ),
          ),
          if (_isDeleting) const AppLoadingOverlay(),
        ],
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _ScannedTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const _ScannedTopBar({
    required this.title,
    required this.onBack,
    this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.back,
                size: 20,
                color: context.textQuaternary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.labelLarge.copyWith(
                color: context.textPrimary,
                fontFamily: AppFonts.display,
              ),
            ),
          ),
          _TopBarActions(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _TopBarActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const _TopBarActions({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (onEdit == null) {
      return GestureDetector(
        onTap: onDelete,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.surfaceColor,
            shape: BoxShape.circle,
            border: Border.all(color: context.borderColor),
          ),
          child: Icon(AppIcons.delete, size: 20, color: context.textQuaternary),
        ),
      );
    }

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border.all(color: context.borderColor),
        borderRadius: AppRadius.radiusFull,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onEdit,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: context.borderColor)),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.edit, size: 16, color: context.textQuaternary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Edit',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textQuaternary,
                      fontSize: 14,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Icon(
                AppIcons.delete,
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

// ─── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double total;
  const _SummaryCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total expense',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              fontVariations: const [FontVariation('wght', 400)],
              color: context.textTertiary,
              height: 1.33,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatTotal(total),
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 24,
              fontVariations: const [FontVariation('wght', 500)],
              color: context.textQuaternary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _AiInsightRow(),
        ],
      ),
    );
  }

  String _formatTotal(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final buffer = StringBuffer('₦');
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    buffer.write('.${parts[1]}');
    return buffer.toString();
  }
}

class _AiInsightRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.claraGradient.createShader(bounds),
          child: const Icon(AppIcons.aiFill, size: 16, color: AppColors.white),
        ),
        const SizedBox(width: AppSpacing.xs),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.claraGradient.createShader(bounds),
          child: Text(
            'You spent 15% of your income.',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              fontVariations: const [FontVariation('wght', 500)],
              color: AppColors.white,
              height: 1.33,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Items card ───────────────────────────────────────────────────────────────

class _ItemsCard extends StatelessWidget {
  final ScannedReceiptModel receipt;
  final ScannedItemModel Function(ScannedItemModel) resolveCategory;
  final ValueChanged<ScannedItemModel> onEditItem;

  const _ItemsCard({
    required this.receipt,
    required this.resolveCategory,
    required this.onEditItem,
  });

  @override
  Widget build(BuildContext context) {
    final items = receipt.items;
    final File? imageFile = receipt.imagePath != null
        ? File(receipt.imagePath!)
        : null;

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
          // Receipt header tile
          _ReceiptHeaderTile(
            imageFile: imageFile,
            receiptUrl: receipt.receiptUrl,
            itemCount: items.length,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Item list
          ...List.generate(items.length * 2 - 1, (index) {
            if (index.isOdd) return const ScannedItemDivider();
            final item = resolveCategory(items[index ~/ 2]);
            return ScannedItemTile(item: item, onTap: () => onEditItem(item));
          }),
        ],
      ),
    );
  }
}

class _ReceiptHeaderTile extends StatelessWidget {
  final File? imageFile;
  final String? receiptUrl;
  final int itemCount;

  const _ReceiptHeaderTile({
    required this.imageFile,
    required this.receiptUrl,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageFile != null || (receiptUrl?.isNotEmpty ?? false);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.radiusCard,
      ),
      child: Row(
        children: [
          // Image thumbnail
          GestureDetector(
            onTap: hasImage
                ? () => showImagePreview(
                    context,
                    file: imageFile,
                    url: receiptUrl,
                  )
                : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageFile != null
                  ? Image.file(imageFile!, fit: BoxFit.cover)
                  : (receiptUrl?.isNotEmpty ?? false)
                  ? CachedNetworkImage(
                      imageUrl: receiptUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const AppSkeleton(
                        width: 44,
                        height: 44,
                      ),
                      errorWidget: (_, _, _) => Icon(
                        AppIcons.file,
                        size: 20,
                        color: context.textTertiary,
                      ),
                    )
                  : Icon(AppIcons.file, size: 20, color: context.textTertiary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment receipt',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  fontVariations: const [FontVariation('wght', 500)],
                  color: context.textQuaternary,
                  height: 1.33,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$itemCount items',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  fontVariations: const [FontVariation('wght', 400)],
                  color: context.textTertiary,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Save bar ─────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final VoidCallback onSave;
  final bool isLoading;
  const _SaveBar({required this.onSave, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom,
      ),
      color: context.surfaceColor,
      child: AppButton(label: 'Save', onTap: onSave, isLoading: isLoading),
    );
  }
}
