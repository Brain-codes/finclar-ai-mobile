import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/widgets/app_attach_receipt_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../providers/challenge_providers.dart';
import 'challenge_success_modal.dart';

/// Logs a savings entry against [challengeId]. Returns true once recorded.
///
/// [weeklyTarget] only seeds the amount field — each Friday's amount is
/// independent, so the user can save more or less than the week before.
Future<bool?> showRecordChallengeEntrySheet(
  BuildContext context, {
  required String challengeId,
  double? weeklyTarget,
  String title = 'Log your savings',
}) {
  return showAppSheet<bool>(
    context,
    title: title,
    avoidKeyboard: true,
    children: [
      _RecordEntryForm(challengeId: challengeId, weeklyTarget: weeklyTarget),
    ],
  );
}

class _RecordEntryForm extends ConsumerStatefulWidget {
  final String challengeId;
  final double? weeklyTarget;

  const _RecordEntryForm({
    required this.challengeId,
    required this.weeklyTarget,
  });

  @override
  ConsumerState<_RecordEntryForm> createState() => _RecordEntryFormState();
}

class _RecordEntryFormState extends ConsumerState<_RecordEntryForm> {
  late final TextEditingController _amountController;
  final _noteController = TextEditingController();
  File? _receipt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.weeklyTarget == null
          ? ''
          : formatAmountInput(widget.weeklyTarget!),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _amount => parseAmountInput(_amountController.text);

  /// Fridays remaining in the current month, not counting today.
  int _fridaysLeftThisMonth() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    var count = 0;
    for (var day = now.day + 1; day <= lastDay; day++) {
      if (DateTime(now.year, now.month, day).weekday == DateTime.friday) {
        count++;
      }
    }
    return count;
  }

  String _successMessage() {
    final symbol = ref.read(currencySymbolProvider);
    final amount = formatCurrency(
      _amount,
      symbol,
      abbreviate: false,
      withCommas: true,
    );
    final month = DateFormat('MMMM').format(DateTime.now());
    final left = _fridaysLeftThisMonth();
    final tail = switch (left) {
      0 => "That's every Friday covered for $month.",
      1 => '1 more Friday to close out $month.',
      _ => '$left more Fridays to close out $month.',
    };
    return "You've saved $amount and kept your Friday streak alive. $tail";
  }

  Future<void> _save() async {
    if (_amount <= 0) return;
    setState(() => _isSaving = true);
    final note = _noteController.text.trim();
    try {
      await ref
          .read(challengesProvider.notifier)
          .recordEntry(
            widget.challengeId,
            amount: _amount,
            note: note.isEmpty ? null : note,
            receipt: _receipt,
          );
      if (!mounted) return;
      final navigator = Navigator.of(context);
      final message = _successMessage();
      navigator.pop(true);
      if (!mounted) return;
      await showChallengeSuccessModal(
        context,
        ChallengeSuccessType.fridaySavings,
        message: message,
      );
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Amount saved',
          hint: 'Enter amount',
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [CurrencyInputFormatter()],
          prefixText: '$symbol ',
          prefixStyle: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.base),
        AppTextField(
          label: 'Note (optional)',
          hint: 'What are you saving towards?',
          controller: _noteController,
        ),
        const SizedBox(height: AppSpacing.base),
        AppAttachReceiptField(
          file: _receipt,
          onChanged: (f) => setState(() => _receipt = f),
          label: 'Attach proof',
          attachedLabel: 'Proof attached',
          helperText:
              'Optional. Attaching proof marks this entry evidence-backed '
              'instead of self-reported.',
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Log savings',
          onTap: _amount > 0 ? _save : null,
          isLoading: _isSaving,
          height: 52,
        ),
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}
