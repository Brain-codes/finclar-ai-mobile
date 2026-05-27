import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_date_sheet.dart';

Future<DateTime?> showExpenseDateSheet(
  BuildContext context, {
  required DateTime initial,
}) {
  return showAppDateSheet(
    context,
    initial: initial,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
  );
}
