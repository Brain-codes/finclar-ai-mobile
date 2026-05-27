import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/scanned_receipt_model.dart';
import 'expense_category_sheet.dart';

Future<ScannedItemModel?> showEditScannedItemSheet(
  BuildContext context, {
  required ScannedItemModel item,
}) {
  return showAppSheet<ScannedItemModel>(
    context,
    title: 'Edit expense',
    avoidKeyboard: true,
    heightFactor: 0.88,
    children: [_EditScannedItemContent(item: item)],
  );
}

class _EditScannedItemContent extends StatefulWidget {
  final ScannedItemModel item;
  const _EditScannedItemContent({required this.item});

  @override
  State<_EditScannedItemContent> createState() => _EditScannedItemContentState();
}

class _EditScannedItemContentState extends State<_EditScannedItemContent> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _quantityCtrl;
  late String _category;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _amountCtrl = TextEditingController(
      text: formatAmountInput(widget.item.unitPrice),
    );
    _quantityCtrl = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _category = widget.item.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final picked = await showExpenseCategorySheet(context, selected: _category);
    if (picked != null) setState(() => _category = picked);
  }

  void _onSave() {
    final qty = int.tryParse(_quantityCtrl.text.trim()) ?? widget.item.quantity;
    final unitPrice = parseAmountInput(
      _amountCtrl.text,
      fallback: widget.item.unitPrice,
    );

    final updated = widget.item.copyWith(
      name: _nameCtrl.text.trim().isEmpty ? widget.item.name : _nameCtrl.text.trim(),
      category: _category,
      quantity: qty,
      unitPrice: unitPrice,
      amount: unitPrice * qty,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          label: 'Name',
          hint: 'Item name',
          controller: _nameCtrl,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: 'Amount',
          hint: '0.00',
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          prefixText: '₦',
          inputFormatters: [CurrencyInputFormatter()],
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: 'Quantity',
          hint: '1',
          controller: _quantityCtrl,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.xl),
        GestureDetector(
          onTap: _pickCategory,
          child: AppTextField(
            label: 'Category',
            hint: 'Select category',
            controller: TextEditingController(text: _category),
            enabled: false,
            suffix: Icon(
              AppIcons.chevronDown,
              size: 18,
              color: context.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: 'Save changes', onTap: _onSave),
      ],
    );
  }
}
