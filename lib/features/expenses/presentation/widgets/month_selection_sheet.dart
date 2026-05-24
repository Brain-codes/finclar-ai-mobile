import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_sheet.dart';

Future<int?> showMonthSelectionSheet(
  BuildContext context, {
  required int selected,
}) {
  return showAppSheet<int>(
    context,
    title: 'Select month',
    children: [_MonthSelectionContent(selected: selected)],
  );
}

class _MonthSelectionContent extends StatefulWidget {
  final int selected;
  const _MonthSelectionContent({required this.selected});

  @override
  State<_MonthSelectionContent> createState() => _MonthSelectionContentState();
}

class _MonthSelectionContentState extends State<_MonthSelectionContent> {
  late int _selected;

  static const _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.6,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isSelected = month == _selected;
        return GestureDetector(
          onTap: () {
            setState(() => _selected = month);
            Navigator.of(context).pop(month);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : context.surfaceVariant,
              borderRadius: AppRadius.radiusFull,
            ),
            alignment: Alignment.center,
            child: Text(
              _months[index],
              style: AppTypography.bodySmall.copyWith(
                color: isSelected
                    ? AppColors.white
                    : context.textQuaternary,
                fontSize: 12,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ),
        );
      },
    );
  }
}
