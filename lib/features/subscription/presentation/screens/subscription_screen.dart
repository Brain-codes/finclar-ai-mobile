import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/services/paystack_checkout_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../data/models/plan_model.dart';
import '../../providers/subscription_providers.dart';
import '../widgets/subscription_feature_row.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/subscription_skeleton.dart';

const _featureColors = [
  AppColors.settingsRed,
  AppColors.primary,
  AppColors.categoryShopping,
  AppColors.settingsCoral,
  AppColors.settingsBrown,
  AppColors.primary,
  AppColors.settingsDeepNavy,
];

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  PlanCode _selected = PlanCode.yearly;
  bool _isProcessing = false;

  Future<void> _startCheckout(PlansResponseModel plans) async {
    final plan = plans.byCode(_selected);
    if (plan == null) return;

    final email = ref.read(userProfileProvider).valueOrNull?.email;
    if (email == null) {
      AppSnackbar.error(context, 'We could not read your account email.');
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final reference = await PaystackCheckoutService.start(
        context,
        publicKey: plans.paystackPublicKey,
        email: email,
        amountMinor: plan.amount,
        currency: plan.currency,
      );

      // Null means the user closed checkout — not an error worth surfacing.
      if (reference == null) return;
      if (!mounted) return;

      await ref
          .read(subscriptionProvider.notifier)
          .verifyCheckout(reference: reference, planCode: _selected);

      if (!mounted) return;
      AppSnackbar.success(context, 'You are now on Clara +');
      if (context.canPop()) context.pop();
    } catch (e) {
      if (mounted) AppSnackbar.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final symbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: Stack(
        children: [
          Positioned(
            top: -74,
            left: -30,
            child: Container(
              width: 443,
              height: 206,
              decoration: const BoxDecoration(
                color: Color(0x80FEE0CD),
                borderRadius: BorderRadius.all(Radius.elliptical(221.5, 103)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppTopBar(onBack: () => context.pop(), circleBack: true),
                Expanded(
                  child: plansAsync.when(
                    loading: () => const SubscriptionSkeleton(),
                    error: (e, _) => _ErrorState(
                      onRetry: () => ref.invalidate(subscriptionPlansProvider),
                    ),
                    data: (plans) => _Content(
                      plans: plans,
                      selected: _selected,
                      symbol: symbol,
                      onChanged: (p) => setState(() => _selected = p),
                    ),
                  ),
                ),
                plansAsync.maybeWhen(
                  data: (plans) => _BottomBar(
                    plan: plans.byCode(_selected),
                    symbol: symbol,
                    isLoading: _isProcessing,
                    onTap: () => _startCheckout(plans),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final PlansResponseModel plans;
  final PlanCode selected;
  final String symbol;
  final ValueChanged<PlanCode> onChanged;

  const _Content({
    required this.plans,
    required this.selected,
    required this.symbol,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final features = plans.byCode(selected)?.features ?? const <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primaryMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.crown, size: 24, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Go Unlimited',
            style: AppTypography.headingLarge.copyWith(color: context.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Get AI intelligence, deeper insights and tools that help you understand your money and change your life',
            style: AppTypography.bodySmall.copyWith(color: context.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < features.length; i++)
            SubscriptionFeatureRow(
              color: _featureColors[i % _featureColors.length],
              text: features[i],
            ),
          const SizedBox(height: AppSpacing.xl),
          _PlanSelector(
            plans: plans,
            selected: selected,
            symbol: symbol,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _PlanSelector extends StatelessWidget {
  final PlansResponseModel plans;
  final PlanCode selected;
  final String symbol;
  final ValueChanged<PlanCode> onChanged;

  const _PlanSelector({
    required this.plans,
    required this.selected,
    required this.symbol,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final monthly = plans.byCode(PlanCode.monthly);
    final yearly = plans.byCode(PlanCode.yearly);
    final savings = yearly?.savingsPercent;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            if (monthly != null)
              Expanded(
                child: SubscriptionPlanCard(
                  plan: monthly,
                  symbol: symbol,
                  isSelected: selected == PlanCode.monthly,
                  onTap: () => onChanged(PlanCode.monthly),
                ),
              ),
            if (monthly != null && yearly != null)
              const SizedBox(width: AppSpacing.sm),
            if (yearly != null)
              Expanded(
                child: SubscriptionPlanCard(
                  plan: yearly,
                  symbol: symbol,
                  isSelected: selected == PlanCode.yearly,
                  onTap: () => onChanged(PlanCode.yearly),
                ),
              ),
          ],
        ),
        if (savings != null)
          Positioned(
            top: -12,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Save $savings%',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "We couldn't load the plans",
              style: AppTypography.headingSmall.copyWith(color: context.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.base),
            AppButton(label: 'Try again', onTap: onRetry, height: 48),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final PlanModel? plan;
  final String symbol;
  final bool isLoading;
  final VoidCallback onTap;

  const _BottomBar({
    required this.plan,
    required this.symbol,
    required this.isLoading,
    required this.onTap,
  });

  String get _label {
    final trialDays = plan?.trialDays ?? 0;
    return trialDays > 0 ? 'Start $trialDays-Days Free Trial' : 'Subscribe';
  }

  String get _finePrint {
    final current = plan;
    if (current == null) return '';
    final price = formatCurrency(
      current.majorAmount,
      symbol,
      abbreviate: false,
      withCommas: true,
    );
    final period = current.isYearly ? 'year' : 'month';
    final prefix = current.trialDays > 0 ? 'Then ' : '';
    return '$prefix$price /$period. Cancel anytime before renewal.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor)),
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
          AppButton(
            label: _label,
            onTap: plan == null ? null : onTap,
            isLoading: isLoading,
            height: 48,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _finePrint,
            style: AppTypography.bodyMedium.copyWith(color: context.textTertiary),
          ),
        ],
      ),
    );
  }
}
