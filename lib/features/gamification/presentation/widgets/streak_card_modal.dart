import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';

Future<void> showStreakCardModal(
  BuildContext context, {
  int streakCount = 5,
  String currentDay = 'Mo',
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) =>
        _StreakCardModal(streakCount: streakCount, currentDay: currentDay),
  );
}

class _StreakCardModal extends StatelessWidget {
  final int streakCount;
  final String currentDay;

  const _StreakCardModal({required this.streakCount, required this.currentDay});

  static const _days = ['Sa', 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr'];

  @override
  Widget build(BuildContext context) {
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
              // Orange gradient overlay at top
              Positioned(
                top: 0,
                left: -39,
                right: -39,
                child: Container(
                  height: 177,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFCA339), Color(0x00FFFFFF)],
                      stops: [0.0, 1.0],
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
                    const SizedBox(height: AppSpacing.sm),
                    // Mascot + streak count
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Image.asset(
                          'assets/images/gamification/streak_mascot.png',
                          width: 140,
                          height: 147,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) =>
                              const SizedBox(width: 140, height: 147),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  Text(
                                    '$streakCount',
                                    style: AppTypography.displayLarge.copyWith(
                                      fontSize: 80,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = AppColors.primary,
                                      color: null,
                                    ),
                                  ),
                                  Text(
                                    '$streakCount',
                                    style: AppTypography.displayLarge.copyWith(
                                      fontSize: 80,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Days streak',
                      style: AppTypography.headingSmall.copyWith(
                        color: AppColors.streakGold,
                        fontVariations: const [FontVariation('wght', 600)],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Day labels row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _days.map((d) {
                        final isActive = d == currentDay;
                        return Text(
                          d,
                          style: AppTypography.labelMedium.copyWith(
                            color: isActive
                                ? AppColors.streakGold
                                : AppColors.textSecondary,
                            fontVariations: [
                              FontVariation('wght', isActive ? 600 : 500),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Streak indicator row
                    Row(
                      children: [
                        // Active streak pill
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF751F),
                                Color(0xFFFD972E),
                                Color(0xFFF9D549),
                              ],
                              stops: [0.0, 0.67, 1.0],
                            ),
                            borderRadius: AppRadius.radiusFull,
                            border: Border.all(
                              color: const Color(0xFFF7D749),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              3,
                              (_) => const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3),
                                child: Icon(
                                  AppIcons.sparkle,
                                  size: 16,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Inactive day circles
                        ...List.generate(
                          4,
                          (_) => Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.sm,
                            ),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.borderStrong,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'You earned a perfect streak for logging your expenses $streakCount days in a row!',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: "Okay, let's go!",
                      onTap: () => Navigator.of(context).pop(),
                      backgroundColor: AppColors.streakGold,
                      foregroundColor: AppColors.onPrimaryDeep,
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
