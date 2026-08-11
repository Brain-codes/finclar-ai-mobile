import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter, TextEditingValue;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../expenses/data/models/category_model.dart';
import '../../../expenses/presentation/widgets/expense_category_utils.dart';
import '../../../expenses/providers/category_color_sync_provider.dart';
import '../../data/models/budget_model.dart';
import 'budget_category_sheet.dart';

/// Small icon badge for a category row. A plain [Consumer] rather than
/// converting the whole sheet to Riverpod — it just needs the background
/// color backfill for categories created before the icon+color encoding.
class _CategoryIconBadge extends StatelessWidget {
  final CategoryModel category;
  const _CategoryIconBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final syncedColors = ref.watch(categoryColorSyncProvider).valueOrNull;
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: categoryBgColorFor(
              name: category.name,
              icon: category.icon,
              categoryId: category.id,
              syncedColors: syncedColors,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            categoryIconFor(name: category.name, icon: category.icon),
            size: 12,
            color: categoryColorFor(
              name: category.name,
              icon: category.icon,
              categoryId: category.id,
              syncedColors: syncedColors,
            ),
          ),
        );
      },
    );
  }
}

/// [onSubmit] — called with the chosen category id and amount; must throw on failure.
/// [onRemove] — called when the user taps "Remove allocation" in edit mode; must throw on failure.
Future<void> showBudgetAllocationSheet(
  BuildContext context, {
  required double amountLeft,
  required double budgetTotal,
  required String currencySymbol,
  AllocationModel? existing,
  required Future<void> Function(String categoryId, double amount) onSubmit,
  Future<void> Function()? onRemove,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSheetTop),
    builder: (_) => _AllocationSheet(
      amountLeft: amountLeft,
      budgetTotal: budgetTotal,
      currencySymbol: currencySymbol,
      existing: existing,
      onSubmit: onSubmit,
      onRemove: onRemove,
    ),
  );
}

class _AllocationSheet extends StatefulWidget {
  final double amountLeft;
  final double budgetTotal;
  final String currencySymbol;
  final AllocationModel? existing;
  final Future<void> Function(String categoryId, double amount) onSubmit;
  final Future<void> Function()? onRemove;

  const _AllocationSheet({
    required this.amountLeft,
    required this.budgetTotal,
    required this.currencySymbol,
    required this.onSubmit,
    this.existing,
    this.onRemove,
  });

  @override
  State<_AllocationSheet> createState() => _AllocationSheetState();
}

class _AllocationSheetState extends State<_AllocationSheet> {
  CategoryModel? _category;
  final _amountController = TextEditingController();
  bool _isSubmitting = false;
  bool _isRemoving = false;

  bool get _isEditMode => widget.existing != null;

  double? get _parsedAmount =>
      double.tryParse(_amountController.text.replaceAll(',', '').trim());

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final e = widget.existing!;
      _category = CategoryModel(
        id: e.categoryId,
        name: e.categoryName,
        icon: e.categoryIcon,
      );
      _amountController.text = _fmtNum(e.amountAllocated);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _exceedsBalance {
    final amount = _parsedAmount;
    if (amount == null) return false;
    return amount > widget.amountLeft;
  }

  bool get _canContinue =>
      _category != null &&
      _parsedAmount != null &&
      !_exceedsBalance &&
      !_isSubmitting &&
      !_isRemoving;

  String _pctLabel() {
    final amount = _parsedAmount;
    if (amount == null || widget.budgetTotal <= 0) return '';
    if (_exceedsBalance) return 'Amount exceeds allocation balance';
    final pct = (amount / widget.budgetTotal * 100).clamp(0, 100);
    return '${pct.toStringAsFixed(0)}% of total budget';
  }

  Future<void> _onContinue() async {
    final amount = _parsedAmount;
    final category = _category;
    if (category == null || amount == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(category.id, amount);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackbar.error(context, e.toString());
      }
    }
  }

  Future<void> _onRemove() async {
    if (widget.onRemove == null || _isRemoving) return;
    setState(() => _isRemoving = true);
    try {
      await widget.onRemove!();
      if (mounted) {
        AppSnackbar.success(context, 'Allocation removed');
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRemoving = false);
        AppSnackbar.error(context, e.toString());
      }
    }
  }

  String _fmtNum(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _fmt(double v) => _fmtNum(v);

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final pctLabel = _pctLabel();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xl,
        AppSpacing.screenPadding,
        AppSpacing.xxxl + keyboardHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.currencySymbol}${_fmt(widget.amountLeft)}',
                      style: AppTypography.headingMedium.copyWith(
                        color: context.textPrimary,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      _isEditMode ? 'Editing allocation' : 'Amount left to allocate',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.borderStrong),
                  ),
                  child: Icon(AppIcons.close, size: 14, color: context.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Category',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // In edit mode the category is locked — show it as a static row
          if (_isEditMode)
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                borderRadius: AppRadius.radiusInput,
                border: Border.all(color: context.inputBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Row(
                children: [
                  _CategoryIconBadge(category: _category!),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _category!.name,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () async {
                final result = await showBudgetCategorySheet(
                  context,
                  selected: _category,
                );
                if (result != null) setState(() => _category = result);
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: AppRadius.radiusInput,
                  border: Border.all(
                    color: _category != null
                        ? context.borderStrong
                        : context.inputBorder,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Row(
                  children: [
                    if (_category != null) ...[
                      _CategoryIconBadge(category: _category!),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Text(
                        _category?.name ?? 'Select category',
                        style: AppTypography.bodyMedium.copyWith(
                          color: _category != null
                              ? context.textPrimary
                              : context.inputPlaceholder,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(AppIcons.chevronRight, size: 16, color: context.textSecondary),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Amount',
            hint: 'Enter amount',
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [_CommaAmountFormatter()],
            onChanged: (_) => setState(() {}),
          ),
          if (pctLabel.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              pctLabel,
              style: AppTypography.bodySmall.copyWith(
                color: _exceedsBalance ? AppColors.error : context.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: _isEditMode ? 'Update' : 'Continue',
            onTap: _canContinue ? _onContinue : null,
            isLoading: _isSubmitting,
            height: 48,
          ),
          if (_isEditMode) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: (!_isRemoving && !_isSubmitting) ? _onRemove : null,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isRemoving)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.error,
                        ),
                      )
                    else
                      Icon(AppIcons.delete, size: 16, color: AppColors.error),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Remove allocation',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.error,
                        fontSize: 14,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommaAmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final n = int.tryParse(digits);
    if (n == null) return oldValue;
    final formatted = n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
