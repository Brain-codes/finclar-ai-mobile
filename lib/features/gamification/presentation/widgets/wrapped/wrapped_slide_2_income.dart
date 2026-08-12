import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/number_formatter.dart';
import '../../../data/models/wrapped_model.dart';
import 'wrapped_shared.dart';

class WrappedSlide2Income extends StatelessWidget {
  final WrappedIncomeExpense data;
  final String symbol;

  const WrappedSlide2Income({
    super.key,
    required this.data,
    required this.symbol,
  });

  String _money(double v) =>
      formatCurrency(v, symbol, abbreviate: false, withCommas: true);

  /// Share of income that was spent. Guarded — a year with no income would
  /// divide by zero.
  int get _spentPctOfIncome => data.totalIncome > 0
      ? ((data.totalExpenses / data.totalIncome) * 100).round()
      : 0;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return WrappedSlide(
      backgroundImage: WrappedAssets.wrapped2BG,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // ── Coin decorations — bottom, three coins partially off-screen ──
          // Coin 1: bleeds left (Figma: left=-72, top≈88% of frame height)
          Positioned(
            top: h * 0.877,
            left: -72,
            child: WrappedPopIn(
              delay: const Duration(milliseconds: 500),
              child: WrappedFloat(
                amplitude: 6,
                period: const Duration(milliseconds: 3400),
                child: Image.asset(
                  WrappedAssets.coinDecor,
                  width: 249,
                  height: 249,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            ),
          ),
          // Coin 2: center-left (Figma: left=74, top≈91% of frame height)
          Positioned(
            top: h * 0.913,
            left: 74,
            child: WrappedPopIn(
              delay: const Duration(milliseconds: 650),
              child: WrappedFloat(
                amplitude: 8,
                period: const Duration(milliseconds: 2800),
                child: Image.asset(
                  WrappedAssets.coinDecor,
                  width: 249,
                  height: 249,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            ),
          ),
          // Coin 3: bleeds right (Figma: left=240, top≈88% of frame height)
          Positioned(
            top: h * 0.883,
            left: 240,
            child: WrappedPopIn(
              delay: const Duration(milliseconds: 800),
              child: WrappedFloat(
                amplitude: 7,
                period: const Duration(milliseconds: 3100),
                child: Image.asset(
                  WrappedAssets.coinDecor,
                  width: 249,
                  height: 249,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            ),
          ),
          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),
                  // Title — 48px BricolageGrotesque SemiBold, letterSpacing -1.44
                  WrappedEntrance(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Your income vs Expense',
                      style: AppTypography.displayLarge.copyWith(
                        color: WrappedColors.white,
                        fontFamily: 'BricolageGrotesque',
                        fontVariations: const [FontVariation('wght', 600)],
                        fontSize: 48,
                        height: 44 / 48,
                        letterSpacing: -1.44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle — 20px Geist Medium, 40% white opacity
                  WrappedEntrance(
                    delay: const Duration(milliseconds: 220),
                    child: WrappedAutoText(
                      data.headline,
                      maxLines: 3,
                      maxFontSize: 20,
                      minFontSize: 14,
                      style: AppTypography.bodyLarge.copyWith(
                        color: WrappedColors.whiteMuted,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // ── Income ───────────────────────────────────────────────
                  WrappedEntrance(
                    delay: const Duration(milliseconds: 380),
                    child: _AmountBlock(
                      amount: data.totalIncome,
                      money: _money,
                      label: 'Total income',
                      amountColor: WrappedColors.income,
                    ),
                  ),
                  // Divider — solid #4D4845 in a 16px-tall frame
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFF4D4845),
                    ),
                  ),
                  // ── Expense + badge ──────────────────────────────────────
                  WrappedEntrance(
                    delay: const Duration(milliseconds: 520),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _AmountBlock(
                            amount: data.totalExpenses,
                            money: _money,
                            label: 'Total spent',
                            amountColor: WrappedColors.expense,
                          ),
                        ),
                        // Badge — #FE2412 bg, 6px radius, 12px SemiBold
                        WrappedPopIn(
                          delay: const Duration(milliseconds: 900),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: WrappedColors.incomeBadge,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$_spentPctOfIncome% of income',
                              style: AppTypography.labelXSmall.copyWith(
                                color: WrappedColors.white,
                                fontVariations: const [
                                  FontVariation('wght', 600),
                                ],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // ── Net balance card — 186px fixed, content centered ─────
                  WrappedEntrance(
                    delay: const Duration(milliseconds: 680),
                    duration: const Duration(milliseconds: 750),
                    slideFrom: const Offset(0, 36),
                    child: Container(
                      width: double.infinity,
                      height: 186,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: WrappedColors.white.withValues(alpha: 0.07),
                        image: DecorationImage(
                          image: AssetImage(WrappedAssets.wrapped2NetBalance),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your net balance',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: WrappedColors.whiteMuted,
                              fontFamily: 'Geist',
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          WrappedCountUp(
                            value: data.netBalance,
                            formatter: _money,
                            delay: const Duration(milliseconds: 900),
                            style: AppTypography.amountLarge.copyWith(
                              color: WrappedColors.white,
                              fontFamily: 'BricolageGrotesque',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 36px BricolageGrotesque SemiBold amount + 14px Geist label
class _AmountBlock extends StatelessWidget {
  final double amount;
  final String Function(double) money;
  final String label;
  final Color amountColor;

  const _AmountBlock({
    required this.amount,
    required this.money,
    required this.label,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WrappedCountUp(
          value: amount,
          formatter: money,
          delay: const Duration(milliseconds: 300),
          style: AppTypography.amountLarge.copyWith(
            color: amountColor,
            fontFamily: 'BricolageGrotesque',
            fontVariations: const [FontVariation('wght', 600)],
            fontSize: 36,
            height: 40 / 36,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: WrappedColors.whiteMuted,
            fontFamily: 'Geist',
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
