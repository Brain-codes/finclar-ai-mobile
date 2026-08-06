import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import 'badge_widget.dart';

enum ChallengeSuccessType { fridaySavings, categoryBudget, weekendChallenge }

/// [message] overrides the gallery's placeholder copy with the real amount,
/// badge and month once this is driven by a live entry.
Future<void> showChallengeSuccessModal(
  BuildContext context,
  ChallengeSuccessType type, {
  String? message,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _ChallengeSuccessModal(type: type, message: message),
  );
}

class _SuccessConfig {
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color gradientColor;
  final BadgeType badgeType;
  final String title;
  final String message;

  const _SuccessConfig({
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.gradientColor,
    required this.badgeType,
    required this.title,
    required this.message,
  });
}

_SuccessConfig _configFor(ChallengeSuccessType type) => switch (type) {
  ChallengeSuccessType.fridaySavings => const _SuccessConfig(
    primaryColor: AppColors.streakGold,
    onPrimaryColor: AppColors.onPrimaryDeep,
    gradientColor: Color(0xFFFCA339),
    badgeType: BadgeType.fridaySavings,
    title: 'Friday savings',
    message:
        "You've saved 5k and earned the FRIDAY SAVINGS BADGE. 3 more to go and close up for the month of April!",
  ),
  ChallengeSuccessType.categoryBudget => const _SuccessConfig(
    primaryColor: AppColors.challengePurple,
    onPrimaryColor: AppColors.onChallengePurple,
    gradientColor: Color(0xFF844FAE),
    badgeType: BadgeType.categoryBudget,
    title: 'Category budget',
    message:
        "You stayed within budget and you've earned the CATEGORY BUDGET BADGE. See you again in May!",
  ),
  ChallengeSuccessType.weekendChallenge => const _SuccessConfig(
    primaryColor: AppColors.streakGold,
    onPrimaryColor: AppColors.onPrimaryDeep,
    gradientColor: Color(0xFFFCA339),
    badgeType: BadgeType.weekendChallenge,
    title: 'Weekend challenge',
    message:
        "You went dark during the weekend and earned the WEEKEND CHALLENGE BADGE. 3 more weekends to go and close up for the month of April!",
  ),
};

class _ChallengeSuccessModal extends StatelessWidget {
  final ChallengeSuccessType type;
  final String? message;
  const _ChallengeSuccessModal({required this.type, this.message});

  @override
  Widget build(BuildContext context) {
    final cfg = _configFor(type);

    return Dialog(
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
              // Gradient overlay at top
              Positioned(
                top: 0,
                left: -39,
                right: -39,
                child: Container(
                  height: 425,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [cfg.gradientColor, const Color(0x00FFFFFF)],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.base,
                  AppSpacing.base,
                  AppSpacing.xl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.centerRight,
                      child: _CloseButton(
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Badge
                    BadgeWidget(type: cfg.badgeType, size: 180),
                    const SizedBox(height: AppSpacing.base),
                    // Title
                    Text(
                      cfg.title,
                      style: AppTypography.labelLarge.copyWith(
                        color: context.textPrimary,
                        fontVariations: const [FontVariation('wght', 700)],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Message
                    Text(
                      message ?? cfg.message,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Done',
                      onTap: () => Navigator.of(context).pop(),
                      backgroundColor: cfg.primaryColor,
                      foregroundColor: cfg.onPrimaryColor,
                      height: 52,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        child: const Icon(
          AppIcons.close,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
