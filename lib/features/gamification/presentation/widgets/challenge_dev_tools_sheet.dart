import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../providers/challenge_providers.dart';
import '../../providers/streak_providers.dart';
import 'streak_card_modal.dart';

/// Wraps the backend's `/dev/` helpers. Only reachable from builds started with
/// `--dart-define=SHOW_GAMIFY_GALLERY=true`.
///
/// [challengeId] is optional: the daily-streak and test-push tools aren't
/// challenge-scoped, so the sheet is also reachable from the gamification
/// gallery with no challenge running. The challenge-scoped tools hide in that
/// case.
Future<void> showChallengeDevToolsSheet(
  BuildContext context, {
  String? challengeId,
}) {
  return showAppSheet<void>(
    context,
    title: 'Dev tools',
    children: [_DevTools(challengeId: challengeId)],
  );
}

class _DevTools extends ConsumerStatefulWidget {
  final String? challengeId;
  const _DevTools({required this.challengeId});

  @override
  ConsumerState<_DevTools> createState() => _DevToolsState();
}

class _DevToolsState extends ConsumerState<_DevTools> {
  int _weeks = 4;
  int _days = 5;
  bool _isBusy = false;

  /// Not routed through [_run] — the point is to see the celebration modal the
  /// real thing would show, which has to happen after the sheet is gone.
  Future<void> _simulateDailyStreak() async {
    setState(() => _isBusy = true);
    try {
      final streak = await ref
          .read(streakRepositoryProvider)
          .simulateStreak(_days);
      ref.invalidate(expenseStreakProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      await showStreakCardModal(context, streak: streak);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      AppSnackbar.error(context, e.message);
    }
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    setState(() => _isBusy = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success(context, success);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      AppSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(challengesProvider.notifier);
    final challengeId = widget.challengeId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'These hit the backend for real on this account. Simulating a streak '
          'awards badges and sends a push.',
          style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (challengeId != null) ...[
          Text(
            'Jump challenge streak to $_weeks ${_weeks == 1 ? 'week' : 'weeks'}',
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
            ),
          ),
          Slider(
            value: _weeks.toDouble(),
            min: 1,
            max: 52,
            divisions: 51,
            label: '$_weeks',
            onChanged: _isBusy
                ? null
                : (v) => setState(() => _weeks = v.round()),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Simulate challenge streak',
            isLoading: _isBusy,
            height: 52,
            onTap: () => _run(
              () => notifier.simulateStreak(challengeId, _weeks),
              'Streak jumped to $_weeks weeks',
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Sends the real Friday reminder push to this device. Tapping it '
            'should open the challenge modal.',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Send reminder push now',
            variant: AppButtonVariant.outline,
            height: 52,
            onTap: _isBusy
                ? null
                : () => _run(
                    () => notifier.sendTestReminder(challengeId),
                    'Test reminder sent',
                  ),
          ),
          const SizedBox(height: AppSpacing.base),
        ],
        Text(
          'Daily expense-logging streak — counts days you logged an expense, '
          'unrelated to any challenge. Jumping it shows the celebration card.',
          style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Jump daily streak to $_days ${_days == 1 ? 'day' : 'days'}',
          style: AppTypography.labelMedium.copyWith(color: context.textPrimary),
        ),
        Slider(
          value: _days.toDouble(),
          min: 1,
          max: 100,
          divisions: 99,
          label: '$_days',
          onChanged: _isBusy ? null : (v) => setState(() => _days = v.round()),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Simulate daily streak',
          variant: AppButtonVariant.outline,
          height: 52,
          onTap: _isBusy ? null : _simulateDailyStreak,
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Plain push to every device on this account — use it to tell a broken '
          'token registration from a broken feature.',
          style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Send test push',
          variant: AppButtonVariant.outline,
          height: 52,
          onTap: _isBusy
              ? null
              : () => _run(NotificationService.sendTestPush, 'Test push sent'),
        ),
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}
