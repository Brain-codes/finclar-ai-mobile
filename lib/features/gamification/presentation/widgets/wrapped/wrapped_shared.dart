import 'dart:ui' show ImageFilter;
import 'package:finclar_ai/core/theme/app_colors.dart';
import 'package:finclar_ai/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_typography.dart';

// ─── Colours (fixed — Figma only, no mode switching) ────────────────────────

abstract class WrappedColors {
  static const Color bg = Color.fromARGB(255, 0, 0, 0);
  static const Color bgGreen = Color.fromARGB(255, 9, 17, 8);
  static const Color bgPassport = Color(0xFF111B17);
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteMuted = Color(0x66FFFFFF); // 40 % opacity
  static const Color dimPill = Color(0x57FFFFFF); // 34 % opacity
  static const Color income = Color(0xFF3EA462);
  static const Color expense = Color(0xFFC62828);
  static const Color neonGreen = Color(0xFF0EFD05);
  static const Color cardOverlay = Color(0x1ABBBBBB); // 10 % #bbb
  static const Color nextBtnBg = Color(0x33140C08); // 20 % dark
  static const Color passportCard = Color(0xFF112C23);
  static const Color passportGreen = Color(0xFF5E8B7B);
  static const Color passportMint = Color(0xFFCBFFEA);
  static const Color passportOverlay = Color(0x0A29F99D); // 4 %

  // category bar colours
  static const Color catFood = Color(0xFF106F0E);
  static const Color catTransport = Color(0xFF4536EF);
  static const Color catShopping = Color(0xFF810056);
  static const Color catEntertain = Color(0xFFE35B00);
  static const Color catOther = Color(0xFF573FD6);

  // personality tags
  static const Color tagGoal = Color(0xFFFE162F);
  static const Color tagConsistent = Color(0xFF641A17);
  static const Color tagTreat = Color(0xFF7B8E0A);

  // savings cards
  static const Color savingsStart = Color(0xFF1AFF09);
  static const Color savingsEnd = Color(0xFF185A14);

  // clara insight
  static const Color claraRed = Color(0xFFFE162F);
  static const Color claraRedBg = Color(0xFF641A17);
  static const Color claraRedCard = Color(0x12F61F04);
  static const Color incomeBadge = Color(0xFFFE2412);
  static const Color incomeBadgeText = Color(0xFFFFFFFF);
  static const Color foodLabel = Color(0xFFFFC861);
  static const Color foodPct = Color(0xFFA6112E);
}

// ─── 8-pill progress bar (left-aligned, auto-filling) ───────────────────────

class WrappedProgressBar extends StatelessWidget {
  final int currentIndex;
  final double currentProgress; // 0.0–1.0 fill of the active pill

  /// Number of pills. The story omits the top-category slide for a year with
  /// no expenses, so this can't be a fixed count.
  final int totalSteps;

