import 'dart:math' as math;
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

// ─── Animation toolkit — reused across every wrapped slide ──────────────────
//
// Slides swap in via PageView, so every entrance animation here starts fresh
// (via initState) each time a slide is built — no manual replay wiring needed.

/// Fade + slide-up + scale entrance. The default single-shot building block
/// for staggering a slide's content in piece by piece.
class WrappedEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideFrom;
  final double scaleFrom;
  final Curve curve;

  const WrappedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 650),
    this.slideFrom = const Offset(0, 28),
    this.scaleFrom = 1.0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<WrappedEntrance> createState() => _WrappedEntranceState();
}

class _WrappedEntranceState extends State<WrappedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curved;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      child: widget.child,
      builder: (context, child) {
        final t = _curved.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: widget.slideFrom * (1 - t),
            child: Transform.scale(
              scale: widget.scaleFrom + (1 - widget.scaleFrom) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Springy pop-in — for badges, tags, pills, coins. Overshoots then settles.
class WrappedPopIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const WrappedPopIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  State<WrappedPopIn> createState() => _WrappedPopInState();
}

class _WrappedPopInState extends State<WrappedPopIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _fade.value.clamp(0.0, 1.0),
        child: Transform.scale(scale: _scale.value, child: child),
      ),
    );
  }
}

/// Counts a number up from 0 to [value] — money and percentages land with
/// weight instead of just appearing.
class WrappedCountUp extends StatefulWidget {
  final double value;
  final String Function(double) formatter;
  final Duration delay;
  final Duration duration;
  final TextStyle style;
  final TextAlign? textAlign;

  const WrappedCountUp({
    super.key,
    required this.value,
    required this.formatter,
    required this.style,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 1100),
    this.textAlign,
  });

  @override
  State<WrappedCountUp> createState() => _WrappedCountUpState();
}

class _WrappedCountUpState extends State<WrappedCountUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _value;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _value = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _value,
      builder: (context, _) => Text(
        widget.formatter(_value.value),
        textAlign: widget.textAlign,
        style: widget.style,
      ),
    );
  }
}

/// Slow, continuous up-down float — for hero illustrations that should feel
/// alive rather than static once their entrance finishes.
class WrappedFloat extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration period;

  const WrappedFloat({
    super.key,
    required this.child,
    this.amplitude = 10,
    this.period = const Duration(milliseconds: 3200),
  });

  @override
  State<WrappedFloat> createState() => _WrappedFloatState();
}

class _WrappedFloatState extends State<WrappedFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -widget.amplitude * t + widget.amplitude / 2),
          child: child,
        );
      },
    );
  }
}

/// Slow continuous pulse — grows and glows, for backgrounds and badges that
/// need ambient life without stealing focus.
class WrappedPulse extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration period;

  const WrappedPulse({
    super.key,
    required this.child,
    this.minScale = 0.94,
    this.maxScale = 1.06,
    this.period = const Duration(milliseconds: 2200),
  });

  @override
  State<WrappedPulse> createState() => _WrappedPulseState();
}

class _WrappedPulseState extends State<WrappedPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final scale =
            widget.minScale + (widget.maxScale - widget.minScale) * t;
        return Transform.scale(scale: scale, child: child);
      },
    );
  }
}

/// Diagonal light-sweep across text/headlines — a one-shot shimmer that
/// passes over the content once its entrance is done.
class WrappedShimmerSweep extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Color shimmerColor;

  const WrappedShimmerSweep({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 500),
    this.duration = const Duration(milliseconds: 1400),
    this.shimmerColor = const Color(0xFFFFFFFF),
  });

  @override
  State<WrappedShimmerSweep> createState() => _WrappedShimmerSweepState();
}

class _WrappedShimmerSweepState extends State<WrappedShimmerSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final t = _controller.value;
            final dx = bounds.width * 2.4 * t - bounds.width * 0.7;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                widget.shimmerColor.withValues(alpha: 0.9),
                Colors.transparent,
              ],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradient(dx),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double dx;
  const _SlideGradient(this.dx);
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}

