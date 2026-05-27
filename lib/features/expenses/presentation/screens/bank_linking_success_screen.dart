import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';

class BankLinkingSuccessScreen extends StatelessWidget {
  final String bankName;

  const BankLinkingSuccessScreen({super.key, required this.bankName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            children: [
              const Spacer(),
              _SuccessIllustration(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                AppStrings.bankLinkedSuccess,
                style: AppTypography.headingMedium.copyWith(
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  AppStrings.bankLinkedSuccessDesc,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _LinkedBankCard(bankName: bankName),
              const Spacer(),
              AppButton(
                label: AppStrings.goHome,
                onTap: () => context.go(RouteNames.home),
                height: 52,
              ),
              const SizedBox(height: AppSpacing.base),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Success illustration ─────────────────────────────────────────────────────

class _SuccessIllustration extends StatelessWidget {
  const _SuccessIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: AppColors.successLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        AppIcons.success,
        size: 56,
        color: AppColors.success,
      ),
    );
  }
}

// ─── Linked bank card ─────────────────────────────────────────────────────────

class _LinkedBankCard extends StatelessWidget {
  final String bankName;

  const _LinkedBankCard({required this.bankName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusCard,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.bank,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankName,
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '*******23457',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            AppIcons.success,
            size: 20,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}
