import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../providers/home_dashboard_provider.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final summary = ref.watch(homeSummaryProvider);

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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  summary.when(
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
                      onTap: () => ref.invalidate(homeSummaryProvider),
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
                    data: (s) => Text(
                      formatCurrency(s.balance, symbol,
                          abbreviate: false, withCommas: true),
                      style: AppTypography.amountLarge
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
