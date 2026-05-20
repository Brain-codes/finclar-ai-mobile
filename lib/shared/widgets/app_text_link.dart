import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';

/// Inline prompt + tappable action link.
///
/// Usage:
/// ```dart
/// AppTextLink(
///   prompt: AppStrings.haveAnAccount,
///   actionLabel: AppStrings.login,
///   onTap: () => context.go(RouteNames.login),
/// )
/// AppTextLink(
///   prompt: AppStrings.didntReceiveCode,
///   actionLabel: AppStrings.resendCode,
///   onTap: _resend,
/// )
/// ```
class AppTextLink extends StatelessWidget {
  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  const AppTextLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prompt,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(actionLabel, style: AppTypography.link),
        ),
      ],
    );
  }
}
