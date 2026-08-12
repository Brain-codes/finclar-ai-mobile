import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../providers/wrapped_banner_provider.dart';

/// Home announcement that a month's recap is ready. Only paints inside the
/// end-of-month window — see [wrappedBannerProvider].
class WrappedBanner extends ConsumerWidget {
  const WrappedBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(wrappedBannerProvider).valueOrNull;
    if (period == null) return const SizedBox.shrink();

    final month = DateFormat('MMMM').format(period);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: GestureDetector(
        onTap: () =>
            context.push(RouteNames.wrappedFor(period.year, period.month)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: context.isDark
                ? AppColors.primaryMutedDark
                : AppColors.primaryMuted,
            borderRadius: AppRadius.radiusCard,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  AppIcons.passport,
                  size: 20,
                  color: AppColors.onPrimaryDeep,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your $month wrap is here',
                      style: AppTypography.labelMedium.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to see your money passport',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(wrappedBannerProvider.notifier).dismiss(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    AppIcons.close,
                    size: 18,
                    color: context.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
