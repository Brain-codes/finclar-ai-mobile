import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../icons/app_icons.dart';
import 'gradient_icon.dart';

/// A short AI line delivered inline with a record — e.g. the `clara_insight`
/// that rides along on an expense or a budget response.
///
/// Renders nothing when [text] is null or blank, so callers can pass the raw
/// backend field without guarding.
class ClaraNote extends StatelessWidget {
  final String? text;

  const ClaraNote({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final value = text?.trim() ?? '';
    if (value.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.radiusCard,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientIcon(
            icon: AppIcons.aiFill,
            size: 16,
            gradient: AppColors.claraGradient,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.aiName,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textQuaternary,
                    height: 18 / 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
