import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/models/wrapped_model.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../providers/wrapped_providers.dart';
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

/// Fetches the monthly recap, then hands it to [WrappedStory]. The story only
/// ever renders with real data — no partially-populated slides.
class WrappedScreen extends ConsumerWidget {
  final int? year;
  final int? month;

  const WrappedScreen({super.key, this.year, this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = (year: year, month: month);
    return Scaffold(
      backgroundColor: Colors.black,
      body: ref
          .watch(wrappedProvider(period))
          .when(
            loading: () => const _WrappedLoading(),
            error: (_, _) => _WrappedError(
              onRetry: () => ref.invalidate(wrappedProvider(period)),
            ),
            data: (wrapped) => WrappedStory(
              wrapped: wrapped,
              period: DateTime(
                year ?? DateTime.now().year,
                month ?? DateTime.now().month,
              ),
              // The passport shows a human name; the payload only carries the
              // username, so use the preferred name the user chose.
              displayName:
                  ref.watch(userProfileProvider).valueOrNull?.displayName ?? '',
            ),
          ),
    );
  }
}

class _WrappedLoading extends StatelessWidget {
  const _WrappedLoading();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.primary));
}

class _WrappedError extends StatelessWidget {
  final VoidCallback onRetry;

  const _WrappedError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "We couldn't build your wrapped",
              textAlign: TextAlign.center,
              style: AppTypography.headingSmall.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(label: 'Try again', onTap: onRetry),
            const SizedBox(height: 12),
            AppButton(
              label: 'Close',
              variant: AppButtonVariant.ghost,
              onTap: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class WrappedStory extends StatefulWidget {
  final WrappedModel wrapped;
  final String displayName;

  /// Month the recap covers — the passport prints it and the share caption
  /// names it.
  final DateTime period;

  const WrappedStory({
    super.key,
    required this.wrapped,
    required this.displayName,
    required this.period,
  });

  @override
  State<WrappedStory> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends State<WrappedStory>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progressController;
  int _currentPage = 0;

  static const Duration _slideDuration = Duration(seconds: 6);

  late final List<Widget> _slides = _buildSlides();

  int get _totalSlides => _slides.length;

  List<Widget> _buildSlides() {
    final w = widget.wrapped;
    final symbol = w.symbol;
    return [
      WrappedSlide1Intro(cover: w.cover),
      WrappedSlide2Income(data: w.incomeVsExpense, symbol: symbol),
      WrappedSlide3Categories(data: w.spendingBreakdown, symbol: symbol),
      // Absent for a year with no expenses — skip rather than render an empty slide.
      if (w.topCategory != null)
        WrappedSlide4TopCategory(data: w.topCategory!, symbol: symbol),
      WrappedSlide5Savings(data: w.savings, symbol: symbol),
      WrappedSlide6Personality(data: w.personality),
      WrappedSlide7ClaraAI(data: w.tip),
      WrappedSlide8WellDone(data: w.badge),
      WrappedSlide9Passport(
        data: w.sharePassport,
        symbol: symbol,
        displayName: widget.displayName,
        period: widget.period,
      ),
    ];
  }

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

  /// Hold-to-pause, like a story. Holds the current slide until release.
  void _pauseAutoPlay() {
    if (!_progressController.isAnimating) return;
    _progressController.stop();
  }

  /// Resumes from where it paused rather than restarting the slide.
  void _resumeAutoPlay() {
    if (_currentPage >= _totalSlides - 1) return;
    if (_progressController.isAnimating) return;
    if (_progressController.value >= 1.0) return;
    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isPassport = _currentPage == _totalSlides - 1;

    return Stack(
      children: [
        // ── Swipeable slides ────────────────────────────────────────────
        // Hold anywhere on a slide to pause; release to resume. The gesture
        // arena hands a horizontal drag to the PageView, so swiping between
        // slides still works.
        GestureDetector(
          onLongPressStart: (_) => _pauseAutoPlay(),
          onLongPressEnd: (_) => _resumeAutoPlay(),
          onLongPressCancel: _resumeAutoPlay,
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _slides,
          ),
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
                // Passport is the finale and shows no progress bar.
                totalSteps: _totalSlides - 1,
              ),
            ),
          ),
        // ── Footer — lives exclusively in WrappedScreen ─────────────────
        if (!isPassport)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFooter(bottomPad),
          ),
        // ── Close — the passport is the finale, so it needs a way out ───
        if (isPassport)
          Positioned(
            top: topPad + 12,
            right: 16,
            child: _CloseButton(
              onTap: () {
                HapticFeedback.lightImpact();
                if (context.canPop()) context.pop();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFooter(double bottomPad) {
    // Indices are relative to the end, since the top-category slide is
    // omitted for a year with no expenses.
    final isFirst = _currentPage == 0;
    final isLastBeforePassport = _currentPage == _totalSlides - 2;
    final label = isFirst
        ? 'View my passport'
        : (isLastBeforePassport ? 'See my passport' : 'Next');

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPad + 36),
      child: Center(
        child: WrappedNextButton(
          onTap: () {
            HapticFeedback.lightImpact();
            _next();
          },
          label: label,
          buttonType: isFirst || isLastBeforePassport ? 'share' : 'next',
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: WrappedColors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(AppIcons.close, size: 18, color: WrappedColors.white),
      ),
    );
  }
}