/// Animates a fractional width (e.g. a bar chart bar or progress fill) from 0
/// to [targetFraction] — used wherever a bar/track needs to "grow in".
class WrappedGrowWidth extends StatefulWidget {
  final double targetFraction;
  final Widget Function(BuildContext context, double fraction) builder;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const WrappedGrowWidth({
    super.key,
    required this.targetFraction,
    required this.builder,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<WrappedGrowWidth> createState() => _WrappedGrowWidthState();
}

class _WrappedGrowWidthState extends State<WrappedGrowWidth>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fraction;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fraction = Tween<double>(
      begin: 0,
      end: widget.targetFraction,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fraction,
      builder: (context, _) => widget.builder(context, _fraction.value),
    );
  }
}

/// Drifting sparkle/confetti particles — a lightweight `CustomPainter` field
/// that loops continuously behind or above slide content.
class WrappedParticles extends StatefulWidget {
  final int count;
  final List<Color> colors;
  final double minSize;
  final double maxSize;
  final Duration period;

  const WrappedParticles({
    super.key,
    this.count = 18,
    this.colors = const [Colors.white],
    this.minSize = 2,
    this.maxSize = 5,
    this.period = const Duration(milliseconds: 6000),
  });

  @override
  State<WrappedParticles> createState() => _WrappedParticlesState();
}

class _Particle {
  final double x;
  final double phase;
  final double speed;
  final double size;
  final Color color;
  final double drift;
  const _Particle(
    this.x,
    this.phase,
    this.speed,
    this.size,
    this.color,
    this.drift,
  );
}

class _WrappedParticlesState extends State<WrappedParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(42);
    _particles = List.generate(widget.count, (i) {
      return _Particle(
        rnd.nextDouble(),
        rnd.nextDouble(),
        0.5 + rnd.nextDouble() * 0.8,
        widget.minSize + rnd.nextDouble() * (widget.maxSize - widget.minSize),
        widget.colors[i % widget.colors.length],
        (rnd.nextDouble() - 0.5) * 0.3,
      );
    });
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ParticlesPainter(_particles, _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ParticlesPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final progress = (p.phase + t * p.speed) % 1.0;
      final y = size.height * (1 - progress);
      final x = size.width * (p.x + p.drift * math.sin(progress * math.pi * 2))
          .clamp(0.0, 1.0);
      final opacity = (math.sin(progress * math.pi)).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => old.t != t;
}

/// One-shot burst of particles exploding outward from the center — for badge
/// / celebration moments like the "well done" slide.
class WrappedConfettiBurst extends StatefulWidget {
  final Duration delay;
  final List<Color> colors;

  const WrappedConfettiBurst({
    super.key,
    this.delay = Duration.zero,
    this.colors = const [
      Color(0xFF0EFD05),
      Color(0xFFFFC861),
      Color(0xFFFA5874),
      Color(0xFFFFFFFF),
    ],
  });

  @override
  State<WrappedConfettiBurst> createState() => _WrappedConfettiBurstState();
}

class _BurstParticle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  const _BurstParticle(this.angle, this.distance, this.size, this.color);
}

class _WrappedConfettiBurstState extends State<WrappedConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_BurstParticle> _particles;
  late final Animation<double> _curved;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(7);
    _particles = List.generate(28, (i) {
      return _BurstParticle(
        rnd.nextDouble() * math.pi * 2,
        0.5 + rnd.nextDouble() * 0.5,
        2 + rnd.nextDouble() * 4,
        widget.colors[i % widget.colors.length],
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _curved,
        builder: (context, _) => CustomPaint(
          painter: _BurstPainter(_particles, _curved.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final List<_BurstParticle> particles;
  final double t;
  _BurstPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.32);
    final maxRadius = size.shortestSide * 0.55;
    final opacity = (1 - t).clamp(0.0, 1.0);
    for (final p in particles) {
      final r = maxRadius * p.distance * t;
      final offset = center + Offset(math.cos(p.angle), math.sin(p.angle)) * r;
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.drawCircle(offset, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
