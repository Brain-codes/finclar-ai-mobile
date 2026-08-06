import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/icons/app_icons.dart';

/// Mock-gallery badges. [key] matches the backend's badge key so the same
/// artwork resolves for both the mock modals and the live badges screen.
enum BadgeType {
  fridaySavings('friday_savings_goal_reached', 'friday_savings'),
  categoryBudget('category_budget_hero', 'budget'),
  weekendChallenge('no_spend_weekend', 'no_spend_weekend');

  final String key;
  final String category;
  const BadgeType(this.key, this.category);
}

/// Shields are keyed off the badge's *category*, not its key — the catalog
/// carries 21 badges across a handful of families and they share artwork.
/// Categories with no shield yet resolve to null and fall back to a tinted
/// icon, so dropping art in later needs no code change here.
String? badgeArtPath(String? category) => switch (category) {
  'friday_savings' => 'assets/images/gamification/badges/friday_savings.png',
  'budget' ||
  'budget_category' => 'assets/images/gamification/badges/budget.png',
  'no_spend_weekend' ||
  'no_spend' => 'assets/images/gamification/badges/no_spend_weekend.png',
  _ => null,
};

IconData badgeIcon(String? iconName) => switch (iconName) {
  'target' => AppIcons.target,
  'piggy-bank' => AppIcons.wallet,
  'shield' => AppIcons.shield,
  'flame' => AppIcons.flame,
  'star' => AppIcons.star,
  _ => AppIcons.medal,
};

Color badgeColor(String? category) => switch (category) {
  'friday_savings' => AppColors.primary,
  'budget' || 'budget_category' => AppColors.challengePurple,
  'no_spend_weekend' || 'no_spend' => AppColors.primary,
  'streak' || 'expense_streak' => AppColors.streakGold,
  _ => AppColors.primary,
};

/// The artwork is normalised so the shield's bottom point always lands at 86%
/// of the tile, which is where the count straddles it — see
/// `assets/images/gamification/badges/`.
const double _countCenter = 0.85;
const double _countFontRatio = 0.19;
const double _countLineHeight = 1.2;

/// Greyscale, for badges that are still locked.
const ColorFilter _desaturate = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

class BadgeWidget extends StatelessWidget {
  final BadgeType? type;
  final String? badgeKey;
  final String? iconName;
  final String? category;
  final int? count;
  final bool earned;
  final double size;

  const BadgeWidget({
    super.key,
    this.type,
    this.badgeKey,
    this.iconName,
    this.category,
    this.count,
    this.earned = true,
    this.size = 130,
  }) : assert(type != null || badgeKey != null);

  String? get _category => category ?? type?.category;

  @override
  Widget build(BuildContext context) {
    final color = badgeColor(_category);
    final art = badgeArtPath(_category);
    final fallback = _BadgeFallback(
      icon: badgeIcon(iconName),
      color: color,
      size: size,
    );

    Widget badge = art == null
        ? fallback
        : Image.asset(
            art,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => fallback,
          );

    if (!earned) {
      badge = ColorFiltered(
        colorFilter: _desaturate,
        child: Opacity(opacity: 0.6, child: badge),
      );
    }

    final times = count ?? 0;
    if (!earned || times < 1) {
      return SizedBox(width: size, height: size, child: badge);
    }

    final fontSize = size * _countFontRatio;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: badge),
          Positioned(
            left: 0,
            right: 0,
            top: size * _countCenter - fontSize * _countLineHeight / 2,
            child: _CountLabel(count: times, color: color, fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}

class _BadgeFallback extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _BadgeFallback({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.35), width: 2),
      ),
      child: Icon(icon, size: size * 0.42, color: color),
    );
  }
}

/// `12x` in white with the badge's own colour as an outline, sitting on the
/// shield's tail. Painted twice because Flutter can't fill and stroke one span.
class _CountLabel extends StatelessWidget {
  final int count;
  final Color color;
  final double fontSize;

  const _CountLabel({
    required this.count,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.headingLarge.copyWith(
      fontSize: fontSize,
      height: _countLineHeight,
      fontVariations: const [FontVariation('wght', 600)],
    );

    Widget layer(TextStyle style) =>
        Text('${count}x', textAlign: TextAlign.center, style: style);

    return Stack(
      alignment: Alignment.center,
      children: [
        layer(
          base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = fontSize * 0.25
              ..strokeJoin = StrokeJoin.round
              ..color = color,
          ),
        ),
        layer(base.copyWith(color: AppColors.white)),
      ],
    );
  }
}
