import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/expense_model.dart';
import 'expense_category_sheet.dart';
import 'expense_date_sheet.dart';
import 'expense_note_sheet.dart';

Future<ExpenseModel?> showEditExpenseSheet(
  BuildContext context, {
  ExpenseModel? expense,
}) {
  return showAppSheet<ExpenseModel>(
    context,
    title: expense == null ? 'Add expense' : 'Edit expense',
    avoidKeyboard: true,
    children: [_EditExpenseContent(expense: expense)],
  );
}

class _EditExpenseContent extends StatefulWidget {
  final ExpenseModel? expense;
  const _EditExpenseContent({this.expense});

  @override
  State<_EditExpenseContent> createState() => _EditExpenseContentState();
}

class _EditExpenseContentState extends State<_EditExpenseContent> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _merchantCtrl;
  String? _category;
  String? _note;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl = TextEditingController(
      text: e != null ? e.amount.toStringAsFixed(2) : '',
    );
    _merchantCtrl = TextEditingController(text: e?.merchant ?? '');
    _category = e?.category;
    _note = e?.note;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _merchantCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _amountCtrl.text.trim().isNotEmpty &&
      _category != null;

  Future<void> _pickCategory() async {
    final result = await showExpenseCategorySheet(
      context,
      selected: _category,
    );
    if (result != null) setState(() => _category = result);
  }

  Future<void> _pickDate() async {
    final result = await showExpenseDateSheet(context, initial: _date);
    if (result != null) setState(() => _date = result);
  }

  Future<void> _pickNote() async {
    final result = await showExpenseNoteSheet(context, initial: _note);
    if (result != null) setState(() => _note = result);
  }

  void _onSave() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final result = ExpenseModel(
      id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      amount: amount,
      category: _category!,
      merchant: _merchantCtrl.text.trim().isEmpty ? null : _merchantCtrl.text.trim(),
      note: _note,
      date: _date,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_nameCtrl, _amountCtrl, _merchantCtrl]),
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Name',
              hint: 'Enter expense name',
              controller: _nameCtrl,
            ),
            const SizedBox(height: AppSpacing.base),
            AppTextField(
              label: 'Amount',
              hint: '0.00',
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.base),
            _SelectRow(
              label: 'Category',
              value: _category ?? 'Select category',
              onTap: _pickCategory,
            ),
            const SizedBox(height: AppSpacing.base),
            AppTextField(
              label: 'Merchant',
              hint: 'Enter merchant name',
              controller: _merchantCtrl,
            ),
            const SizedBox(height: AppSpacing.base),
            _SelectRow(
              label: 'Date',
              value: DateFormat('MMM d, yyyy').format(_date),
              onTap: _pickDate,
            ),
            const SizedBox(height: AppSpacing.base),
            _SelectRow(
              label: 'Note',
              value: _note ?? 'Add a note',
              onTap: _pickNote,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: widget.expense == null ? 'Save' : 'Save changes',
              onTap: _isValid ? _onSave : null,
              height: 48,
            ),
          ],
        );
      },
    );
  }
}

class _SelectRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _SelectRow({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
