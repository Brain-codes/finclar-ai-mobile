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

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
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
                  WrappedHeadline(data.headline, padding: EdgeInsets.zero),
                  const SizedBox(height: 8),
                  WrappedSubtitle(
                    'Your biggest category this month was ${data.name}',
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 28),
                  Image.asset(
                    WrappedAssets.wrapped4Image,
                    // height: h * 0.23,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 28),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatCurrency(
                          data.amount,
                          symbol,
                          abbreviate: false,
                          withCommas: true,
                        ),
                        style: AppTypography.amountLarge.copyWith(
                          color: WrappedColors.white,
                          fontSize: 40,
                          fontVariations: const [FontVariation('wght', 700)],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
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
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  WrappedAssets.food,
                  height: h * 0.32,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => SizedBox(height: h * 0.32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
