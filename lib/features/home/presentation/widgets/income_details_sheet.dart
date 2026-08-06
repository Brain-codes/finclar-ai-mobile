import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../data/models/income_model.dart';
import '../../data/models/income_source_model.dart';
import '../../providers/home_dashboard_provider.dart';
import '../../providers/income_setup_provider.dart';
import 'select_source_sheet.dart';
import 'add_note_sheet.dart';
import 'recurrence_sheet.dart';

/// [existing] switches the sheet into edit mode: the rows open pre-filled and
/// Done PATCHes instead of POSTing. The backend keeps one income record per
/// user, so creating twice would 409 rather than add a second entry.
Future<void> showIncomeDetailsSheet(
  BuildContext context, {
  required double amount,
  IncomeModel? existing,
}) {
  return showAppSheet(
    context,
    title: existing == null ? 'Add details' : 'Edit details',
    children: [_IncomeDetailsContent(amount: amount, existing: existing)],
  );
}

// Maps the UI display label to the API reoccurrence value.
String _toApiReoccurrence(String label) {
  return switch (label) {
    'Monthly' => 'monthly',
    'Weekly' => 'weekly',
    'Daily' => 'daily',
    'One time' => 'one_time',
    _ => label.toLowerCase(),
  };
}

// Inverse of [_toApiReoccurrence], for pre-filling the edit flow.
String? _toDisplayReoccurrence(String? value) {
  return switch (value) {
    'monthly' => 'Monthly',
    'weekly' => 'Weekly',
    'daily' => 'Daily',
    'one_time' => 'One time',
    _ => null,
  };
}

class _IncomeDetailsContent extends ConsumerStatefulWidget {
  final double amount;
  final IncomeModel? existing;
  const _IncomeDetailsContent({required this.amount, this.existing});

  @override
  ConsumerState<_IncomeDetailsContent> createState() =>
      _IncomeDetailsContentState();
}

class _IncomeDetailsContentState extends ConsumerState<_IncomeDetailsContent> {
  IncomeSourceModel? _source;
  String? _recurrence;
  String? _note;
  late DateTime _date;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _date = existing != null
        ? (DateTime.tryParse(existing.startDate) ?? DateTime.now())
        : DateTime.now();
    _recurrence = _toDisplayReoccurrence(existing?.reoccurrence);
    _note = existing?.note;
    if (existing != null) {
      // Only id/name are known here; the picker matches on id, and isDefault
      // is never read for the selected value.
      _source = IncomeSourceModel(
        id: existing.sourceId,
        name: existing.sourceName,
        isDefault: false,
      );
    }
  }

  Future<void> _pickSource() async {
    final result =
        await showSelectSourceSheet(context, selected: _source);
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

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(incomeProvider.notifier);
      final args = (
        amount: widget.amount,
        sourceId: _source!.id,
        reoccurrence: _toApiReoccurrence(_recurrence!),
        startDate: DateFormat('yyyy-MM-dd').format(_date),
        note: _note,
      );
      if (widget.existing == null) {
        await notifier.create(
          amount: args.amount,
          sourceId: args.sourceId,
          reoccurrence: args.reoccurrence,
          startDate: args.startDate,
          note: args.note,
        );
      } else {
        await notifier.save(
          amount: args.amount,
          sourceId: args.sourceId,
          reoccurrence: args.reoccurrence,
          startDate: args.startDate,
          note: args.note,
        );
      }
      // AsyncValue.guard swallows the failure into state — surface it rather
      // than navigating home as if the save worked.
      final result = ref.read(incomeProvider);
      if (result.hasError) throw result.error!;

      // The balance card and the income/expense chart both read backend-computed
      // figures that income feeds into.
      ref.invalidate(homeInsightProvider);
      ref.invalidate(homeSummaryProvider);
      if (mounted) context.go(RouteNames.home);
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, e.toString());
        setState(() => _isLoading = false);
      }
    }
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
              value: _source?.name ?? 'Select source',
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
          onTap: _source != null && _recurrence != null && !_isLoading
              ? _submit
              : null,
          isLoading: _isLoading,
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
