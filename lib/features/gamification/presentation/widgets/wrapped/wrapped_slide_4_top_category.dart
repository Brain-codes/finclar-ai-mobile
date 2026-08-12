import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/number_formatter.dart';
import '../../../data/models/wrapped_model.dart';
import 'wrapped_shared.dart';

class WrappedSlide4TopCategory extends StatelessWidget {
  final WrappedTopCategory data;
  final String symbol;

  const WrappedSlide4TopCategory({
    super.key,
    required this.data,
    required this.symbol,
  });

  /// Widest the illustration is allowed to get. On a phone the 90 % rule wins;
  /// on a tablet it would run away, so the cap takes over.
  static const double _maxImageSide = 420;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;

    // Square artwork, so one side does for both. Also bounded by height, or a
    // short landscape-ish screen would push the amount off the slide.
    final imageSide = [
      size.width * 0.9,
      _maxImageSide,
      h * 0.42,
    ].reduce((a, b) => a < b ? a : b);
    return WrappedSlide(
      backgroundImage: WrappedAssets.wrapped4BG,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WrappedEntrance(
                    delay: const Duration(milliseconds: 100),
                    child: WrappedHeadline(
                      data.headline,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 8),
                  WrappedEntrance(
                    delay: const Duration(milliseconds: 220),
                    child: WrappedSubtitle(
                      'Your biggest category this month was ${data.name}',
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // The illustration follows the category the slide names.
                  // The column is start-aligned, so the image needs its own
                  // centring to sit in the middle of the slide.
                  Center(
                    child: WrappedEntrance(
                      delay: const Duration(milliseconds: 340),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.elasticOut,
                      slideFrom: Offset.zero,
                      scaleFrom: 0.4,
                      child: WrappedFloat(
                        amplitude: 6,
                        child: SizedBox(
                          width: imageSide,
                          height: imageSide,
                          child: Image.asset(
                            WrappedAssets.categoryImage(data.name),
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Image.asset(
                              WrappedAssets.categoryFallback,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WrappedCountUp(
                        value: data.amount,
                        formatter: (v) => formatCurrency(
                          v,
                          symbol,
                          abbreviate: false,
                          withCommas: true,
                        ),
                        delay: const Duration(milliseconds: 700),
                        textAlign: TextAlign.center,
                        style: AppTypography.amountLarge.copyWith(
                          color: WrappedColors.white,
                          fontSize: 40,
                          fontVariations: const [FontVariation('wght', 700)],
                        ),
                      ),
                      const SizedBox(height: 8),
                      WrappedEntrance(
                        delay: const Duration(milliseconds: 900),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'You spent approximately',
                              style: AppTypography.bodySmall.copyWith(
                                color: WrappedColors.foodLabel,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: WrappedColors.foodLabel,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${data.percentage.round()}% of spending',
                                style: AppTypography.labelXSmall.copyWith(
                                  color: WrappedColors.foodPct,
                                  fontVariations: const [
                                    FontVariation('wght', 600),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
