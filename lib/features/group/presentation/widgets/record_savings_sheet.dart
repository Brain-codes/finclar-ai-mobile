import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_attach_receipt_field.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../providers/group_providers.dart';

final _numberFormat = NumberFormat('#,##0', 'en');

/// Records a savings contribution to [groupId]. Returns true on success.
Future<bool?> showRecordSavingsSheet(BuildContext context, String groupId) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _RecordSavingsSheet(groupId: groupId),
  );
}

class _RecordSavingsSheet extends ConsumerStatefulWidget {
  final String groupId;
  const _RecordSavingsSheet({required this.groupId});

  @override
  ConsumerState<_RecordSavingsSheet> createState() =>
      _RecordSavingsSheetState();
}

class _RecordSavingsSheetState extends ConsumerState<_RecordSavingsSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  File? _receipt;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String raw) {
    final digits = raw.replaceAll(',', '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      _amountController.value = const TextEditingValue(text: '');
      setState(() {});
      return;
    }
    final n = int.tryParse(digits) ?? 0;
    final formatted = _numberFormat.format(n);
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
  }

  double get _amount =>
      double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

  Future<void> _save() async {
    if (_amount <= 0 || _receipt == null) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(groupDetailProvider(widget.groupId).notifier).recordSavings(
            amount: _amount,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            receipt: _receipt,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      AppSnackbar.success(context, 'Savings recorded');
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackbar.error(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbol = ref.watch(currencySymbolProvider);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xl,
        AppSpacing.screenPadding,
        AppSpacing.lg + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Record savings',
                style: AppTypography.headingSmall.copyWith(
                  color: context.textPrimary,
                  fontFamily: AppFonts.display,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.borderStrong),
                  ),
                  child: Icon(AppIcons.close,
                      size: 16, color: context.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Amount',
            hint: 'Enter amount',
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: _onAmountChanged,
            prefixText: '$symbol ',
            prefixStyle:
                AppTypography.bodyMedium.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.base),
          AppTextField(
            label: 'Note (optional)',
            hint: 'Add a note',
            controller: _noteController,
          ),
          const SizedBox(height: AppSpacing.base),
          AppAttachReceiptField(
            file: _receipt,
            onChanged: (f) => setState(() => _receipt = f),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Save',
            onTap: _amount > 0 && _receipt != null ? _save : null,
            isLoading: _isSaving,
            height: 52,
          ),
        ],
      ),
    );
  }
}
