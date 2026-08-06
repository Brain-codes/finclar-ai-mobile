import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';

/// The only place `showcaseview` is imported outside this file's siblings.
/// Everything visual about a coachmark — colours, type, radii, arrow — is
/// fixed here so feature code just supplies a key, title and body.
class AppCoachmark extends StatelessWidget {
  final GlobalKey coachKey;
  final String title;
  final String description;
  final Widget child;

  /// Circular spotlight, for round targets like the FAB or the `+` button.
  final bool circular;

  const AppCoachmark({
    super.key,
    required this.coachKey,
    required this.title,
    required this.description,
    required this.child,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: coachKey,
      title: title,
      description: description,
      // The tooltip is a floating card in both themes; it must not inherit the
      // scaffold colour or it disappears against the dimmed background.
      tooltipBackgroundColor: context.surfaceColor,
      textColor: context.textPrimary,
      titleTextStyle: AppTypography.labelMedium.copyWith(
        color: context.textPrimary,
        fontVariations: const [FontVariation('wght', 600)],
      ),
      descTextStyle: AppTypography.bodySmall.copyWith(
        color: context.textSecondary,
      ),
      tooltipPadding: const EdgeInsets.all(AppSpacing.base),
      tooltipBorderRadius: AppRadius.radiusCard,
      targetPadding: const EdgeInsets.all(AppSpacing.xs),
      targetShapeBorder: circular
          ? const CircleBorder()
          : const RoundedRectangleBorder(borderRadius: AppRadius.radiusCard),
      targetBorderRadius: circular ? null : AppRadius.radiusCard,
      overlayColor: AppColors.black,
      overlayOpacity: 0.72,
      disableDefaultTargetGestures: true,
      child: child,
    );
  }
}

/// Registers the showcase controller for the subtree containing
/// [AppCoachmark]s. Required — a coachmark with no registered scope throws at
/// runtime.
class AppCoachmarkScope extends StatefulWidget {
  final Widget child;
  final VoidCallback? onFinish;

  const AppCoachmarkScope({super.key, required this.child, this.onFinish});

  @override
  State<AppCoachmarkScope> createState() => _AppCoachmarkScopeState();
}

class _AppCoachmarkScopeState extends State<AppCoachmarkScope> {
  late final ShowcaseView _view;

  @override
  void initState() {
    super.initState();
    _view = ShowcaseView.register(
      onFinish: widget.onFinish,
      onDismiss: (_) => widget.onFinish?.call(),
      // Tapping the dimmed backdrop advances/exits rather than doing nothing —
      // with this true, a user who doesn't spot the buttons is stuck.
      disableBarrierInteraction: false,
      // A target that hasn't been laid out yet would otherwise stall the tour.
      skipIfTargetNotPresent: true,
      // Every tooltip carries its own way out. This is the fix for "no way to
      // skip or continue" — never ship a coachmark without both.
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: 'Skip',
          backgroundColor: AppColors.transparent,
          textStyle: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Next',
          backgroundColor: AppColors.primary,
          textStyle: AppTypography.labelSmall.copyWith(color: AppColors.white),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
      ],
      globalTooltipActionConfig: const TooltipActionConfig(
        alignment: MainAxisAlignment.spaceBetween,
        position: TooltipActionPosition.inside,
        gapBetweenContentAndAction: 12,
      ),
    );
  }

  @override
  void dispose() {
    _view.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Starts a tour for [keys], in order. Safe to call from a post-frame callback.
void startAppCoachmarks(List<GlobalKey> keys) {
  if (keys.isEmpty) return;
  ShowcaseView.get().startShowCase(keys);
}

/// Tears down any running tour. Call before navigating away — an overlay left
/// running across a route change renders over the wrong screen.
void dismissAppCoachmarks() {
  final view = ShowcaseView.get();
  if (view.isShowCaseCompleted) return;
  view.dismiss();
}
