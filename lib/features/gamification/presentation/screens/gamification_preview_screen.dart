import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/expense_streak_model.dart';
import '../widgets/challenge_dev_tools_sheet.dart';
import '../widgets/challenge_modal.dart';
import '../widgets/challenge_prompts.dart';
import '../widgets/challenge_success_modal.dart';
import '../widgets/challenge_type_sheet.dart';
import '../widgets/streak_card_modal.dart';

/// Design-gallery fixture. The shipping modal is driven by
/// `expenseStreakProvider`; this screen only exists to eyeball the layout.
const _sampleStreak = ExpenseStreakModel(
  currentStreak: 5,
  longestStreak: 12,
  loggedToday: true,
  days: [
    ExpenseStreakDayModel(dayLabel: 'Sa', logged: true, isToday: false),
    ExpenseStreakDayModel(dayLabel: 'Su', logged: true, isToday: false),
    ExpenseStreakDayModel(dayLabel: 'Mo', logged: true, isToday: true),
    ExpenseStreakDayModel(dayLabel: 'Tu', logged: false, isToday: false),
    ExpenseStreakDayModel(dayLabel: 'We', logged: false, isToday: false),
    ExpenseStreakDayModel(dayLabel: 'Th', logged: false, isToday: false),
    ExpenseStreakDayModel(dayLabel: 'Fr', logged: false, isToday: false),
  ],
);

class GamificationPreviewScreen extends StatelessWidget {
  const GamificationPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: 'Gamify',
              onBack: () => context.pop(),
              circleBack: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.base,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('Screens'),
                    _PreviewTile(
                      icon: AppIcons.medal,
                      iconBg: AppColors.settingsBrown,
                      label: 'Badges Screen',
                      onTap: () => context.push(RouteNames.badges),
                    ),
                    _PreviewTile(
                      icon: AppIcons.sparkle,
                      iconBg: const Color(0xFF191919),
                      label: 'Money Wrapped',
                      onTap: () => context.push(RouteNames.wrapped),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _SectionLabel('Streak'),
                    _PreviewTile(
                      icon: AppIcons.flame,
                      iconBg: AppColors.primary,
                      label: 'Streak Card',
                      onTap: () =>
                          showStreakCardModal(context, streak: _sampleStreak),
                    ),
                    _PreviewTile(
                      icon: AppIcons.settings,
                      iconBg: AppColors.settingsBrown,
                      label: 'Dev tools (live backend)',
                      onTap: () => showChallengeDevToolsSheet(context),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    // Forced past the day/window guards so the weekend and
                    // category prompts can be tested on any day.
                    _SectionLabel('Prompts (live backend)'),
                    _PreviewTile(
                      icon: AppIcons.flame,
                      iconBg: AppColors.streakGold,
                      label: 'Friday prompt — force',
                      onTap: () => maybeShowFridayChallengePrompt(
                        context,
                        ProviderScope.containerOf(context),
                        fromPush: true,
                      ),
                    ),
                    _PreviewTile(
                      icon: AppIcons.target,
                      iconBg: AppColors.primary,
                      label: 'Weekend prompt — force',
                      onTap: () => maybeShowWeekendChallengePrompt(
                        context,
                        ProviderScope.containerOf(context),
                        fromPush: true,
                      ),
                    ),
                    _PreviewTile(
                      icon: AppIcons.budget,
                      iconBg: AppColors.challengePurple,
                      label: 'Category prompt — force',
                      onTap: () => maybeShowCategoryChallengePrompt(
                        context,
                        ProviderScope.containerOf(context),
                        fromPush: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _SectionLabel('Challenge Intros'),
                    _PreviewTile(
                      icon: AppIcons.add,
                      iconBg: AppColors.challengePurple,
                      label: 'Challenge type picker',
                      onTap: () => showChallengeTypeSheet(context),
                    ),
                    _PreviewTile(
                      icon: AppIcons.trophy,
                      iconBg: AppColors.streakGold,
                      label: 'Friday Savings Challenge',
                      onTap: () => showChallengeModal(
                        context,
                        ChallengeType.fridaySavings,
                      ),
                    ),
                    _PreviewTile(
                      icon: AppIcons.trophy,
                      iconBg: AppColors.challengePurple,
                      label: 'Category Budget Challenge',
                      onTap: () => showChallengeModal(
                        context,
                        ChallengeType.budgetCategory,
                      ),
                    ),
                    _PreviewTile(
                      icon: AppIcons.trophy,
                      iconBg: AppColors.primary,
                      label: 'No Spend Weekend Challenge',
                      onTap: () =>
                          showChallengeModal(context, ChallengeType.noSpend),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _SectionLabel('Challenge Success'),
                    _PreviewTile(
                      icon: AppIcons.sparkle,
                      iconBg: AppColors.streakGold,
                      label: 'Friday Savings — Success',
                      onTap: () => showChallengeSuccessModal(
                        context,
                        ChallengeSuccessType.fridaySavings,
                      ),
                    ),
                    _PreviewTile(
                      icon: AppIcons.sparkle,
                      iconBg: AppColors.challengePurple,
                      label: 'Category Budget — Success',
                      onTap: () => showChallengeSuccessModal(
                        context,
                        ChallengeSuccessType.categoryBudget,
                      ),
                    ),
                    _PreviewTile(
                      icon: AppIcons.sparkle,
                      iconBg: AppColors.primary,
                      label: 'Weekend Challenge — Success',
                      onTap: () => showChallengeSuccessModal(
                        context,
                        ChallengeSuccessType.weekendChallenge,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.labelXSmall.copyWith(
          color: context.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  const _PreviewTile({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Icon(icon, size: 18, color: AppColors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: context.textPrimary,
                ),
              ),
            ),
            Icon(AppIcons.chevronRight, size: 18, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}
