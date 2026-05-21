import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_text_field.dart';

Future<String?> showAddNoteSheet(
  BuildContext context, {
  String? initial,
}) {
  return showAppSheet<String>(
    context,
    title: 'Add a note',
    avoidKeyboard: true,
    children: [_AddNoteContent(initial: initial)],
  );
}

class _AddNoteContent extends StatefulWidget {
  final String? initial;
  const _AddNoteContent({this.initial});

  @override
  State<_AddNoteContent> createState() => _AddNoteContentState();
}

class _AddNoteContentState extends State<_AddNoteContent> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) _controller.text = widget.initial!;
    _hasText = _controller.text.trim().isNotEmpty;
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
      children: [
        AppTextField(
          label: 'Note',
          controller: _controller,
          hint: 'Add a note…',
          maxLines: 5,
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
