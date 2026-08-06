import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/models/challenge_model.dart';
import 'challenge_amount_sheet.dart';

/// Returns true when the action finished and the modal should close, false to
/// leave it open — a dismissed sheet or a failed call must not lose the modal.
typedef ChallengeModalAction = Future<bool> Function();

/// [onStart] and [onEnterAmount] hook the two CTAs up to real actions;
/// [ctaLabel] overrides the primary button's copy. All null = the inert
/// design-gallery behaviour.
///
/// The modal outlives whatever it opens. It only closes on ✕ or on an action
/// reporting success, so backing out of a sheet mid-flow drops you back here
/// instead of stranding you on the screen behind.
Future<void> showChallengeModal(
  BuildContext context,
  ChallengeType type, {
  ChallengeModalAction? onStart,
  ChallengeModalAction? onEnterAmount,
  String? ctaLabel,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    barrierDismissible: false,
    builder: (_) => _ChallengeModal(
      type: type,
      onStart: onStart,
      onEnterAmount: onEnterAmount,
      ctaLabel: ctaLabel,
    ),
  );
}

class _ChallengeConfig {
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color gradientColor;
  final Color gradientMutedColor;
  final String title;
  final String description;
  final String ctaLabel;
  final String assetPath;
  final bool hasAmountButton;

  const _ChallengeConfig({
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.gradientColor,
    required this.gradientMutedColor,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.assetPath,
    this.hasAmountButton = false,
  });
}

_ChallengeConfig _configFor(ChallengeType type) => switch (type) {
  ChallengeType.fridaySavings => const _ChallengeConfig(
    primaryColor: AppColors.primary,
    onPrimaryColor: AppColors.onPrimaryDeep,
    gradientColor: Color(0xFFFCA339),
    gradientMutedColor: Color(0xFFFEE8CD),
    title: 'Friday Savings Challenge',
    description:
        'Can you beat the Friday test? Save ₦5,000 or your preferred amount before midnight and keep your streak alive every week.',
    ctaLabel: 'Start saving',
    assetPath: 'assets/images/gamification/friday_savings_mascot.png',
    hasAmountButton: true,
  ),
  ChallengeType.budgetCategory => const _ChallengeConfig(
    primaryColor: AppColors.challengePurple,
    onPrimaryColor: AppColors.onChallengePurple,
    gradientColor: Color(0xFF844FAE),
    gradientMutedColor: Color(0xFFCEB9DF),
    title: 'Category budget challenge',
    description:
        'Spend smart and stay within your limits across every category. Keep it tight and prove you\'re in control.',
    ctaLabel: 'Start saving',
    assetPath: 'assets/images/gamification/category_budget_mascot.png',
    hasAmountButton: false,
  ),
  ChallengeType.noSpend => const _ChallengeConfig(
    primaryColor: AppColors.primary,
    onPrimaryColor: AppColors.onPrimaryDeep,
    gradientColor: Color(0xFFFCA339),
    gradientMutedColor: Color(0xFFFEE8CD),
    title: 'No spend weekend challenge',
    description:
        'Your streak is on the line. Go dark on spending from Friday to Sunday and earn the No Spend Champion badge.',
    ctaLabel: "I'm in, let's go",
    assetPath: 'assets/images/gamification/no_spend_mascot.png',
    hasAmountButton: false,
  ),
};

class _ChallengeModal extends StatefulWidget {
  final ChallengeType type;
  final ChallengeModalAction? onStart;
  final ChallengeModalAction? onEnterAmount;
  final String? ctaLabel;

  const _ChallengeModal({
    required this.type,
    this.onStart,
    this.onEnterAmount,
    this.ctaLabel,
  });

  @override
  State<_ChallengeModal> createState() => _ChallengeModalState();
}

class _ChallengeModalState extends State<_ChallengeModal> {
  /// Which CTA is mid-flight, so only that one spins and neither can be
  /// double-fired. Null when idle.
  int? _busyIndex;

  /// Gallery fallbacks — with no action wired the CTA is just a close, and
  /// "Enter amount" only shows the sheet so the layout can be eyeballed.
  Future<bool> _dismiss() async => true;

  Future<bool> _previewAmount() async {
    await showChallengeAmountSheet(context);
    return false;
  }

  Future<void> _run(int index, ChallengeModalAction action) async {
    setState(() => _busyIndex = index);
    final done = await action();
    if (!mounted) return;
    if (done) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _busyIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _configFor(widget.type);
    final busy = _busyIndex != null;

    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.radiusSheet,
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                // Top gradient overlay
                Positioned(
                  top: 0,
                  left: -39,
                  right: -39,
                  child: Container(
                    height: 192,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [cfg.gradientColor, const Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                ),
                // Close button — top right
                Positioned(
                  top: AppSpacing.base,
                  right: AppSpacing.base,
                  child: _CloseButton(
                    onTap: busy ? null : () => Navigator.of(context).pop(),
                  ),
                ),
                // Mascot — top right
                // Positioned(
                //   top: 20,
                //   right: AppSpacing.xl,
                //   child: Image.asset(
                //     cfg.assetPath,
                //     width: 200,
                //     height: 200,
                //     fit: BoxFit.contain,
                //     errorBuilder: (_, _, _) =>
                //         const SizedBox(width: 110, height: 110),
                //   ),
                // ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            cfg.assetPath,
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) =>
                                const SizedBox(width: 110, height: 110),
                          ),
                        ],
                      ),
                      Text(
                        cfg.title,
                        style: AppTypography.headingSmall.copyWith(
                          color: context.textPrimary,
                          fontVariations: const [FontVariation('wght', 600)],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        cfg.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      if (cfg.hasAmountButton)
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: widget.ctaLabel ?? cfg.ctaLabel,
                                height: 44,
                                isLoading: _busyIndex == 0,
                                onTap: busy
                                    ? null
                                    : () => _run(0, widget.onStart ?? _dismiss),
                                backgroundColor: cfg.primaryColor,
                                foregroundColor: cfg.onPrimaryColor,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppButton(
                                label: 'Enter amount',
                                height: 44,
                                variant: AppButtonVariant.outline,
                                isLoading: _busyIndex == 1,
                                onTap: busy
                                    ? null
                                    : () => _run(
                                        1,
                                        widget.onEnterAmount ?? _previewAmount,
                                      ),
                              ),
                            ),
                          ],
                        )
                      else
                        AppButton(
                          label: widget.ctaLabel ?? cfg.ctaLabel,
                          height: 44,
                          isLoading: _busyIndex == 0,
                          onTap: busy
                              ? null
                              : () => _run(0, widget.onStart ?? _dismiss),
                          backgroundColor: cfg.primaryColor,
                          foregroundColor: cfg.onPrimaryColor,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: const Icon(
          AppIcons.close,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
