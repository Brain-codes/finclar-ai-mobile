import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_text_field.dart';

Future<String?> showExpenseNoteSheet(
  BuildContext context, {
  String? initial,
}) {
  return showAppSheet<String>(
    context,
    title: 'Add a note',
    avoidKeyboard: true,
    children: [_ExpenseNoteContent(initial: initial)],
  );
}

class _ExpenseNoteContent extends StatefulWidget {
  final String? initial;
  const _ExpenseNoteContent({this.initial});

  @override
  State<_ExpenseNoteContent> createState() => _ExpenseNoteContentState();
}

class _ExpenseNoteContentState extends State<_ExpenseNoteContent> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial ?? '');
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
          hint: 'Add a note…',
          controller: _controller,
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
