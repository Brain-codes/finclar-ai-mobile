import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/number_formatter.dart';
import '../../../../../shared/svg/app_svg.dart';
import '../../../../../shared/widgets/app_svg_image.dart';
import '../../../data/models/wrapped_model.dart';
import 'wrapped_shared.dart';

class WrappedSlide9Passport extends StatelessWidget {
  final WrappedSharePassport data;
  final String symbol;

  /// Preferred name from the user's profile — the passport payload carries only
  /// a username.
  final String displayName;

  const WrappedSlide9Passport({
    super.key,
    required this.data,
    required this.symbol,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return WrappedSlide(
      bg: WrappedColors.bgPassport,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const WrappedHeadline(
                'Share your passport',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              Text(
                'Well done! You can share your passport with loved ones',
                style: AppTypography.bodySmall.copyWith(
                  color: WrappedColors.white.withValues(alpha: 0.4),
                  fontFamily: 'Geist',
                  fontVariations: const [FontVariation('wght', 500)],
                  fontSize: 16,
                  letterSpacing: -0.5,
                  height: 24 / 16,
                ),
              ),
              const SizedBox(height: 22),
              // Passport card — photo bleeds 16px above card top
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _PassportCard(
                          data: data,
                          symbol: symbol,
                          displayName: displayName,
                        ),
                      ),
                      // Passport photo — top-right, clipped to the card bounds
                      Positioned(top: -7, right: 24, child: _PassportPhoto()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const SizedBox(height: 10),
              const _LiquidGlassButton(label: 'Share passport'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Passport card ───────────────────────────────────────────────────────────

class _PassportCard extends StatelessWidget {
  final WrappedSharePassport data;
  final String symbol;
  final String displayName;

  const _PassportCard({
    required this.data,
    required this.symbol,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: WrappedColors.passportCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: WrappedColors.passportGreen.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with bottom divider
            _PassportHeader(),
            // User row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
              child: _UserRow(data: data, displayName: displayName),
            ),
            // Stats inner card
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
              child: _StatsCard(data: data, symbol: symbol),
            ),
            // MRZ line
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: _MrzLine(name: displayName),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card header (logo + title + photo) ─────────────────────────────────────

class _PassportHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: WrappedColors.passportGreen.withValues(alpha: 0.32),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo row — icon placeholder + "Finclar"
          Row(
            children: [
              const AppSvgImage(
                AppSvg.wrappedPassportMark,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Finclar',
                style: AppTypography.bodySmall.copyWith(
                  color: WrappedColors.passportGreen,
                  fontFamily: 'Geist',
                  fontVariations: const [FontVariation('wght', 500)],
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // "Money Passport" + date
          Text(
            'Money Passport',
            style: AppTypography.displayLarge.copyWith(
              color: WrappedColors.passportGreen,
              fontFamily: 'BricolageGrotesque',
              fontVariations: const [FontVariation('wght', 600)],
              fontSize: 24,
              height: 32 / 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMMM yyyy').format(DateTime.now()),
            style: AppTypography.bodySmall.copyWith(
              color: WrappedColors.passportGreen.withValues(alpha: 0.73),
              fontFamily: 'Geist',
              fontVariations: const [FontVariation('wght', 500)],
              fontSize: 12,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── User row (avatar + name + handle) ──────────────────────────────────────

class _UserRow extends StatelessWidget {
  final WrappedSharePassport data;
  final String displayName;

  const _UserRow({required this.data, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar — 40×40, cornerRadius 12, blue bg + green stroke
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFC5ECFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0F9774), width: 1),
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.asset(
            WrappedAssets.passportMemoji,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WrappedAutoText(
                displayName.isNotEmpty ? displayName : data.username,
                maxLines: 1,
                maxFontSize: 14,
                minFontSize: 10,
                style: AppTypography.bodySmall.copyWith(
                  color: WrappedColors.passportMint,
                  fontFamily: 'BricolageGrotesque',
                  fontVariations: const [FontVariation('wght', 500)],
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
              Text(
                data.username,
                style: AppTypography.bodySmall.copyWith(
                  color: WrappedColors.passportGreen.withValues(alpha: 0.73),
                  fontFamily: 'Geist',
                  fontVariations: const [FontVariation('wght', 500)],
                  fontSize: 12,
                  height: 16 / 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stats inner card ────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final WrappedSharePassport data;
  final String symbol;

  const _StatsCard({required this.data, required this.symbol});

  String _money(double v) =>
      formatCurrency(v, symbol, abbreviate: false, withCommas: true);

  /// Share of income kept. Guarded — a year with no income can't have a rate.
  int get _savingsRate => data.totalIncome > 0
      ? ((data.totalSaved / data.totalIncome) * 100).round()
      : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WrappedColors.passportOverlay,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: WrappedColors.passportGreen.withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Row 1: Income / Expense
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  label: 'Income',
                  value: _money(data.totalIncome),
                ),
              ),
              Expanded(
                child: _StatCell(
                  label: 'Expense',
                  value: _money(data.totalExpenses),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: WrappedColors.passportGreen.withValues(alpha: 0.32),
          ),
          const SizedBox(height: 16),
          // Row 2: Amount saved / Savings rate
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  label: 'Amount saved',
                  value: _money(data.totalSaved),
                ),
              ),
              Expanded(
                child: _StatCell(
                  label: 'Savings rate',
                  value: '$_savingsRate%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Personality row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: WrappedColors.passportOverlay,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Logo icon placeholder
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset(
                    WrappedAssets.passportCoin,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WrappedAutoText(
                        data.personalityName,
                        maxLines: 1,
                        maxFontSize: 14,
                        minFontSize: 10,
                        style: AppTypography.bodySmall.copyWith(
                          color: WrappedColors.passportMint,
                          fontFamily: 'Geist',
                          fontVariations: const [FontVariation('wght', 500)],
                          fontSize: 14,
                          height: 20 / 14,
                        ),
                      ),
                      Text(
                        'See my money story on Finclar',
                        style: AppTypography.bodySmall.copyWith(
                          color: WrappedColors.passportGreen,
                          fontFamily: 'Geist',
                          fontVariations: const [FontVariation('wght', 400)],
                          fontSize: 12,
                          height: 16 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: WrappedColors.passportGreen,
            fontFamily: 'Geist',
            fontVariations: const [FontVariation('wght', 400)],
            fontSize: 12,
            height: 16 / 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.displayLarge.copyWith(
            color: WrappedColors.passportMint.withValues(alpha: 0.92),
            fontFamily: 'BricolageGrotesque',
            fontVariations: const [FontVariation('wght', 400)],
            fontSize: 20,
            height: 24 / 20,
          ),
        ),
      ],
    );
  }
}

// ─── MRZ line ────────────────────────────────────────────────────────────────

class _MrzLine extends StatelessWidget {
  final String name;

  const _MrzLine({required this.name});

  /// MRZ-style encoding: uppercase name tokens joined by "<<", suffixed with
  /// the app tag — mirrors the passport aesthetic instead of a fixed mock name.
  String get _mrz {
    final tokens = name
        .trim()
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty);
    final base = tokens.isEmpty ? 'FINCLAR' : tokens.join('<<');
    return '$base<<FINCLAR<<345';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        _mrz,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall.copyWith(
          color: WrappedColors.passportGreen.withValues(alpha: 0.92),
          fontFamily: 'Inter',
          fontVariations: const [FontVariation('wght', 400)],
          fontSize: 12,
          letterSpacing: 3.8,
          height: 16 / 12,
        ),
      ),
    );
  }
}

// ─── Passport photo placeholder ──────────────────────────────────────────────

class _PassportPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 63,
        height: 116,
        child: Image.asset(
          WrappedAssets.passportMedal,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, _, _) => Container(
            color: WrappedColors.passportGreen.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}

// ─── Share button (glass fill + gradient stroke + backdrop blur) ──────────────

class _LiquidGlassButton extends StatelessWidget {
  final String label;

  const _LiquidGlassButton({required this.label});

  // Gradient stroke: #E7E7E4 40% → #81817F 60%
  static const _borderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x66E7E7E4), Color(0x9981817F)],
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: WrappedGradientBorderPainter(
          gradient: _borderGradient,
          radius: 100,
          strokeWidth: 1,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              height: 56,
              color: WrappedColors.nextBtnBg,
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: WrappedColors.white,
                  fontFamily: 'Geist',
                  fontVariations: const [FontVariation('wght', 600)],
                  fontSize: 16,
                  height: 24 / 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
