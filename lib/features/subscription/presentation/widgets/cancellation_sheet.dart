import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';

Future<void> showCancellationSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CancellationSheet(),
  );
}

class _CancellationSheet extends StatelessWidget {
  const _CancellationSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.scaffoldColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.borderColor),
                ),
                child: Icon(AppIcons.close, size: 16, color: context.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Your subscription will end on March 8, 2027',
            style: AppTypography.headingLarge.copyWith(
              color: context.textPrimary,
              height: 1.33,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            "You'll continue enjoying Clara+ until March 8, 2027. After this date, your account will automatically return to the free plan and you won't be charged again.",
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Clara will still be here if you changed your mind.',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Confirm cancellation',
            onTap: () {
              Navigator.of(context).pop();
              AppSnackbar.success(context, 'Subscription cancelled successfully');
            },
            height: 48,
          ),
        ],
      ),
    );
  }
}
