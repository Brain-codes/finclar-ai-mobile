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

Future<void> showBankIntegrationModal(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final router = GoRouter.of(context);
  return showDialog(
    context: context,
    barrierColor: isDark
        ? Colors.black.withValues(alpha: 0.7)
        : const Color(0xFFEFEFED).withValues(alpha: 0.67),
    barrierDismissible: false,
    builder: (dialogCtx) => _BankIntegrationModal(
      onGetStarted: () {
        Navigator.of(dialogCtx).pop();
        router.push(RouteNames.bankIntegration);
      },
      onClose: () => Navigator.of(dialogCtx).pop(),
    ),
  );
}

class _BankIntegrationModal extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onClose;

  const _BankIntegrationModal({
    required this.onGetStarted,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xxxl,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CloseRow(onClose: onClose),
              const SizedBox(height: AppSpacing.base),
              const _Header(),
              const SizedBox(height: AppSpacing.xl),
              const _FeatureList(),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: AppStrings.getStarted,
                onTap: onGetStarted,
                fullWidth: false,
                height: 48,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Close row ───────────────────────────────────────────────────────────────

class _CloseRow extends StatelessWidget {
  final VoidCallback onClose;
  const _CloseRow({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.surfaceColor,
            shape: BoxShape.circle,
            border: Border.all(color: context.borderColor),
          ),
          child: Icon(AppIcons.close, size: 16, color: context.textSecondary),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('🏦', style: TextStyle(fontSize: 72)),
        const SizedBox(height: AppSpacing.base),
        Text(
          AppStrings.connectYourAccount,
          style: AppTypography.headingSmall.copyWith(
            fontVariations: const [FontVariation('wght', 600)],
            fontSize: 19,
            color: context.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            AppStrings.connectSubtitle,
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ─── Feature list ────────────────────────────────────────────────────────────

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        AppIcons.transfer,
        AppStrings.bankNoMoreTracking,
        AppStrings.bankNoMoreTrackingDesc,
        AppColors.categoryTransport,
      ),
      (
        AppIcons.chartFill,
        AppStrings.bankSeeMoneyGoes,
        AppStrings.bankSeeMoneyGoesDesc,
        AppColors.success,
      ),
      (
        AppIcons.aiFill,
        AppStrings.bankSmarterInsights,
        AppStrings.bankSmarterInsightsDesc,
        AppColors.primary,
      ),
      (
        AppIcons.shield,
        AppStrings.bankSecureProtected,
        AppStrings.bankSecureProtectedDesc,
        AppColors.categoryShopping,
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _FeatureRow(
            icon: items[i].$1,
            title: items[i].$2,
            description: items[i].$3,
            color: items[i].$4,
          ),
          if (i < items.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Divider(
                height: 1,
                thickness: 1,
                color: context.borderColor,
              ),
            ),
        ],
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: context.textQuaternary,
                    fontFamily: AppFonts.display,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
