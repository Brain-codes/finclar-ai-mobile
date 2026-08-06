import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Asks what to save this Friday. The amount is per-Friday, so [initialAmount]
/// is only a suggestion — the user is free to save more or less than last week.
Future<double?> showChallengeAmountSheet(
  BuildContext context, {
  double? initialAmount,
}) {
  return showAppSheet<double>(
    context,
    title: 'Enter amount',
    avoidKeyboard: true,
    children: [_ChallengeAmountForm(initialAmount: initialAmount)],
  );
}

class _ChallengeAmountForm extends ConsumerStatefulWidget {
  final double? initialAmount;
  const _ChallengeAmountForm({this.initialAmount});

  @override
  ConsumerState<_ChallengeAmountForm> createState() =>
      _ChallengeAmountFormState();
}

class _ChallengeAmountFormState extends ConsumerState<_ChallengeAmountForm> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialAmount == null
          ? ''
          : formatAmountInput(widget.initialAmount!),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = ref.watch(currencySymbolProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          label: 'Amount',
          hint: 'Enter amount',
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [CurrencyInputFormatter()],
          prefixText: '$symbol ',
          prefixStyle: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.xl),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            final amount = parseAmountInput(value.text);
            return AppButton(
              label: 'Done',
              onTap: amount > 0
                  ? () => Navigator.of(context).pop(amount)
                  : null,
              height: 52,
            );
          },
        ),
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}
