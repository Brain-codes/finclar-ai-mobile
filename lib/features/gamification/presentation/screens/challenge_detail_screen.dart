import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/challenge_model.dart';
import '../../providers/challenge_providers.dart';
import '../widgets/cancel_challenge_sheet.dart';
import '../widgets/challenge_dev_tools_sheet.dart';
import '../widgets/challenge_entry_tile.dart';
import '../widgets/challenge_utils.dart';
import '../widgets/record_challenge_entry_sheet.dart';
import '../widgets/start_challenge_sheet.dart';

class ChallengeDetailScreen extends ConsumerWidget {
  /// Passed via `extra` from the list; kept only as the initial value — the
  /// live copy comes from [challengesProvider] so streaks update in place.
  final ChallengeModel initial;

  const ChallengeDetailScreen({super.key, required this.initial});

  Future<void> _onRecord(BuildContext context, ChallengeModel challenge) async {
    await showRecordChallengeEntrySheet(
      context,
      challengeId: challenge.id,
      weeklyTarget: challenge.weeklyTarget,
    );
  }

  Future<void> _onEdit(BuildContext context, ChallengeModel challenge) async {
    await showStartChallengeSheet(context, existing: challenge);
  }

  Future<void> _onCancel(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
  ) async {
    final confirmed = await showCancelChallengeSheet(
      context,
      challengeName: challenge.name,
      currentStreak: challenge.currentStreak,
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(challengesProvider.notifier).cancel(challenge.id);
      if (!context.mounted) return;
      if (context.canPop()) context.pop();
      AppSnackbar.success(context, 'Challenge cancelled');
    } on AppException catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge =
        ref
            .watch(challengesProvider)
            .valueOrNull
            ?.where((c) => c.id == initial.id)
            .firstOrNull ??
        initial;

    final symbol = ref.watch(currencySymbolProvider);
    String fmt(double v) =>
        formatCurrency(v, symbol, abbreviate: false, withCommas: true);

    final entriesState = ref.watch(challengeEntriesProvider(challenge.id));
    final savedThisWeek = hasSavedThisWeek(challenge);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: challenge.name,
              onBack: () => context.pop(),
              circleBack: true,
              actions: challenge.isActive
                  ? [
                      if (AppConstants.showGamifyGallery) ...[
                        _CircleAction(
                          icon: AppIcons.settings,
                          onTap: () => showChallengeDevToolsSheet(
                            context,
                            challengeId: challenge.id,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      _CircleAction(
                        icon: AppIcons.edit,
                        onTap: () => _onEdit(context, challenge),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _CircleAction(
                        icon: AppIcons.delete,
                        color: AppColors.error,
                        onTap: () => _onCancel(context, ref, challenge),
                      ),
                    ]
                  : const [SizedBox(width: 36)],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(challengesProvider.notifier).refresh();
                  ref.invalidate(challengeEntriesProvider(challenge.id));
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.base,
                    AppSpacing.screenPadding,
                    AppSpacing.xxl,
                  ),
                  children: [
                    _SummaryCard(challenge: challenge, fmt: fmt),
                    const SizedBox(height: AppSpacing.base),
                    // Spend-based challenges are scored from logged expenses,
                    // so there is nothing for the user to record by hand.
                    if (challenge.isActive && !challenge.type.isSpendBased)
                      AppButton(
                        label: savedThisWeek
                            ? 'Log another entry'
                            : 'Log this week\'s savings',
                        variant: savedThisWeek
                            ? AppButtonVariant.outline
                            : AppButtonVariant.primary,
                        onTap: () => _onRecord(context, challenge),
                        height: 52,
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Entries',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondary,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    entriesState.when(
                      loading: () => const _EntriesSkeleton(),
                      error: (_, _) =>
                          _EntriesMessage("Couldn't load your entries"),
                      data: (entries) => entries.isEmpty
                          ? _EntriesMessage(
                              challenge.type.isSpendBased
                                  ? 'Nothing logged against this challenge yet. '
                                        'Expenses you record count automatically.'
                                  : 'No savings logged yet. Your first Friday '
                                        'starts the streak.',
                            )
                          : Column(
                              children: [
                                for (final e in entries) ...[
                                  ChallengeEntryTile(
                                    entry: e,
                                    amountLabel: e.amount == null
                                        ? 'Logged'
                                        : fmt(e.amount!),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                ],
                              ],
                            ),
                    ),
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

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _CircleAction({required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color ?? context.textQuaternary),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ChallengeModel challenge;
  final String Function(double) fmt;

  const _SummaryCard({required this.challenge, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final overall = challenge.overallTarget;
    final hasGoal = overall != null && overall > 0;
    final spendBased = challenge.type.isSpendBased;
    final amount = challengeAmount(challenge);
    final progress = hasGoal
        ? (spendBased
                  ? amount / overall
                  : (challenge.progressPercent ??
                            (challenge.totalSaved / overall * 100)) /
                        100)
              .clamp(0.0, 1.0)
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            challengeAmountLabel(challenge),
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            fmt(amount),
            style: AppTypography.amountLarge.copyWith(
              color: context.textPrimary,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: AppRadius.radiusXs,
              child: Container(
                height: 10,
                color: context.borderColor,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              spendBased
                  ? '${(progress * 100).round()}% of your ${fmt(overall!)} cap'
                  : '${(progress * 100).round()}% of ${fmt(overall!)} goal',
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: AppIcons.flame,
                  label: 'Current streak',
                  value: '${challenge.currentStreak} wk',
                ),
              ),
              Expanded(
                child: _Stat(
                  icon: AppIcons.trophy,
                  label: 'Longest streak',
                  value: '${challenge.longestStreak} wk',
                ),
              ),
              Expanded(
                child: _Stat(
                  icon: AppIcons.target,
                  label: spendBased ? 'Spend cap' : 'Weekly target',
                  value: spendBased
                      ? (hasGoal ? fmt(overall) : '—')
                      : challenge.weeklyTarget == null
                      ? '—'
                      : fmt(challenge.weeklyTarget!),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            challengeStatusLabel(challenge),
            style: AppTypography.labelSmall.copyWith(
              color: context.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textPrimary,
            fontVariations: const [FontVariation('wght', 600)],
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _EntriesSkeleton extends StatelessWidget {
  const _EntriesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.radiusCard,
              border: Border.all(color: context.borderColor),
            ),
            child: const Row(
              children: [
                AppSkeleton.circle(size: 40),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton.text(width: 90),
                      SizedBox(height: 6),
                      AppSkeleton.text(width: 130, height: 11),
                    ],
                  ),
                ),
                AppSkeleton.text(width: 40, height: 11),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntriesMessage extends StatelessWidget {
  final String message;
  const _EntriesMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
      child: Text(
        message,
        style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
      ),
    );
  }
}
