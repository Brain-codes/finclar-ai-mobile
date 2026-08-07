import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/svg/app_svg.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../providers/social_auth_provider.dart';
import 'social_auth_error_sheet.dart';

/// "or" divider used above the social buttons on both Sign up and Login.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: context.borderColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            AppStrings.orDivider,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
          ),
        ),
        Expanded(child: Container(height: 1, color: context.borderColor)),
      ],
    );
  }
}

/// Google (+ Apple on iOS) sign-in buttons. Owns its own loading and failure
/// handling, so both Sign up and Login get identical behaviour for free.
class SocialAuthButtons extends ConsumerWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(socialAuthProvider);

    ref.listen(socialAuthProvider, (prev, next) {
      final failure = next.failure;
      if (failure != null && failure != prev?.failure) {
        ref.read(socialAuthProvider.notifier).clearFailure();
        showSocialAuthErrorSheet(context, failure);
      }
    });

    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: AppStrings.google,
            onTap: state.isLoading
                ? null
                : () => ref.read(socialAuthProvider.notifier).signInWithGoogle(),
            isLoading: state.loading == SocialProvider.google,
            variant: AppButtonVariant.secondary,
            svgIcon: AppSvg.google,
          ),
        ),
        // Apple requires Sign in with Apple to be offered wherever another
        // social login is, but only on their platforms.
        if (Platform.isIOS) ...[
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton(
              label: AppStrings.apple,
              onTap: state.isLoading
                  ? null
                  : () => ref.read(socialAuthProvider.notifier).signInWithApple(),
              isLoading: state.loading == SocialProvider.apple,
              variant: AppButtonVariant.secondary,
              svgIcon: AppSvg.apple,
            ),
          ),
        ],
      ],
    );
  }
}
