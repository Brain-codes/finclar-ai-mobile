import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../widgets/subscription_feature_row.dart';
import '../widgets/subscription_plan_card.dart';

const _features = [
  (color: AppColors.settingsRed, text: 'Advanced analytics, spending trends and habit tracking'),
  (color: AppColors.primary, text: 'Deep AI insights, emotional spending analysis and personalized coaching'),
  (color: AppColors.categoryShopping, text: 'Multiple account integrations'),
  (color: AppColors.settingsCoral, text: 'Yearly, monthly and unlimited sharing'),
  (color: AppColors.settingsBrown, text: 'Unlimited receipt scans'),
  (color: AppColors.primary, text: 'Unlimited saving groups with leaderboards'),
  (color: AppColors.settingsDeepNavy, text: 'Advanced savings projections, goal tracking and financial forecast'),
];

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionPlan _selected = SubscriptionPlan.yearly;

  String get _finePrint => _selected == SubscriptionPlan.yearly
      ? 'Then ₦28,000 /year. Cancel anytime before renewal.'
      : 'Then ₦3,000 /month. Cancel anytime before renewal.';

  @override
  Widget build(BuildContext context) {
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
              decoration: BoxDecoration(
                color: const Color(0x80FEE0CD),
                borderRadius: BorderRadius.all(Radius.elliptical(221.5, 103)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppTopBar(onBack: () => context.pop(), circleBack: true),
                Expanded(
                  child: SingleChildScrollView(
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
                        for (final f in _features)
                          SubscriptionFeatureRow(color: f.color, text: f.text),
                        const SizedBox(height: AppSpacing.xl),
                        _PlanSelector(
                          selected: _selected,
                          onChanged: (p) => setState(() => _selected = p),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                _BottomBar(finePrint: _finePrint),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanSelector extends StatelessWidget {
  final SubscriptionPlan selected;
  final ValueChanged<SubscriptionPlan> onChanged;

  const _PlanSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            Expanded(
              child: SubscriptionPlanCard(
                plan: SubscriptionPlan.monthly,
                isSelected: selected == SubscriptionPlan.monthly,
                onTap: () => onChanged(SubscriptionPlan.monthly),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SubscriptionPlanCard(
                plan: SubscriptionPlan.yearly,
                isSelected: selected == SubscriptionPlan.yearly,
                onTap: () => onChanged(SubscriptionPlan.yearly),
              ),
            ),
          ],
        ),
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
              'Save 5%',
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

class _BottomBar extends StatelessWidget {
  final String finePrint;

  const _BottomBar({required this.finePrint});

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
            label: 'Start 7-Days Free Trial',
            onTap: () {},
            height: 48,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            finePrint,
            style: AppTypography.bodyMedium.copyWith(color: context.textTertiary),
          ),
        ],
      ),
    );
  }
}
