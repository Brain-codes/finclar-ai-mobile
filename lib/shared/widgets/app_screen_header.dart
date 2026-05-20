import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';

/// Standard screen title + optional subtitle block.
///
/// [highlightedText] is appended to [subtitle] in [AppColors.primary].
///
/// Usage:
/// ```dart
/// AppScreenHeader(title: AppStrings.createAccountTitle)
///
/// AppScreenHeader(
///   title: AppStrings.verifyEmailTitle,
///   subtitle: AppStrings.verifyEmailSubtitle,
///   highlightedText: email,
/// )
/// ```
class AppScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Appended to [subtitle] in primary orange. Ignored if [subtitle] is null.
  final String? highlightedText;

  const AppScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.highlightedText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headingMedium.copyWith(
            color: context.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          if (highlightedText != null)
            RichText(
              text: TextSpan(
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
                children: [
                  TextSpan(text: subtitle),
                  TextSpan(
                    text: ' $highlightedText',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              subtitle!,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
        ],
      ],
    );
  }
}
