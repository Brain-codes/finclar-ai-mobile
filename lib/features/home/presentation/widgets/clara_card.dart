import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/gradient_icon.dart';

class ClaraCard extends StatelessWidget {
  final bool isEmpty;
  final String? insightText;
  final VoidCallback? onTap;

  const ClaraCard({
    super.key,
    this.isEmpty = false,
    this.insightText,
    this.onTap,
  });

  static const _defaultInsight =
      "You've spent ₦150,000 so far this month which is 25% of your income and the biggest jump came from food. Apparently your wallet has developed a taste for \"just one small treat\" that somehow keeps happening. We should have a discussion about that.";

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return _EmptyClaraCard(onTap: onTap);
    }
    return _FilledClaraCard(
      insightText: insightText ?? _defaultInsight,
      onTap: onTap,
    );
  }
}

class _FilledClaraCard extends StatelessWidget {
  final String insightText;
  final VoidCallback? onTap;

  const _FilledClaraCard({required this.insightText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GradientBorderCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Clara label + "Chat with Clara" link
              Row(
                children: [
                  GradientIcon(icon: AppIcons.aiFill, size: 16, gradient: AppColors.claraGradient),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    AppStrings.aiName,
                    style: AppTypography.labelMedium.copyWith(
                      color: const Color(0xFF4D4845),
                    ),
                  ),
                  const Spacer(),
                  GradientText(
                    'Chat with ${AppStrings.aiName}',
                    gradient: AppColors.claraGradient,
                    style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Insight body text
              GradientText(
                insightText,
                gradient: AppColors.claraGradient,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Pagination dots
              const _ClaraDots(totalDots: 3, activeDot: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card with 1px gradient border drawn via a background-gradient wrapper.
class _GradientBorderCard extends StatelessWidget {
  final Widget child;

  const _GradientBorderCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.claraBorderGradient,
        borderRadius: AppRadius.radiusSheet,
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F7),
          borderRadius: BorderRadius.circular(AppRadius.sheet - 1.5),
        ),
        child: child,
      ),
    );
  }
}


/// Three pill-shaped pagination indicators using the Clara gradient at 50% opacity.
class _ClaraDots extends StatelessWidget {
  final int totalDots;
  final int activeDot;

  const _ClaraDots({required this.totalDots, required this.activeDot});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDots, (i) {
        final isActive = i == activeDot;
        return Padding(
          padding: EdgeInsets.only(right: i < totalDots - 1 ? AppSpacing.xs : 0),
          child: _GradientDot(width: isActive ? 59 : 20),
        );
      }),
    );
  }
}

class _GradientDot extends StatelessWidget {
  final double width;

  const _GradientDot({required this.width});

  static const _dotGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x80FA5874),
      Color(0x80800080),
      Color(0x80F8853D),
    ],
    stops: [0.0, 0.53, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 3,
      decoration: BoxDecoration(
        gradient: _dotGradient,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class _EmptyClaraCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _EmptyClaraCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return _GradientBorderCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            GradientIcon(icon: AppIcons.ai, size: 32, gradient: AppColors.claraGradient),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Insights Yet',
              style: AppTypography.labelMedium.copyWith(
                color: const Color(0xFF4D4845),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add your expenses, income, and Clara AI will start giving you smart money insights.',
              style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
