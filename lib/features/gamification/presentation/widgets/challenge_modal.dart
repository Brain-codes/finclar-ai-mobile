import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import 'challenge_amount_sheet.dart';

enum ChallengeType { fridaySavings, categoryBudget, noSpend }

Future<void> showChallengeModal(BuildContext context, ChallengeType type) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _ChallengeModal(type: type),
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
  ChallengeType.categoryBudget => const _ChallengeConfig(
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

class _ChallengeModal extends StatelessWidget {
  final ChallengeType type;
  const _ChallengeModal({required this.type});

  @override
  Widget build(BuildContext context) {
    final cfg = _configFor(type);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      backgroundColor: Colors.transparent,
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
              child: _CloseButton(onTap: () => Navigator.of(context).pop()),
            ),
            // Mascot — top right
            Positioned(
              top: 20,
              right: AppSpacing.xl,
              child: Image.asset(
                cfg.assetPath,
                width: 110,
                height: 110,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(width: 110, height: 110),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                140,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            label: cfg.ctaLabel,
                            height: 44,
                            onTap: () => Navigator.of(context).pop(),
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
                            onTap: () async {
                              Navigator.of(context).pop();
                              await showChallengeAmountSheet(context);
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    AppButton(
                      label: cfg.ctaLabel,
                      height: 44,
                      onTap: () => Navigator.of(context).pop(),
                      backgroundColor: cfg.primaryColor,
                      foregroundColor: cfg.onPrimaryColor,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
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
        child: const Icon(AppIcons.close, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}
