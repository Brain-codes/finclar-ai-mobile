import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String title = 'Select date',
  String? subtitle,
  String doneLabel = 'Done',
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
      title: title,
      subtitle: subtitle,
      doneLabel: doneLabel,
    ),
  );
}

class _DateSheet extends StatefulWidget {
  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;
  final String? subtitle;
  final String doneLabel;

  const _DateSheet({
    required this.initial,
    required this.firstDate,
    required this.lastDate,
    required this.title,
    required this.subtitle,
    required this.doneLabel,
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

  String get _selectedLabel {
    final now = DateTime.now();
    final formatted = DateFormat('EEE, d MMM yyyy').format(_selected);
    final isSameDay = _selected.year == now.year &&
        _selected.month == now.month &&
        _selected.day == now.day;
    return isSameDay ? '$formatted (Today)' : formatted;
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
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTypography.labelLarge.copyWith(
                      color: context.textPrimary,
                      fontFamily: AppFonts.display,
                    ),
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
            if (widget.subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.subtitle!,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
            CalendarDatePicker(
              initialDate: _selected,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: (date) => setState(() => _selected = date),
              currentDate: DateTime.now(),
              initialCalendarMode: DatePickerMode.day,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                borderRadius: AppRadius.radiusCard,
              ),
              child: Row(
                children: [
                  Icon(AppIcons.calendar, size: 16, color: context.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _selectedLabel,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppButton(
              label: widget.doneLabel,
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
