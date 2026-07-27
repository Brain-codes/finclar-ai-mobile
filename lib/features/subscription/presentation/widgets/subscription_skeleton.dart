import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_skeleton.dart';

class SubscriptionSkeleton extends StatelessWidget {
  const SubscriptionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppSkeleton.circle(size: 56),
          const SizedBox(height: AppSpacing.base),
          const AppSkeleton.text(width: 180, height: 26),
          const SizedBox(height: AppSpacing.sm),
          const AppSkeleton.text(width: double.infinity),
          const SizedBox(height: AppSpacing.xs),
          const AppSkeleton.text(width: 240),
          const SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < 7; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.base),
              child: Row(
                children: [
                  AppSkeleton.circle(size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: AppSkeleton.text(width: double.infinity)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppSkeleton(
                  width: double.infinity,
                  height: 116,
                  borderRadius: AppRadius.radiusSheet,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppSkeleton(
                  width: double.infinity,
                  height: 116,
                  borderRadius: AppRadius.radiusSheet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
