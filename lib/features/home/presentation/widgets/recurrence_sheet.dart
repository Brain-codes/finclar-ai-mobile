import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

Future<String?> showRecurrenceSheet(BuildContext context, {String? selected}) {
  return showAppSheet<String>(
    context,
    title: 'Reoccurrence',
    children: [_RecurrenceContent(initialSelected: selected)],
  );
}

const _kOptions = ['Monthly', 'Weekly', 'Daily', 'One time'];

class _RecurrenceContent extends StatefulWidget {
  final String? initialSelected;
  const _RecurrenceContent({this.initialSelected});

  @override
  State<_RecurrenceContent> createState() => _RecurrenceContentState();
}

class _RecurrenceContentState extends State<_RecurrenceContent> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.radiusSheet,
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _kOptions.length; i++) ...[
                _RecurrenceRow(
                  label: _kOptions[i],
                  isSelected: _selected == _kOptions[i],
                  onTap: () => setState(() => _selected = _kOptions[i]),
                ),
                if (i < _kOptions.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.borderColor,
                    indent: AppSpacing.base,
                    endIndent: AppSpacing.base,
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Done',
          onTap: _selected != null
              ? () => Navigator.of(context).pop(_selected)
              : null,
          height: 48,
        ),
      ],
    );
  }
}

class _RecurrenceRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _RecurrenceRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.base,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textQuaternary,
                fontVariations: const [FontVariation('wght', 500)],
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(
              isSelected ? AppIcons.radioChecked : AppIcons.circle,
              size: 20,
              color: isSelected ? AppColors.primary : context.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
