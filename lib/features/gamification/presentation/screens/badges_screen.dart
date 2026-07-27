import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../widgets/badge_widget.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.base,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BadgeSection(
                      month: 'April badges',
                      badges: const [
                        _BadgeEntry(
                          type: BadgeType.fridaySavings,
                          count: 2,
                          earned: true,
                        ),
                        _BadgeEntry(
                          type: BadgeType.categoryBudget,
                          count: 1,
                          earned: true,
                        ),
                        _BadgeEntry(
                          type: BadgeType.weekendChallenge,
                          count: 2,
                          earned: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _BadgeSection(
                      month: 'May badges',
                      badges: const [
                        _BadgeEntry(
                          type: BadgeType.fridaySavings,
                          earned: false,
                        ),
                        _BadgeEntry(
                          type: BadgeType.categoryBudget,
                          earned: false,
                        ),
                        _BadgeEntry(
                          type: BadgeType.weekendChallenge,
                          earned: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _BadgeSection(
                      month: 'June badges',
                      badges: const [
                        _BadgeEntry(
                          type: BadgeType.fridaySavings,
                          earned: false,
                        ),
                        _BadgeEntry(
                          type: BadgeType.categoryBudget,
                          earned: false,
                        ),
                        _BadgeEntry(
                          type: BadgeType.weekendChallenge,
                          earned: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _BadgeSection(
                      month: 'July badges',
                      badges: const [
                        _BadgeEntry(
                          type: BadgeType.fridaySavings,
                          earned: false,
                        ),
                        _BadgeEntry(
                          type: BadgeType.categoryBudget,
                          earned: false,
                        ),
                        _BadgeEntry(
                          type: BadgeType.weekendChallenge,
                          earned: false,
                        ),
                      ],
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

class _BadgeEntry {
  final BadgeType type;
  final int? count;
  final bool earned;
  const _BadgeEntry({required this.type, this.count, required this.earned});
}

class _BadgeSection extends StatelessWidget {
  final String month;
  final List<_BadgeEntry> badges;

  const _BadgeSection({required this.month, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          month,
          style: AppTypography.labelMedium.copyWith(
            color: context.textQuaternary,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        LayoutBuilder(
          builder: (context, constraints) {
            final count = badges.length;
            final spacing = AppSpacing.base;
            final available =
                constraints.maxWidth - (spacing * (count > 1 ? count - 1 : 0));
            final size = (available / (count == 0 ? 1 : count)).clamp(
              0.0,
              110.0,
            );
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: badges
                  .map(
                    (e) => BadgeWidget(
                      type: e.type,
                      count: e.count,
                      earned: e.earned,
                      size: size,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
