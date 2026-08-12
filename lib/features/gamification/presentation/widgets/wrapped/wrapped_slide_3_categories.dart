import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/number_formatter.dart';
import '../../../data/models/wrapped_model.dart';
import 'wrapped_shared.dart';

class WrappedSlide3Categories extends StatelessWidget {
  final WrappedSpendingBreakdown data;
  final String symbol;

  const WrappedSlide3Categories({
    super.key,
    required this.data,
    required this.symbol,
  });

  /// Fixed palette cycled across however many categories come back — the
  /// backend sends no per-category color.
  static const _palette = [
    WrappedColors.catFood,
    WrappedColors.catTransport,
    WrappedColors.catShopping,
    WrappedColors.catEntertain,
    WrappedColors.catOther,
  ];

  /// The slide is fixed-height (no scrolling), so only the top few categories
  /// fit. The backend can return more than this.
  static const int _maxBars = 5;

  /// Bars are sized relative to the biggest category, not to 100%, so the
  /// chart still reads well when one category dominates.
  List<_Category> _bars() {
    if (data.categories.isEmpty) return const [];
    final sorted = [...data.categories]
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final shown = sorted.take(_maxBars).toList();
    final top = shown.first.amount;
    return List.generate(shown.length, (i) {
      final c = shown[i];
      return _Category(
        c.name,
        formatCurrency(c.amount, symbol, abbreviate: false, withCommas: true),
        c.percentage,
        _palette[i % _palette.length],
        top > 0 ? (0.35 + 0.65 * (c.amount / top)) : 1.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return WrappedSlide(
      backgroundImage: WrappedAssets.wrapped3BG,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              WrappedEntrance(
                delay: const Duration(milliseconds: 100),
                child: const WrappedHeadline(
                  'Where your money went',
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 8),
              WrappedEntrance(
                delay: const Duration(milliseconds: 220),
                child: WrappedSubtitle(data.headline, padding: EdgeInsets.zero),
              ),
              const SizedBox(height: 28),
              // Category bars — grow in one after another
              ..._bars().asMap().entries.map(
                (entry) => _CategoryBar(
                  category: entry.value,
                  maxWidth: screenW - 32,
                  delay: Duration(milliseconds: 380 + entry.key * 160),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Category {
  final String name;
  final String amount;
  final double pct;
  final Color color;
  final double widthFraction;
  const _Category(
    this.name,
    this.amount,
    this.pct,
    this.color,
    this.widthFraction,
  );
}

class _CategoryBar extends StatelessWidget {
  final _Category category;
  final double maxWidth;
  final Duration delay;
  const _CategoryBar({
    required this.category,
    required this.maxWidth,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WrappedGrowWidth(
        targetFraction: category.widthFraction,
        delay: delay,
        duration: const Duration(milliseconds: 750),
        builder: (context, fraction) => Opacity(
          opacity: (fraction / category.widthFraction).clamp(0.0, 1.0),
          child: Container(
            width: maxWidth * fraction,
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: AppTypography.bodySmall.copyWith(
                    color: WrappedColors.white,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      category.amount,
                      style: AppTypography.amountSmall.copyWith(
                        color: WrappedColors.white,
                        fontSize: 22,
                      ),
                    ),
                    WrappedCountUp(
                      value: category.pct,
                      formatter: (v) => '${v.round()}%',
                      delay: delay,
                      duration: const Duration(milliseconds: 750),
                      style: AppTypography.bodySmall.copyWith(
                        color: WrappedColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
