import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/subscription_model.dart';
import '../../providers/subscription_providers.dart';
import 'cancellation_sheet.dart';

final _dateFormat = DateFormat('MMMM d, y');

Future<void> showActiveSubscriptionSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ActiveSubscriptionSheet(),
  );
}

class _ActiveSubscriptionSheet extends ConsumerWidget {
  const _ActiveSubscriptionSheet();

  Future<void> _resume(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(subscriptionProvider.notifier).resume();
      if (!context.mounted) return;
      AppSnackbar.success(context, 'Your subscription has been resumed');
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(subscriptionProvider);
    final symbol = ref.watch(currencySymbolProvider);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subscription',
                style: AppTypography.headingSmall.copyWith(color: context.textPrimary),
              ),
              GestureDetector(
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
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          async.when(
            loading: () => const _Skeleton(),
            error: (e, _) => Text(
              "We couldn't load your subscription",
              style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
            ),
            data: (subscription) => subscription == null
                ? const SizedBox.shrink()
                : _Details(
                    subscription: subscription,
                    symbol: symbol,
                    onResume: () => _resume(context, ref),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final SubscriptionModel subscription;
  final String symbol;
  final VoidCallback onResume;

  const _Details({
    required this.subscription,
    required this.symbol,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final isYearly = subscription.planCode == PlanCode.yearly;
    final amount = subscription.majorAmount;
    final start = subscription.currentPeriodStart;
    final end = subscription.currentPeriodEnd;
    final isEnding = subscription.isEndingAtPeriodEnd;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6F0),
            borderRadius: AppRadius.radiusSheet,
            border: Border.all(color: AppColors.primary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isYearly ? 'Clara + yearly' : 'Clara + monthly',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textTertiary,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                amount == null
                    ? '—'
                    : formatCurrency(
                        amount,
                        symbol,
                        abbreviate: false,
                        withCommas: true,
                      ),
                style: AppTypography.bodyLarge.copyWith(
                  color: context.textPrimary,
                  fontVariations: const [FontVariation('wght', 600)],
                  fontSize: 24,
                ),
              ),
              Text(
                isYearly ? 'Yearly' : 'Monthly',
                style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          subscription.isTrialing
              ? 'Your free trial is active through'
              : isEnding
                  ? 'Your Clara + subscription ends on'
                  : 'Your Clara + subscription is active through',
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
            fontVariations: const [FontVariation('wght', 500)],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _periodLabel(isEnding ? null : start, end),
          style: AppTypography.headingLarge.copyWith(color: context.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: isEnding ? 'Resume subscription' : 'Cancel subscription',
          onTap: () async {
            if (isEnding) {
              Navigator.of(context).pop();
              onResume();
              return;
            }
            Navigator.of(context).pop();
            await showCancellationSheet(context);
          },
          height: 48,
        ),
      ],
    );
  }

  String _periodLabel(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      return '${_dateFormat.format(start)} – ${_dateFormat.format(end)}';
    }
    if (end != null) return _dateFormat.format(end);
    return '—';
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton(
          width: double.infinity,
          height: 108,
          borderRadius: AppRadius.radiusSheet,
        ),
        const SizedBox(height: AppSpacing.base),
        const AppSkeleton.text(width: 220),
        const SizedBox(height: AppSpacing.xs),
        const AppSkeleton.text(width: 260, height: 26),
        const SizedBox(height: AppSpacing.xl),
        AppSkeleton(
          width: double.infinity,
          height: 48,
          borderRadius: AppRadius.radiusFull,
        ),
      ],
    );
  }
}
