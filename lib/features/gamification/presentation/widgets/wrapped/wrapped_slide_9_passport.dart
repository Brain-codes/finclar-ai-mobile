import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:intl/intl.dart';
import '../../../../../core/services/share_service.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/number_formatter.dart';
import '../../../../../shared/svg/app_svg.dart';
import '../../../../../shared/widgets/app_profile_avatar.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/app_svg_image.dart';
import '../../../data/models/wrapped_model.dart';
import 'wrapped_shared.dart';

class WrappedSlide9Passport extends StatefulWidget {
  final WrappedSharePassport data;
  final String symbol;

  /// Preferred name from the user's profile — the passport payload carries only
  /// a username.
  final String displayName;

  /// The user's profile icon — null falls back to initials in [AppProfileAvatar].
  final String? profileIcon;

  /// The profile's actual username (Settings → Edit details) — the passport
  /// payload's own `username` field can be stale, so this is used instead.
  final String username;

  /// Month the recap covers, used for the card date and the share caption.
  final DateTime period;

  const WrappedSlide9Passport({
    super.key,
    required this.data,
    required this.symbol,
    required this.displayName,
    this.profileIcon,
    required this.username,
    required this.period,
  });

  @override
  State<WrappedSlide9Passport> createState() => _WrappedSlide9PassportState();
}

class _WrappedSlide9PassportState extends State<WrappedSlide9Passport> {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;

  /// `<username> money passport.png`. Path separators and the like would break
  /// the temp file, so anything that isn't safe in a filename is dropped.
  String get _fileName {
    final safe = widget.username
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '')
        .trim();
    return '${safe.isEmpty ? 'Finclar' : safe} money passport.png';
  }

  /// Shares the passport card itself as a PNG — the point is that the receiver
  /// sees the passport, not a link.
  Future<void> _onShare() async {
    if (_sharing) return;
    HapticFeedback.lightImpact();
    setState(() => _sharing = true);

    final origin = ShareService.originFrom(context);
    final bytes = await ShareService.captureAsPng(_cardKey);

    if (!mounted) return;
    if (bytes == null) {
      setState(() => _sharing = false);
      AppSnackbar.error(context, "Couldn't create your passport image");
      return;
    }

    final month = DateFormat('MMMM yyyy').format(widget.period);
    final ok = await ShareService.shareImage(
      bytes,
      fileName: _fileName,
      text: 'My Finclar Money Passport for $month',
      subject: 'My Finclar Money Passport',
      sharePositionOrigin: origin,
    );

    if (!mounted) return;
    setState(() => _sharing = false);
    if (!ok) AppSnackbar.error(context, "Couldn't open the share sheet");
  }

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
              WrappedEntrance(
                delay: const Duration(milliseconds: 100),
                child: const WrappedHeadline(
                  'Share your passport',
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 12),
              WrappedEntrance(
                delay: const Duration(milliseconds: 220),
                child: Text(
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
              ),
              const SizedBox(height: 22),
              // Passport card — photo bleeds 16px above card top
              Expanded(
                child: WrappedEntrance(
                  delay: const Duration(milliseconds: 340),
                  duration: const Duration(milliseconds: 850),
                  curve: Curves.easeOutBack,
                  slideFrom: const Offset(0, 70),
                  scaleFrom: 0.85,
                  // The boundary is exactly what gets shared as a PNG.
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _PassportCard(
                              data: widget.data,
                              symbol: widget.symbol,
                              displayName: widget.displayName,
                              profileIcon: widget.profileIcon,
                              username: widget.username,
                              period: widget.period,
                            ),
                          ),
                          // Passport photo — top-right, clipped to the card bounds
                          Positioned(
                            top: -7,
                            right: 24,
                            child: WrappedPopIn(
                              delay: const Duration(milliseconds: 800),
                              child: _PassportPhoto(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const SizedBox(height: 10),
              WrappedEntrance(
                delay: const Duration(milliseconds: 950),
                child: WrappedPulse(
                  minScale: 0.98,
                  maxScale: 1.02,
                  period: const Duration(milliseconds: 1800),
                  child: _LiquidGlassButton(
                    label: 'Share passport',
                    isLoading: _sharing,
                    onTap: _onShare,
                  ),
                ),
              ),
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
  final String? profileIcon;
  final String username;
  final DateTime period;

  const _PassportCard({
    required this.data,
    required this.symbol,
    required this.displayName,
    this.profileIcon,
    required this.username,
    required this.period,
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
            _PassportHeader(period: period),
            // User row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
              child: _UserRow(
                displayName: displayName,
                username: username,
                profileIcon: profileIcon,
              ),
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
  final DateTime period;

  const _PassportHeader({required this.period});

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
            DateFormat('MMMM yyyy').format(period),
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
  final String displayName;
  final String username;
  final String? profileIcon;

  const _UserRow({
    required this.displayName,
    required this.username,
    this.profileIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar — 40×40, cornerRadius 12, blue bg + green stroke.
        // AppProfileAvatar always draws a circular face, so it's zoomed and
        // clipped to a square here to match the passport's ID-photo look.
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0F9774), width: 1),
          ),
          clipBehavior: Clip.hardEdge,
          child: OverflowBox(
            maxWidth: 56,
            maxHeight: 56,
            child: AppProfileAvatar(
              profileIcon: profileIcon,
              name: displayName.isNotEmpty ? displayName : username,
              size: 56,
              seedWhenEmpty: true,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WrappedAutoText(
                displayName.isNotEmpty ? displayName : username,
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
                '@$username',
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
  final bool isLoading;
  final VoidCallback onTap;

  const _LiquidGlassButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  // Gradient stroke: #E7E7E4 40% → #81817F 60%
  static const _borderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x66E7E7E4), Color(0x9981817F)],
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
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
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: WrappedColors.white,
                      ),
                    )
                  : Text(
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
