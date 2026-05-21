import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/icons/app_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import 'select_source_sheet.dart';
import 'add_note_sheet.dart';
import 'recurrence_sheet.dart';

Future<void> showIncomeDetailsSheet(
  BuildContext context, {
  required double amount,
}) {
  return showAppSheet(
    context,
    title: 'Add details',
    children: [_IncomeDetailsContent(amount: amount)],
  );
}

class _IncomeDetailsContent extends StatefulWidget {
  final double amount;
  const _IncomeDetailsContent({required this.amount});

  @override
  State<_IncomeDetailsContent> createState() => _IncomeDetailsContentState();
}

class _IncomeDetailsContentState extends State<_IncomeDetailsContent> {
  String? _source;
  String? _recurrence;
  String? _note;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  Future<void> _pickSource() async {
    final result = await showSelectSourceSheet(context, selected: _source);
    if (result != null) setState(() => _source = result);
  }

  Future<void> _pickRecurrence() async {
    final result = await showRecurrenceSheet(context, selected: _recurrence);
    if (result != null) setState(() => _recurrence = result);
  }

  Future<void> _pickNote() async {
    final result = await showAddNoteSheet(context, initial: _note);
    if (result != null) setState(() => _note = result);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MMM d, yyyy').format(_date);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DetailsCard(
          children: [
            _DetailRow(
              label: 'Source',
              value: _source ?? 'Select source',
              onTap: _pickSource,
            ),
            _Divider(),
            _DetailRow(
              label: 'Reoccurence',
              value: _recurrence ?? 'Select recurrence',
              onTap: _pickRecurrence,
            ),
            _Divider(),
            _DetailRow(
              label: 'Note',
              value: _note ?? 'Add note',
              onTap: _pickNote,
            ),
            _Divider(),
            _DetailRow(label: 'Date', value: dateLabel, onTap: null),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Done',
          onTap: _source != null && _recurrence != null
              ? () => context.go(RouteNames.home)
              : null,
          height: 48,
        ),
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _DetailRow({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textPrimary,
                fontSize: 14,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      AppIcons.chevronRight,
                      size: 16,
                      color: context.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.borderColor,
      indent: AppSpacing.base,
      endIndent: AppSpacing.base,
    );
  }
}
