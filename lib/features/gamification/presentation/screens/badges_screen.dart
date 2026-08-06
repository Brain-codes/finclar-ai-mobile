import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/challenge_model.dart';
import '../../providers/challenge_providers.dart';
import '../widgets/badge_detail_sheet.dart';
import '../widgets/badge_widget.dart';

const int _perRow = 3;

/// Badges with no shield yet show their name instead, so the icon shrinks to
/// leave room and the tile stays the same height as an art tile.
const double _fallbackRatio = 0.62;

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(myBadgesProvider);
    final catalog = ref.watch(badgeCatalogProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: 'Badges',
              onBack: () => context.pop(),
              circleBack: true,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(myBadgesProvider);
                  ref.invalidate(badgeCatalogProvider);
                },
                child: mine.when(
                  loading: () => const _LoadingState(),
                  error: (_, _) => _Message(
                    "Couldn't load your badges. Pull down to try again.",
                  ),
                  data: (earned) => _BadgeMonths(
                    earned: earned,
                    catalog: catalog.valueOrNull ?? const [],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeMonths extends StatelessWidget {
  final List<UserBadgeModel> earned;
  final List<BadgeModel> catalog;

  const _BadgeMonths({required this.earned, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final months = _groupByMonth(earned);
    final now = DateTime.now();
    final currentKey = DateTime(now.year, now.month);

    // The current month always shows, even when nothing has been earned yet,
    // so the locked badges read as goals for the month in progress.
    if (!months.any((m) => m.month == currentKey)) {
      months.insert(0, _MonthGroup(currentKey, const []));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.base,
      ),
      itemCount: months.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xl),
      itemBuilder: (context, i) => _BadgeSection(
        group: months[i],
        catalog: catalog,
        showLocked: months[i].month == currentKey,
      ),
    );
  }
}

class _MonthGroup {
  final DateTime month;
  final List<UserBadgeModel> badges;
  const _MonthGroup(this.month, this.badges);
}

/// `earned_period` is a week label (`2026-W31`) on some badges and a month on
/// others, so grouping keys off `earned_at` instead — it is always a timestamp.
List<_MonthGroup> _groupByMonth(List<UserBadgeModel> earned) {
  final map = <DateTime, List<UserBadgeModel>>{};
  for (final b in earned) {
    final at = b.earnedAt;
    if (at == null) continue;
    map.putIfAbsent(DateTime(at.year, at.month), () => []).add(b);
  }
  final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
  return [for (final k in keys) _MonthGroup(k, map[k]!)];
}

class _BadgeSection extends StatelessWidget {
  final _MonthGroup group;
  final List<BadgeModel> catalog;
  final bool showLocked;

  const _BadgeSection({
    required this.group,
    required this.catalog,
    required this.showLocked,
  });

  @override
  Widget build(BuildContext context) {
    // Same badge earned twice in a month is one tile with a 2x count.
    final counts = <String, List<UserBadgeModel>>{};
    for (final b in group.badges) {
      counts.putIfAbsent(b.badge.key, () => []).add(b);
    }

    final tiles = <_Tile>[
      for (final e in counts.entries)
        _Tile(badge: e.value.first.badge, earnings: e.value),
      if (showLocked)
        for (final b in catalog)
          if (!counts.containsKey(b.key)) _Tile(badge: b, earnings: const []),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${DateFormat('MMMM').format(group.month)} badges',
          style: AppTypography.labelLarge.copyWith(
            color: context.textQuaternary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (tiles.isEmpty)
          _Message('No badges earned this month yet.')
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth / _perRow;
              return Wrap(
                runSpacing: AppSpacing.sm,
                children: [
                  for (final tile in tiles) SizedBox(width: size, child: tile),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final BadgeModel badge;
  final List<UserBadgeModel> earnings;

  const _Tile({required this.badge, required this.earnings});

  @override
  Widget build(BuildContext context) {
    // A shield carries its own name on the ribbon, so only the icon fallback
    // needs a caption underneath it.
    final hasArt = badgeArtPath(badge.category) != null;

    return GestureDetector(
      onTap: () =>
          showBadgeDetailSheet(context, badge: badge, earnings: earnings),
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth;
            final widget = BadgeWidget(
              badgeKey: badge.key,
              iconName: badge.iconName,
              category: badge.category,
              count: earnings.length,
              earned: earnings.isNotEmpty,
              size: hasArt ? size : size * _fallbackRatio,
            );

            if (hasArt) return widget;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget,
                const SizedBox(height: AppSpacing.xs),
                Text(
                  badge.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    height: 1.2,
                    color: earnings.isEmpty
                        ? context.textTertiary
                        : context.textPrimary,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.base,
      ),
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSkeleton.text(width: 110),
              const SizedBox(height: AppSpacing.sm),
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.maxWidth / _perRow;
                  return Row(
                    children: List.generate(
                      _perRow,
                      (_) => SizedBox(
                        width: size,
                        height: size,
                        child: Center(
                          child: AppSkeleton.circle(size: size * 0.76),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String message;
  const _Message(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusCard,
        border: Border.all(color: context.borderColor),
      ),
      child: Text(
        message,
        style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
      ),
    );
  }
}
