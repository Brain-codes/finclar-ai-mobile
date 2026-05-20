import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/text_style_extensions.dart';

class SplashBottomSection extends StatelessWidget {
  final String heading;
  final String subtitle;
  final int currentPage;
  final int totalPages;
  final VoidCallback onCta;
  final VoidCallback onLogin;

  const SplashBottomSection({
    super.key,
    required this.heading,
    required this.subtitle,
    required this.currentPage,
    required this.totalPages,
    required this.onCta,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.scaffoldColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          0,
          AppSpacing.screenPadding,
          AppSpacing.xl,
        ),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                heading,
                key: ValueKey(heading),
                style: AppTypography.displayMedium.copyWith(
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            AppSpacing.verticalMd,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  subtitle,
                  key: ValueKey(subtitle),
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            AppSpacing.verticalXxl,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 9 : 0),
                  child: _Dot(active: i == currentPage),
                );
              }),
            ),
            AppSpacing.verticalXxl,
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onCta,
                child: Text(
                  currentPage < 2
                      ? AppStrings.continueText
                      : AppStrings.createAccount,
                ),
              ),
            ),
            AppSpacing.verticalBase,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.haveAnAccount,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onLogin,
                  child: Text(AppStrings.login, style: AppTypography.link),
                ),
              ],
            ),
            AppSpacing.verticalBase,
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 5,
      height: active ? 17 : 14,
      decoration: BoxDecoration(
        color: active ? context.textSecondary : context.borderColor,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
