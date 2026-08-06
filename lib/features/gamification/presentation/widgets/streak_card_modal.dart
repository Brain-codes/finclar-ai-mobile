import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/models/expense_streak_model.dart';
import '../../providers/streak_providers.dart';

Future<void> showStreakCardModal(
  BuildContext context, {
  required ExpenseStreakModel streak,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _StreakCardModal(streak: streak),
  );
}

/// Celebrates the streak on the first expense logged each day. Silent when the
/// user has already seen it today, has no streak, or the fetch fails — logging
/// an expense must never be blocked by this.
Future<void> maybeShowStreakModal(BuildContext context, WidgetRef ref) async {
  final today = DateTime.now().toIso8601String().split('T').first;
  if (await StorageService.getStreakModalDate() == today) return;

  final ExpenseStreakModel streak;
  try {
    streak = await ref.read(expenseStreakProvider.future);
  } on AppException catch (e) {
    Log.e('Streak fetch failed', error: e.message);
    return;
  }
  if (!streak.loggedToday || !streak.hasStreak) return;

  await StorageService.setStreakModalDate(today);
  if (!context.mounted) return;
  await showStreakCardModal(context, streak: streak);
}

class _StreakCardModal extends StatelessWidget {
  final ExpenseStreakModel streak;

  const _StreakCardModal({required this.streak});

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
                                    '${streak.currentStreak}',
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
                                    '${streak.currentStreak}',
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
                      streak.currentStreak == 1 ? 'Day streak' : 'Days streak',
                      style: AppTypography.headingSmall.copyWith(
                        color: AppColors.streakGold,
                        fontVariations: const [FontVariation('wght', 600)],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Day labels row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: streak.days.map((d) {
                        return Text(
                          d.dayLabel,
                          style: AppTypography.labelMedium.copyWith(
                            color: d.isToday
                                ? AppColors.streakGold
                                : AppColors.textSecondary,
                            fontVariations: [
                              FontVariation('wght', d.isToday ? 600 : 500),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _StreakIndicatorRow(days: streak.days),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      streak.isPersonalBest
                          ? 'A new personal best — you logged your expenses '
                                '${streak.currentStreak} days in a row!'
                          : 'You earned a perfect streak for logging your '
                                'expenses ${streak.currentStreak} days in a row!',
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

/// Each unbroken run of logged days collapses into one gradient pill; every
/// missed day is a hollow circle. A full week logged is a single wide pill.
class _StreakIndicatorRow extends StatelessWidget {
  final List<ExpenseStreakDayModel> days;

  const _StreakIndicatorRow({required this.days});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    var run = 0;

    void flushRun() {
      if (run == 0) return;
      children.add(_StreakPill(count: run));
      run = 0;
    }

    for (final day in days) {
      if (day.logged) {
        run++;
      } else {
        flushRun();
        children.add(const _MissedDayCircle());
      }
    }
    flushRun();

    return Row(
      children: [
        for (final child in children) ...[
          child,
          const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int count;

  const _StreakPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF751F), Color(0xFFFD972E), Color(0xFFF9D549)],
          stops: [0.0, 0.67, 1.0],
        ),
        borderRadius: AppRadius.radiusFull,
        border: Border.all(color: const Color(0xFFF7D749)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          count,
          (_) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Icon(AppIcons.sparkle, size: 16, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}

class _MissedDayCircle extends StatelessWidget {
  const _MissedDayCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderStrong),
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
