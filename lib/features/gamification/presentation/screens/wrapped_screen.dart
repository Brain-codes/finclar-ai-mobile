import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/wrapped/wrapped_shared.dart';
import '../widgets/wrapped/wrapped_slide_1_intro.dart';
import '../widgets/wrapped/wrapped_slide_2_income.dart';
import '../widgets/wrapped/wrapped_slide_3_categories.dart';
import '../widgets/wrapped/wrapped_slide_4_top_category.dart';
import '../widgets/wrapped/wrapped_slide_5_savings.dart';
import '../widgets/wrapped/wrapped_slide_6_personality.dart';
import '../widgets/wrapped/wrapped_slide_7_clara_ai.dart';
import '../widgets/wrapped/wrapped_slide_8_well_done.dart';
import '../widgets/wrapped/wrapped_slide_9_passport.dart';

class WrappedScreen extends StatefulWidget {
  const WrappedScreen({super.key});

  @override
  State<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends State<WrappedScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progressController;
  int _currentPage = 0;

  static const int _totalSlides = 9;
  static const Duration _slideDuration = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: _slideDuration,
    );
    _progressController.addStatusListener(_onProgressStatus);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _progressController.removeStatusListener(_onProgressStatus);
    _progressController.dispose();
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) _next();
  }

  void _startAutoPlay() {
    if (_currentPage >= _totalSlides - 1) return;
    _progressController
      ..stop()
      ..reset()
      ..forward();
  }

  void _next() {
    if (_currentPage < _totalSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    HapticFeedback.lightImpact();
    setState(() => _currentPage = page);
    _startAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isPassport = _currentPage == _totalSlides - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Swipeable slides ────────────────────────────────────────────
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              WrappedSlide1Intro(),
              WrappedSlide2Income(),
              WrappedSlide3Categories(),
              WrappedSlide4TopCategory(),
              WrappedSlide5Savings(),
              WrappedSlide6Personality(),
              WrappedSlide7ClaraAI(),
              WrappedSlide8WellDone(),
              WrappedSlide9Passport(),
            ],
          ),
          // ── Progress bar — left-aligned, auto-filling ───────────────────
          if (!isPassport)
            Positioned(
              top: topPad + 12,
              left: 16,
              right: 16,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (_, _) => WrappedProgressBar(
                  currentIndex: _currentPage,
                  currentProgress: _progressController.value,
                ),
              ),
            ),
          // ── Footer — lives exclusively in WrappedScreen ─────────────────
          if (!isPassport)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildFooter(bottomPad, isPassport),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(double bottomPad, bool isPassport) {
    if (isPassport) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Share passport',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.onPrimaryDeep,
                    fontVariations: const [FontVariation('wght', 600)],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: WrappedColors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Done',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMedium.copyWith(
                    color: WrappedColors.white,
                    fontVariations: const [FontVariation('wght', 600)],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final label = switch (_currentPage) {
      0 => 'View my passport',
      7 => 'See my passport',
      _ => 'Next',
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPad + 36),
      child: Center(
        child: WrappedNextButton(
          onTap: () {
            HapticFeedback.lightImpact();
            _next();
          },
          label: label,
          buttonType: _currentPage == 0 || _currentPage == 7 ? 'share' : 'next',
        ),
      ),
    );
  }
}
