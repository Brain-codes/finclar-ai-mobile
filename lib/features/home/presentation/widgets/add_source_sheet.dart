import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_text_field.dart';

Future<String?> showAddSourceSheet(BuildContext context) {
  return showAppSheet<String>(
    context,
    title: 'Add a source',
    avoidKeyboard: true,
    children: [const _AddSourceContent()],
  );
}

class _AddSourceContent extends StatefulWidget {
  const _AddSourceContent();

  @override
  State<_AddSourceContent> createState() => _AddSourceContentState();
}

class _AddSourceContentState extends State<_AddSourceContent> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => setState(() => _hasText = _controller.text.trim().isNotEmpty),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Source',
          controller: _controller,
          hint: 'e.g. Side hustle, Pension…',
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Done',
          onTap: _hasText
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          height: 48,
        ),
      ],
    );
  }
}
