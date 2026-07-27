import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../providers/subscription_providers.dart';

final _dateFormat = DateFormat('MMMM d, y');

Future<void> showCancellationSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CancellationSheet(),
  );
}

class _CancellationSheet extends ConsumerStatefulWidget {
  const _CancellationSheet();

  @override
  ConsumerState<_CancellationSheet> createState() => _CancellationSheetState();
}

class _CancellationSheetState extends ConsumerState<_CancellationSheet> {
  bool _isLoading = false;

  Future<void> _confirm() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(subscriptionProvider.notifier).cancel();
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success(context, 'Subscription cancelled successfully');
    } catch (e) {
      if (mounted) AppSnackbar.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final endDate =
        ref.watch(subscriptionProvider).valueOrNull?.currentPeriodEnd;
    final endLabel = endDate != null ? _dateFormat.format(endDate) : null;

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
            endLabel != null
                ? 'Your subscription will end on $endLabel'
                : 'Your subscription will end at the end of the current period',
            style: AppTypography.headingLarge.copyWith(
              color: context.textPrimary,
              height: 1.33,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            endLabel != null
                ? "You'll continue enjoying Clara+ until $endLabel. After this date, your account will automatically return to the free plan and you won't be charged again."
                : "You'll continue enjoying Clara+ until the end of your current period. After that, your account will automatically return to the free plan and you won't be charged again.",
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
            onTap: _confirm,
            isLoading: _isLoading,
            height: 48,
          ),
        ],
      ),
    );
  }
}
