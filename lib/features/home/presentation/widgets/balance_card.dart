import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../providers/home_dashboard_provider.dart';
import '../../providers/income_setup_provider.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    // available_balance is computed by the backend — use it rather than
    // deriving income − expenses here, so the two can't drift apart.
    final insight = ref.watch(homeInsightProvider);
    final income = ref.watch(incomeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.radiusCardLarge,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xl,
        ),
        child: Row(
          // Top-aligned so the action sits level with the "Available balance"
          // label in the card's top-right corner, not beside the amount.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.availableBalance,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  insight.when(
                    loading: () => const SizedBox(
                      height: 32,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoActivityIndicator(
                          radius: 12,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    error: (_, _) => GestureDetector(
                      onTap: () => ref.invalidate(homeInsightProvider),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '—',
                            style: AppTypography.amountLarge
                                .copyWith(color: AppColors.white),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            AppIcons.refresh,
                            size: 18,
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ),
                    // Shrinks rather than overflowing — the pill beside it
                    // takes width, and a large balance in a wide-symbol
                    // currency (CA$, KSh) would otherwise clip.
                    data: (s) => FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatCurrency(s.availableBalance, symbol,
                            abbreviate: false, withCommas: true),
                        maxLines: 1,
                        style: AppTypography.amountLarge
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Always-visible entry point to income. The setup modal only fires
            // when income is null and only on the home listener — if it's
            // missed or dismissed there is otherwise nothing on screen that
            // says income can be set at all.
            _IncomeAction(hasIncome: income.valueOrNull != null),
          ],
        ),
      ),
    );
  }
}

/// Once income exists this is just a pencil — the card's job is the balance,
/// not a standing call to action. It only becomes a labelled button when
/// income is missing, because then it *is* the thing the user needs to do.
class _IncomeAction extends StatelessWidget {
  final bool hasIncome;
  const _IncomeAction({required this.hasIncome});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.incomeSetup),
      behavior: HitTestBehavior.opaque,
      child: hasIncome
          ? Semantics(
              button: true,
              label: 'Edit income',
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.edit,
                  size: 16,
                  color: AppColors.white,
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.add, size: 14, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Add income',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontVariations: const [FontVariation('wght', 600)],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
