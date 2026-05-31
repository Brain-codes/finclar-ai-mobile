import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_text_field.dart';

Future<String?> showChallengeAmountSheet(BuildContext context) {
  return showAppSheet<String>(
    context,
    title: 'Enter amount',
    avoidKeyboard: true,
    children: [const _ChallengeAmountForm()],
  );
}

class _ChallengeAmountForm extends StatefulWidget {
  const _ChallengeAmountForm();

  @override
  State<_ChallengeAmountForm> createState() => _ChallengeAmountFormState();
}

class _ChallengeAmountFormState extends State<_ChallengeAmountForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDone() {
    final value = _controller.text.trim();
    Navigator.of(context).pop(value.isEmpty ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          label: 'Amount',
          hint: 'Enter email address',
          controller: _controller,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.xl),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            final hasValue = value.text.trim().isNotEmpty;
            return AppButton(
              label: 'Done',
              onTap: hasValue ? _onDone : null,
              height: 52,
            );
          },
        ),
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}