  const WrappedProgressBar({
    super.key,
    required this.currentIndex,
    this.currentProgress = 0.0,
    this.totalSteps = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(totalSteps, (i) {
        final isPast = i < currentIndex;
        final isCurrent = i == currentIndex;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: SizedBox(
            width: 36,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Stack(
                children: [
                  Container(color: WrappedColors.dimPill),
                  FractionallySizedBox(
                    widthFactor: isPast
                        ? 1.0
                        : isCurrent
                        ? currentProgress.clamp(0.0, 1.0)
                        : 0.0,
                    child: Container(color: WrappedColors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── "Next" pill button ─────────────────────────────────────────────────────

// Gradient stroke: #E7E7E4 40% → #81817F 60%
const _nextBorderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0x66E7E7E4), Color(0x9981817F)],
);

class WrappedNextButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final String buttonType;

  const WrappedNextButton({
    super.key,
    required this.onTap,
    this.label = 'Next',
    this.buttonType = 'next',
  });

  @override
  Widget build(BuildContext context) {
    if (buttonType == 'next') {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          painter: WrappedGradientBorderPainter(
            gradient: _nextBorderGradient,
            radius: 100,
            strokeWidth: 1,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                color: WrappedColors.nextBtnBg,
                child: Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: WrappedColors.white,
                    fontVariations: const [FontVariation('wght', 600)],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.massive),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.onPrimaryDeep,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared gradient border painter ─────────────────────────────────────────

class WrappedGradientBorderPainter extends CustomPainter {
  final LinearGradient gradient;
  final double radius;
  final double strokeWidth;

  const WrappedGradientBorderPainter({
    required this.gradient,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(WrappedGradientBorderPainter old) =>
      old.gradient != gradient ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth;
}

// ─── Slide scaffold (navigation handled by PageView swipe + screen footer) ──

class WrappedSlide extends StatelessWidget {
  final Color bg;
  final String? backgroundImage;
  final Widget child;

  const WrappedSlide({
    super.key,
    this.bg = WrappedColors.bg,
    this.backgroundImage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (backgroundImage == null) {
      return Container(color: bg, child: child);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: bg),
        Image.asset(
          backgroundImage!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
        child,
      ],
    );
  }
}

// ─── Auto-fitting text ───────────────────────────────────────────────────────

/// Renders [text] at the largest size between [minFontSize] and [maxFontSize]
/// that still fits inside [maxLines] at the available width.
///
/// Slides are fixed-height and must not scroll, and the copy is backend-written
/// and variable length — so long text shrinks to fit rather than being cut off.
/// Ellipsis only kicks in if the text still doesn't fit at [minFontSize].
class WrappedAutoText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int maxLines;
  final double maxFontSize;
  final double minFontSize;

  const WrappedAutoText(
    this.text, {
    super.key,
    required this.style,
    required this.maxLines,
    required this.maxFontSize,
    required this.minFontSize,
  });

  bool _fits(double fontSize, double maxWidth, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(fontSize: fontSize),
      ),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout(maxWidth: maxWidth);
    return !painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        var fontSize = maxFontSize;

        if (maxWidth.isFinite && !_fits(maxFontSize, maxWidth, scaler)) {
          // Binary search to within 0.5pt — cheaper than stepping down 1pt at
          // a time, and the half-point difference isn't visible.
          var low = minFontSize;
          var high = maxFontSize;
          while (high - low > 0.5) {
            final mid = (low + high) / 2;
            if (_fits(mid, maxWidth, scaler)) {
              low = mid;
            } else {
              high = mid;
            }
          }
          fontSize = low;
        }

        return Text(
          text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(fontSize: fontSize),
        );
      },
    );
  }
}

// ─── Wrapped 48 px headline ──────────────────────────────────────────────────

class WrappedHeadline extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  /// Headlines are backend-written and variable length. Slides are fixed-height
  /// (no scrolling), so long copy shrinks to fit within this many lines rather
  /// than pushing content off the bottom.
  final int maxLines;

  const WrappedHeadline(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: WrappedAutoText(
        text,
        maxLines: maxLines,
        maxFontSize: 48,
        // Floor picked so a long headline still reads as the slide's title and
        // doesn't shrink into the subtitle's weight class.
        minFontSize: 28,
        style: AppTypography.displayLarge.copyWith(
          color: WrappedColors.white,
          fontFamily: 'BricolageGrotesque',
          fontVariations: const [FontVariation('wght', 600)],
          fontSize: 48,
          height: 1.1,
        ),
      ),
    );
  }
}

// ─── Wrapped subtitle ────────────────────────────────────────────────────────

class WrappedSubtitle extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;
  final int maxLines;

  const WrappedSubtitle(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: WrappedAutoText(
        text,
        maxLines: maxLines,
        maxFontSize: 20,
        minFontSize: 14,
        style: AppTypography.bodyLarge.copyWith(
          color: WrappedColors.whiteMuted,
          fontSize: 20,
        ),
      ),
    );
  }
}

// ─── Wrapped slide asset helper ─────────────────────────────────────────────

abstract class WrappedAssets {
  static const String introHero =
      'assets/images/wrapped/wrapped_intro_hero.png';
  static const String introVectorLine =
      'assets/images/wrapped/wrapped-1-bg.png';
  static const String wrapped2BG = 'assets/images/wrapped/wrapped-2-bg.png';
  static const String wrapped3BG = 'assets/images/wrapped/wrapped-3-bg.png';
  static const String wrapped4BG = 'assets/images/wrapped/wrapped-4-bg.png';
  static const String wrapped6Image =
      'assets/images/wrapped/wrapped-6-image.png';
  static const String wrapped5card1 =
      'assets/images/wrapped/wrapped-5-card-1.png';
  static const String wrapped5card2 =
      'assets/images/wrapped/wrapped-5-card-2.png';
  static const String wrapped7card1 =
      'assets/images/wrapped/wrapped-7-card-1.png';
  static const String wrapped6BGInner =
      'assets/images/wrapped/wrapped-6-bg-inner.png';
  static const String wrapped2NetBalance =
      'assets/images/wrapped/wrapped-2-net-balance.png';
  static const String coinDecor =
      'assets/images/wrapped/wrapped_coin_decor.png';
  // ─── Top-category illustrations ───────────────────────────────────────────
  // Keyed by the normalised category name the backend sends. Anything without
  // its own artwork falls back to Other.

  static const String _categoryDir = 'assets/images/wrapped/category';

  static const String categoryFallback = '$_categoryDir/Other.png';

  static const Map<String, String> _categoryImages = {
    'education': '$_categoryDir/Education.png',
    'entertainment': '$_categoryDir/Entertainment.png',
    'food': '$_categoryDir/Food.png',
    'health': '$_categoryDir/Health.png',
    'investment': '$_categoryDir/Investment.png',
    'rent': '$_categoryDir/Rent.png',
    'savings': '$_categoryDir/Savings.png',
    'shopping': '$_categoryDir/Shopping.png',
    'transportation': '$_categoryDir/Transportation.png',
    'utilities': '$_categoryDir/Utilities.png',
    'other': categoryFallback,
  };

  /// Names that mean an existing illustration but don't match its key.
  static const Map<String, String> _categoryAliases = {
    'transport': 'transportation',
    'travel': 'transportation',
    'groceries': 'food',
    'grocery': 'food',
    'dining': 'food',
    'restaurant': 'food',
    'restaurants': 'food',
    'medical': 'health',
    'healthcare': 'health',
    'bills': 'utilities',
    'utility': 'utilities',
    'housing': 'rent',
    'accommodation': 'rent',
    'school': 'education',
    'tuition': 'education',
    'leisure': 'entertainment',
    'fun': 'entertainment',
    'saving': 'savings',
    'invest': 'investment',
    'investments': 'investment',
  };

  static String categoryImage(String name) {
    final key = name.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return _categoryImages[_categoryAliases[key] ?? key] ?? categoryFallback;
  }
  static const String personality =
      'assets/images/wrapped/wrapped_personality.png';
  static const String aiRobot = 'assets/images/wrapped/ai-robot.png';
  static const String medal = 'assets/images/wrapped/wrapped_medal.png';
  static const String wrapped7CardBG =
      'assets/images/wrapped/wrapped-7-card-bg.png';
  static const String wrapped8BGInner =
      'assets/images/wrapped/wrapped-8-bg-inner.png';
  static const String wrapped8Image =
      'assets/images/wrapped/wrapped-8-image.png';
  static const String passportPhoto =
      'assets/images/wrapped/passport-photo.png';
  static const String passportCoin = 'assets/images/wrapped/passportCoin.png';
  static const String passportMedal = 'assets/images/wrapped/passportMedal.png';
  static const String passportMemoji =
      'assets/images/wrapped/passport-memoji.png';
}
