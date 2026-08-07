import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../providers/social_auth_provider.dart';

Future<void> showSocialAuthErrorSheet(
  BuildContext context,
  SocialAuthFailure failure,
) {
  return showAppSheet<void>(
    context,
    title: AppStrings.socialSignInFailedTitle,
    children: [_SocialAuthErrorBody(failure: failure)],
  );
}

class _SocialAuthErrorBody extends StatefulWidget {
  final SocialAuthFailure failure;
  const _SocialAuthErrorBody({required this.failure});

  @override
  State<_SocialAuthErrorBody> createState() => _SocialAuthErrorBodyState();
}

class _SocialAuthErrorBodyState extends State<_SocialAuthErrorBody> {
  bool _expanded = false;

  String get _providerLabel => switch (widget.failure.provider) {
        SocialProvider.google => AppStrings.google,
        SocialProvider.apple => AppStrings.apple,
      };

  Future<void> _copy() async {
    final text = widget.failure.details ?? widget.failure.message;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    AppSnackbar.success(context, AppStrings.socialDetailsCopied);
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.failure.details;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFFF9EAEA),
            shape: BoxShape.circle,
          ),
          child: const Icon(AppIcons.error, color: AppColors.error, size: 26),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          '$_providerLabel sign-in didn\'t go through',
          style: AppTypography.headingSmall.copyWith(color: context.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          widget.failure.message,
          style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.base),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Text(
                AppStrings.socialTechnicalDetails,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                _expanded ? AppIcons.chevronUp : AppIcons.chevronDown,
                size: 18,
                color: context.textSecondary,
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: context.surfaceVariant,
              borderRadius: AppRadius.radiusCard,
            ),
            child: SelectableText(
              details ?? AppStrings.socialNoDetails,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          if (details != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: AppStrings.socialCopyDetails,
              onTap: _copy,
              variant: AppButtonVariant.ghost,
              icon: AppIcons.copy,
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: AppStrings.done,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
