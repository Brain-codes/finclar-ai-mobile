import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/challenge_model.dart';
import '../../domain/challenge_availability.dart';
import '../../providers/challenge_providers.dart';
import '../widgets/available_challenge_card.dart';
import '../widgets/challenge_card.dart';
import '../widgets/challenge_empty_state.dart';
import '../widgets/challenge_modal.dart';
import '../widgets/challenge_type_sheet.dart';
import '../widgets/challenge_utils.dart';
import '../widgets/past_challenge_group.dart';
import '../widgets/start_challenge_sheet.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  Future<void> _onPick(BuildContext context, Set<ChallengeType> running) async {
    final type = await showChallengeTypeSheet(context, running: running);
    if (type == null || !context.mounted) return;
    await _start(context, type);
  }

  Future<void> _start(BuildContext context, ChallengeType type) async {
    final endDate = challengeAvailability(type, DateTime.now()).closesAt;
    ChallengeModel? created;

    // Friday's intro modal belongs to the weekly prompt — its two CTAs record
    // an entry rather than create anything, so creation goes straight to the
    // form. The other two intros are pure explainers and fit here.
    if (type == ChallengeType.fridaySavings) {
      created = await showStartChallengeSheet(context, type: type);
    } else {
      await showChallengeModal(
        context,
        type,
        onStart: () async {
          created = await showStartChallengeSheet(
            context,
            type: type,
            endDate: endDate,
          );
          return created != null;
        },
      );
    }

    final challenge = created;
    if (challenge != null && context.mounted) {
      context.push(RouteNames.challengeDetail, extra: challenge);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesState = ref.watch(challengesProvider);
    final running = (challengesState.valueOrNull ?? const <ChallengeModel>[])
        .where((c) => c.isActive)
        .map((c) => c.type)
        .toSet();
    // Only hidden once every type is already running — one active challenge
    // shouldn't block starting a different kind.
    final canStart = running.length < ChallengeType.values.length;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: 'Challenges',
              onBack: () => context.pop(),
              circleBack: true,
              actions: [
                if (canStart)
                  _AddButton(onTap: () => _onPick(context, running))
                else
                  const SizedBox(width: 36),
              ],
            ),
            Expanded(
              child: challengesState.when(
                loading: () => const _LoadingState(),
                error: (_, _) => _ErrorState(
                  onRetry: () =>
                      ref.read(challengesProvider.notifier).refresh(),
                ),
                data: (challenges) => _ChallengeList(
                  challenges: challenges,
                  onStart: (type) => _start(context, type),
                  onRefresh: () =>
                      ref.read(challengesProvider.notifier).refresh(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

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
          border: Border.all(color: context.borderColor),
        ),
        child: Icon(AppIcons.add, size: 20, color: context.textQuaternary),
      ),
    );
  }
}

class _ChallengeList extends ConsumerWidget {
  final List<ChallengeModel> challenges;
  final void Function(ChallengeType) onStart;
  final Future<void> Function() onRefresh;

  const _ChallengeList({
    required this.challenges,
    required this.onStart,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    String fmt(double v) =>
        formatCurrency(v, symbol, abbreviate: false, withCommas: true);

    final active = challenges.where((c) => c.isActive).toList();
    final past = challenges.where((c) => !c.isActive).toList();
    final available = availableChallenges(
      now: DateTime.now(),
      running: active.map((c) => c.type).toSet(),
    );

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.base,
          AppSpacing.screenPadding,
          AppSpacing.xxl,
        ),
        children: [
          if (challenges.isEmpty) const ChallengeEmptyState(),
          if (active.isNotEmpty) ...[
            const _SectionLabel('Ongoing'),
            for (final c in active) ...[
              _Card(challenge: c, fmt: fmt),
              const SizedBox(height: AppSpacing.base),
            ],
          ],
          if (available.isNotEmpty) ...[
            if (challenges.isNotEmpty) const _SectionLabel('Start a challenge'),
            for (final a in available) ...[
              AvailableChallengeCard(
                availability: a,
                onTap: () => onStart(a.type),
              ),
              const SizedBox(height: AppSpacing.base),
            ],
          ],
          if (past.isNotEmpty) ...[
            const _SectionLabel('Past challenges'),
            for (final group in _groupByType(past)) ...[
              PastChallengeGroup(
                type: group.key,
                challenges: group.value,
                cardBuilder: (c) => _Card(challenge: c, fmt: fmt),
              ),
              const SizedBox(height: AppSpacing.base),
            ],
          ],
        ],
      ),
    );
  }
}

/// Newest run first within each type, and types ordered by whichever was
/// finished most recently.
List<MapEntry<ChallengeType, List<ChallengeModel>>> _groupByType(
  List<ChallengeModel> past,
) {
  final sorted = [...past]
    ..sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
  final map = <ChallengeType, List<ChallengeModel>>{};
  for (final c in sorted) {
    map.putIfAbsent(c.type, () => []).add(c);
  }
  return map.entries.toList();
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(
          color: context.textSecondary,
          fontVariations: const [FontVariation('wght', 500)],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final ChallengeModel challenge;
  final String Function(double) fmt;

  const _Card({required this.challenge, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final overall = challenge.overallTarget;
    final weekly = challenge.weeklyTarget;
    final hasCap = overall != null && overall > 0;
    final spendBased = challenge.type.isSpendBased;
    final amount = challengeAmount(challenge);

    return ChallengeCard(
      name: challenge.name,
      amount: fmt(amount),
      amountPrefix: spendBased ? "You've spent" : "You've saved",
      currentStreak: challenge.currentStreak,
      progress: hasCap
          ? (spendBased
                ? amount / overall
                : (challenge.progressPercent != null
                      ? challenge.progressPercent! / 100
                      : challenge.totalSaved / overall))
          : null,
      targetLabel: hasCap
          ? (spendBased ? 'Cap: ${fmt(overall)}' : 'Goal: ${fmt(overall)}')
          : weekly != null && !spendBased
          ? '${fmt(weekly)} every Friday'
          : null,
      statusLabel: challengeStatusLabel(challenge),
      isActive: challenge.isActive,
      onTap: () => context.push(RouteNames.challengeDetail, extra: challenge),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.xxl,
      ),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.base),
      itemBuilder: (_, _) => const _CardSkeleton(),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton.text(width: 160),
          SizedBox(height: 10),
          AppSkeleton.text(width: 110, height: 12),
          SizedBox(height: 12),
          AppSkeleton(width: double.infinity, height: 14),
          SizedBox(height: 12),
          AppSkeleton(width: double.infinity, height: 28),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.flame, size: 40, color: context.textSecondary),
          const SizedBox(height: AppSpacing.base),
          Text(
            "Couldn't load your challenges",
            style: AppTypography.bodyMedium.copyWith(
              color: context.textQuaternary,
              fontSize: 14,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.radiusFull,
              ),
              child: Text(
                'Retry',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 14,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
