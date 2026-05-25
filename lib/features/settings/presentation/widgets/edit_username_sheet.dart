import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_text_field.dart';

Future<String?> showEditUsernameSheet(BuildContext context, {String? current}) {
  return showAppSheet<String>(
    context,
    title: 'Enter a username',
    avoidKeyboard: true,
    children: [_EditUsernameContent(current: current)],
  );
}

class _EditUsernameContent extends StatefulWidget {
  final String? current;
  const _EditUsernameContent({this.current});

  @override
  State<_EditUsernameContent> createState() => _EditUsernameContentState();
}

class _EditUsernameContentState extends State<_EditUsernameContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.current ?? '');
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
      children: [
        AppTextField(
          label: 'username',
          hint: 'Enter username',
          controller: _controller,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.xl),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => AppButton(
            label: 'Done',
            onTap: value.text.trim().isNotEmpty
                ? () => Navigator.of(context).pop(value.text.trim())
                : null,
            height: 48,
          ),
        ),
      ],
    );
  }
}
