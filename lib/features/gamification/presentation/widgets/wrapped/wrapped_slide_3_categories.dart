import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import 'wrapped_shared.dart';

class WrappedSlide3Categories extends StatelessWidget {
  const WrappedSlide3Categories({super.key});

  static const _categories = [
    _Category('Food & dining', '₦450,000', '32%', WrappedColors.catFood, 1.0),
    _Category(
      'Transportation',
      '₦350,000',
      '28%',
      WrappedColors.catTransport,
      0.925,
    ),
    _Category('Shopping', '₦250,000', '24%', WrappedColors.catShopping, 0.865),
    _Category(
      'Entertainment',
      '₦150,000',
      '20%',
      WrappedColors.catEntertain,
      0.786,
    ),
    _Category('Others', '₦50,000', '15%', WrappedColors.catOther, 0.690),
  ];

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
              const WrappedHeadline(
                'Where your money went',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              const WrappedSubtitle(
                'Your spent a total of ₦450,000 across 5 categories',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 28),
              // Category bars
              ..._categories.map(
                (c) => _CategoryBar(category: c, maxWidth: screenW - 32),
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
  final String pct;
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
  const _CategoryBar({required this.category, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: maxWidth * category.widthFraction,
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
                Text(
                  category.pct,
                  style: AppTypography.bodySmall.copyWith(
                    color: WrappedColors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
