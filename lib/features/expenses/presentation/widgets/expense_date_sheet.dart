import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';

Future<DateTime?> showExpenseDateSheet(
  BuildContext context, {
  required DateTime initial,
}) {
  return showAppSheet<DateTime>(
    context,
    title: 'Select date',
    heightFactor: 0.65,
    children: [_ExpenseDateContent(initial: initial)],
  );
}

class _ExpenseDateContent extends StatefulWidget {
  final DateTime initial;
  const _ExpenseDateContent({required this.initial});

  @override
  State<_ExpenseDateContent> createState() => _ExpenseDateContentState();
}

class _ExpenseDateContentState extends State<_ExpenseDateContent> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarDatePicker(
          initialDate: _selected,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          onDateChanged: (date) => setState(() => _selected = date),
          currentDate: DateTime.now(),
          initialCalendarMode: DatePickerMode.day,
          selectableDayPredicate: (day) => !day.isAfter(DateTime.now()),
        ),
        const SizedBox(height: AppSpacing.base),
        AppButton(
          label: 'Done',
          onTap: () => Navigator.of(context).pop(_selected),
          height: 48,
        ),
      ],
    );
  }
}
