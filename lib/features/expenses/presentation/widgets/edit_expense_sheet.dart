import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_attach_receipt_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';
import '../../providers/expense_providers.dart';
import 'expense_category_sheet.dart';
import 'expense_date_sheet.dart';

Future<ExpenseModel?> showEditExpenseSheet(
  BuildContext context, {
  ExpenseModel? expense,
  bool hasItems = false,
}) {
  return showAppSheet<ExpenseModel>(
    context,
    title: expense == null ? 'Add expense' : 'Edit expense',
    avoidKeyboard: true,
    children: [_EditExpenseContent(expense: expense, hasItems: hasItems)],
  );
}

class _EditExpenseContent extends ConsumerStatefulWidget {
  final ExpenseModel? expense;
  final bool hasItems;
  const _EditExpenseContent({this.expense, this.hasItems = false});

  @override
  ConsumerState<_EditExpenseContent> createState() =>
      _EditExpenseContentState();
}

class _EditExpenseContentState extends ConsumerState<_EditExpenseContent> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  CategoryModel? _category;
  late DateTime _date;
  bool _isSaving = false;
  bool _applyCategoryToItems = false;
  File? _receipt;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _nameCtrl = TextEditingController(text: e?.description ?? '');
    _amountCtrl = TextEditingController(
      text: e != null ? formatAmountInput(e.amount) : '',
    );
    if (e != null && e.categoryId != null) {
      _category = CategoryModel(id: e.categoryId!, name: e.category);
    }
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _amountCtrl.text.trim().isNotEmpty &&
      parseAmountInput(_amountCtrl.text) > 0 &&
      _category != null;

  /// Hidden once an expense is already verified — there's nothing to prove.
  bool get _showReceiptField =>
      widget.expense?.verificationLevel != ExpenseVerificationLevel.verified;

  String get _receiptHelper => widget.expense == null
      ? 'Optional. Attaching one verifies the amount automatically.'
      : widget.expense!.evidenceSuggested
      ? 'This is a large self-reported expense — attach proof to verify it.'
      : 'Optional. Attaching one marks this expense verified.';

  Future<void> _pickCategory() async {
    final result = await showExpenseCategorySheet(
      context,
      selectedId: _category?.id,
    );
    if (result != null) setState(() => _category = result);
  }

  Future<void> _pickDate() async {
    final result = await showExpenseDateSheet(context, initial: _date);
    if (result != null) setState(() => _date = result);
  }

  Future<void> _onSave() async {
    if (!_isValid || _isSaving) return;
    setState(() => _isSaving = true);
    final amount = parseAmountInput(_amountCtrl.text);
    final description = _nameCtrl.text.trim();
    final notifier = ref.read(expenseListProvider.notifier);
    try {
      final ExpenseModel result;
      if (widget.expense == null) {
        result = await notifier.create(
          amount: amount,
          description: description.isEmpty ? null : description,
          categoryIds: [_category!.id],
          expenseDate: _date,
          receipt: _receipt,
        );
      } else {
        // Cascading the category onto line items rides along in the same PATCH
        // — the backend accepts `items` on UpdateExpenseDto.
        final itemUpdates = (widget.hasItems && _applyCategoryToItems)
            ? [
                for (final item in widget.expense!.items)
                  if (item.id != null)
                    ExpenseItemUpdate(id: item.id!, categoryId: _category!.id),
              ]
            : null;
        result = await notifier.edit(
          widget.expense!.id,
          amount: amount,
          description: description,
          categoryIds: [_category!.id],
          expenseDate: _date,
          items: itemUpdates,
          receipt: _receipt,
        );
      }
      if (mounted) Navigator.of(context).pop(result);
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackbar.error(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_nameCtrl, _amountCtrl]),
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Description',
              hint: 'What was this expense for?',
              controller: _nameCtrl,
            ),
            const SizedBox(height: AppSpacing.base),
            AppTextField(
              label: 'Amount',
              hint: '0.00',
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [CurrencyInputFormatter()],
            ),
            const SizedBox(height: AppSpacing.base),
            _SelectRow(
              label: 'Category',
              value: _category?.name ?? 'Select category',
              isPlaceholder: _category == null,
              onTap: _pickCategory,
            ),
            if (widget.hasItems) ...[
              const SizedBox(height: AppSpacing.md),
              _ApplyToItemsCheckbox(
                value: _applyCategoryToItems,
                onChanged: (v) => setState(() => _applyCategoryToItems = v),
              ),
            ],
            const SizedBox(height: AppSpacing.base),
            _SelectRow(
              label: 'Date',
              value: DateFormat('MMM d, yyyy').format(_date),
              onTap: _pickDate,
            ),
            if (_showReceiptField) ...[
              const SizedBox(height: AppSpacing.base),
              AppAttachReceiptField(
                file: _receipt,
                onChanged: (f) => setState(() => _receipt = f),
                helperText: _receiptHelper,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: widget.expense == null ? 'Save' : 'Save changes',
              onTap: _isValid ? _onSave : null,
              isLoading: _isSaving,
              height: 48,
            ),
          ],
        );
      },
    );
  }
}

class _ApplyToItemsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ApplyToItemsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : context.inputFill,
              borderRadius: AppRadius.radiusXs,
              border: Border.all(
                color: value ? AppColors.primary : context.inputBorder,
              ),
            ),
            child: value
                ? const Icon(AppIcons.check, size: 14, color: AppColors.white)
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Apply this category to all items in this expense',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPlaceholder;
  final VoidCallback onTap;
  const _SelectRow({
    required this.label,
    required this.value,
    this.isPlaceholder = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            decoration: BoxDecoration(
              color: context.inputFill,
              border: Border.all(color: context.inputBorder),
              borderRadius: AppRadius.radiusInput,
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color:
                    isPlaceholder ? context.inputPlaceholder : context.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
