import 'package:flutter/material.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../icons/app_icons.dart';
import 'app_button.dart';

Future<DateTime?> showAppDateSheet(
  BuildContext context, {
  required DateTime initial,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSheetTop),
    builder: (_) => _DateSheet(
      initial: initial,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now(),
    ),
  );
}

class _DateSheet extends StatefulWidget {
  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;

  const _DateSheet({
    required this.initial,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_DateSheet> createState() => _DateSheetState();
}

class _DateSheetState extends State<_DateSheet> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.xl,
          AppSpacing.screenPadding,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select date',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textPrimary,
                    fontFamily: AppFonts.display,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.borderStrong),
                    ),
                    child: Icon(AppIcons.close, size: 14, color: context.textSecondary),
                  ),
                ),
              ],
            ),
            CalendarDatePicker(
              initialDate: _selected,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: (date) => setState(() => _selected = date),
              currentDate: DateTime.now(),
              initialCalendarMode: DatePickerMode.day,
            ),
            AppButton(
              label: 'Done',
              onTap: () => Navigator.of(context).pop(_selected),
              height: 48,
            ),
            SizedBox(height: AppSpacing.lg + bottomPadding),
          ],
        ),
      ),
    );
  }
}
