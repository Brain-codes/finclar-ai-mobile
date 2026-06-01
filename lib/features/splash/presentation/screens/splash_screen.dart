import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/services/auth_state_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../widgets/splash_bottom_section.dart';
import '../widgets/splash_page1_illustration.dart';
import '../widgets/splash_page2_illustration.dart';
import '../widgets/splash_page3_illustration.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _totalPages = 3;

  static const _pages = [
    (heading: AppStrings.splash1Heading, subtitle: AppStrings.splash1Subtitle),
    (heading: AppStrings.splash2Heading, subtitle: AppStrings.splash2Subtitle),
    (heading: AppStrings.splash3Heading, subtitle: AppStrings.splash3Subtitle),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _currentPage = index);

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      authStateService.completeOnboarding();
      context.go(RouteNames.signUp);
    }
  }

  void _skip() {
    authStateService.completeOnboarding();
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/GRADIENT.png', fit: BoxFit.cover),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _skip,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: Text(
                          AppStrings.skip,
                          style: AppTypography.labelMedium.copyWith(
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: const [
                      SplashPage1Illustration(),
                      SplashPage2Illustration(),
                      SplashPage3Illustration(),
                    ],
                  ),
                ),
                SplashBottomSection(
                  heading: _pages[_currentPage].heading,
                  subtitle: _pages[_currentPage].subtitle,
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onCta: _next,
                  onLogin: _skip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
