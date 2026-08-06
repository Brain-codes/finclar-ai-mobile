import 'package:flutter/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/challenge_model.dart';

/// The icon and colour a challenge type is drawn with, shared by the picker
/// sheet, the available cards and the past-challenge groups so a type looks the
/// same everywhere it appears.
class ChallengeTypeStyle {
  final IconData icon;
  final Color color;
  final Color mutedColor;

  const ChallengeTypeStyle(this.icon, this.color, this.mutedColor);
}

ChallengeTypeStyle challengeTypeStyle(ChallengeType type) => switch (type) {
  ChallengeType.fridaySavings => const ChallengeTypeStyle(
    AppIcons.flame,
    AppColors.streakGold,
    AppColors.streakGoldMuted,
  ),
  ChallengeType.noSpend => const ChallengeTypeStyle(
    AppIcons.target,
    AppColors.primary,
    AppColors.primaryMuted,
  ),
  ChallengeType.budgetCategory => const ChallengeTypeStyle(
    AppIcons.budget,
    AppColors.challengePurple,
    AppColors.challengePurpleMuted,
  ),
};
