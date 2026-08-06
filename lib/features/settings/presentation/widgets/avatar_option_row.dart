import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class AvatarOption<T> {
  final T value;
  final String label;

  const AvatarOption(this.value, this.label);
}

/// Label above a horizontally scrolling strip of selectable pills. Used for
/// every non-colour part of the avatar customiser.
class AvatarOptionRow<T> extends StatelessWidget {
  final String label;
  final List<AvatarOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelectedChanged;

  const AvatarOptionRow({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelectedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final option in options) ...[
                _Pill(
                  label: option.label,
                  isSelected: option.value == selected,
                  onTap: () => onSelectedChanged(option.value),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : context.surfaceVariant,
          borderRadius: AppRadius.radiusFull,
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 13,
            color: isSelected ? AppColors.white : context.textQuaternary,
          ),
        ),
      ),
    );
  }
}
