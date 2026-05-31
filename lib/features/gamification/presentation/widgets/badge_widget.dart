import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

enum BadgeType { fridaySavings, categoryBudget, weekendChallenge }

class BadgeWidget extends StatelessWidget {
  final BadgeType type;
  final int? count;
  final bool earned;
  final double size;

  const BadgeWidget({
    super.key,
    required this.type,
    this.count,
    this.earned = true,
    this.size = 130,
  });

  String get _assetPath => switch (type) {
    BadgeType.fridaySavings    => 'assets/images/gamification/badge_friday_savings.png',
    BadgeType.categoryBudget   => 'assets/images/gamification/badge_category_budget.png',
    BadgeType.weekendChallenge => 'assets/images/gamification/badge_weekend_challenge.png',
  };

  Color get _countStrokeColor => switch (type) {
    BadgeType.fridaySavings    => AppColors.primary,
    BadgeType.categoryBudget   => AppColors.challengePurple,
    BadgeType.weekendChallenge => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    Widget badge = Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => SizedBox(width: size, height: size),
    );

    if (!earned) {
      badge = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Opacity(opacity: 0.6, child: badge),
      );
    }

    if (count != null && earned) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          badge,
          Positioned(
            top: -4,
            right: -4,
            child: _CountBadge(count: count!, strokeColor: _countStrokeColor),
          ),
        ],
      );
    }

    return badge;
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color strokeColor;

  const _CountBadge({required this.count, required this.strokeColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          '${count}x',
          style: AppTypography.labelMedium.copyWith(
            fontSize: 14,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = strokeColor,
          ),
        ),
        Text(
          '${count}x',
          style: AppTypography.labelMedium.copyWith(
            fontSize: 14,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}
