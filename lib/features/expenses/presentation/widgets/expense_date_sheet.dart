import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_date_sheet.dart';

Future<DateTime?> showExpenseDateSheet(
  BuildContext context, {
  required DateTime initial,
  String title = 'Expense date',
  String? subtitle = 'The day this expense happened. Future dates are not allowed.',
  String doneLabel = 'Done',
}) {
  return showAppDateSheet(
    context,
    initial: initial,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    title: title,
    subtitle: subtitle,
    doneLabel: doneLabel,
  );
}
