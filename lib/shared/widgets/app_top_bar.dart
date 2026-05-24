import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../icons/app_icons.dart';

/// Shared top bar used on all auth (and other) screens.
///
/// Usage:
/// ```dart
/// AppTopBar(onBack: () => context.pop(), stepLabel: AppStrings.step1of3)
/// AppTopBar(showBack: false, stepLabel: AppStrings.step3of3)
/// AppTopBar(onBack: () => context.pop())   // no step label
/// AppTopBar()                              // no back, no label (rare)
/// ```
class AppTopBar extends StatelessWidget {
  /// Whether to show the back arrow. Defaults to true.
  final bool showBack;

  /// Called when the back arrow is tapped. Required when [showBack] is true.
  final VoidCallback? onBack;

  /// Optional step label rendered on the trailing edge (e.g. "Step 1/3").
  final String? stepLabel;

  /// Optional widget injected after the step label (rarely needed).
  final Widget? trailing;

  /// Optional centered title. When provided, renders between back button and
  /// trailing — use instead of [stepLabel] when a screen title is needed.
  final String? title;

  const AppTopBar({
    super.key,
    this.showBack = true,
    this.onBack,
    this.stepLabel,
    this.trailing,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              if (showBack)
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    height: 40,
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      AppIcons.back,
                      size: 22,
                      color: context.textPrimary,
                    ),
                  ),
                )
              else
                const SizedBox(width: 40),
              const Spacer(),
              if (stepLabel != null)
                Text(
                  stepLabel!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              if (trailing != null) ...[
                if (stepLabel != null) const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
          if (title != null)
            Text(
              title!,
              style: AppTypography.labelMedium.copyWith(
                color: context.textPrimary,
                fontVariations: const [FontVariation('wght', 600)],
              ),
            ),
        ],
      ),
    );
  }
}
