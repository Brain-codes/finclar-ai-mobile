import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';

/// A `null` [value] is the "no filter" entry — distinct from the sheet being
/// dismissed, which returns null for the whole option.
class FilterOption<T> {
  final T? value;
  final String label;

  /// Category rows carry their own icon + colour so the picker matches the
  /// tiles in the list.
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBgColor;

  const FilterOption({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.iconBgColor,
  });
}

Future<FilterOption<T>?> showFilterOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<FilterOption<T>> options,
  required T? selected,
}) {
  return showAppSheet<FilterOption<T>>(
    context,
    title: title,
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            _OptionRow(
              option: option,
              selected: option.value == selected,
              onTap: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    ],
  );
}

class _OptionRow extends StatelessWidget {
  final FilterOption option;
  final bool selected;
  final VoidCallback onTap;

  const _OptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Row(
            children: [
              if (option.icon != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: option.iconBgColor ?? context.surfaceVariant,
                    borderRadius: AppRadius.radiusCard,
                  ),
                  child: Icon(
                    option.icon,
                    size: 16,
                    color: option.iconColor ?? context.textQuaternary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: selected ? AppColors.primary : context.textPrimary,
                    fontSize: 15,
                    fontVariations: [
                      FontVariation('wght', selected ? 500 : 400),
                    ],
                  ),
                ),
              ),
              if (selected)
                const Icon(AppIcons.check, size: 20, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
