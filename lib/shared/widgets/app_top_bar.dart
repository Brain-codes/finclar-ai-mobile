import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../icons/app_icons.dart';

/// Unified top bar for all screens. Supports three layouts:
///
/// 1. Back only — `AppTopBar(onBack: ...)`
/// 2. Back + title — `AppTopBar(onBack: ..., title: 'FAQ')`
///    - `centerTitle: true` (default) centers title; `false` places it left of back button
/// 3. Back + title + actions — `AppTopBar(onBack: ..., title: '...', actions: [...])`
///
/// Auth screens use `circleBack: false` (plain arrow, default).
/// Settings screens use `circleBack: true` (36×36 surfaceVariant circle).
///
/// `stepLabel` is auth-only — renders trailing step text e.g. "Step 1/3".
class AppTopBar extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final String? title;

  /// When true (default), title is centered with back button on left and a
  /// balanced invisible spacer on right. When false, title sits immediately
  /// right of the back button (left-aligned).
  final bool centerTitle;

  /// Trailing action widgets (e.g. edit/delete circles). Only shown when
  /// [title] is provided.
  final List<Widget> actions;

  /// Step label shown on trailing edge — auth screens only (e.g. "Step 1/3").
  final String? stepLabel;

  /// Whether to wrap the back arrow in a 36×36 surfaceVariant circle.
  /// Default false (plain icon for auth). Set true for settings screens.
  final bool circleBack;

  const AppTopBar({
    super.key,
    this.showBack = true,
    this.onBack,
    this.title,
    this.centerTitle = true,
    this.actions = const [],
    this.stepLabel,
    this.circleBack = false,
  });

  Widget _backButton(BuildContext context) {
    if (!showBack) return const SizedBox(width: 40);
    final icon = Icon(AppIcons.back, size: circleBack ? 20 : 22, color: circleBack ? context.textQuaternary : context.textPrimary);
    if (circleBack) {
      return GestureDetector(
        onTap: onBack,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: context.surfaceVariant, shape: BoxShape.circle),
          child: icon,
        ),
      );
    }
    return GestureDetector(
      onTap: onBack,
      child: SizedBox(width: 40, height: 40, child: icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null;
    final hasActions = actions.isNotEmpty;
    final hasStepLabel = stepLabel != null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: hasTitle && centerTitle && !hasActions
          // Variant 2: centered title (Stack keeps it truly centered)
          ? SizedBox(
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: AppTypography.headingSmall.copyWith(color: context.textPrimary),
                  ),
                  Align(alignment: Alignment.centerLeft, child: _backButton(context)),
                  const Align(alignment: Alignment.centerRight, child: SizedBox(width: 36)),
                ],
              ),
            )
          // Variant 1 (back only) and Variant 3 (back + left title + actions)
          : Row(
              children: [
                _backButton(context),
                if (hasTitle) ...[
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTypography.headingSmall.copyWith(color: context.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                if (hasStepLabel)
                  Text(stepLabel!, style: AppTypography.bodyMedium.copyWith(color: context.textSecondary)),
                if (hasActions) ...[
                  if (hasStepLabel) const SizedBox(width: AppSpacing.sm),
                  ...actions,
                ],
              ],
            ),
    );
  }
}

/// A circular action button for use in [AppTopBar.actions].
/// Renders a 40×40 white circle with a subtle border and an icon inside.
class AppTopBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const AppTopBarAction({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(color: context.borderColor),
        ),
        child: Icon(icon, size: 20, color: context.textPrimary),
      ),
    );
  }
}
