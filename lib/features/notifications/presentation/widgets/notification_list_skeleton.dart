import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_skeleton.dart';

class NotificationListSkeleton extends StatelessWidget {
  final int count;

  const NotificationListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.radiusCard,
              border: Border.all(color: context.borderColor),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(
                  width: 40,
                  height: 40,
                  borderRadius: AppRadius.radiusCard,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton.text(width: 140),
                      SizedBox(height: AppSpacing.sm),
                      AppSkeleton.text(width: double.infinity, height: 12),
                      SizedBox(height: AppSpacing.xs),
                      AppSkeleton.text(width: 60, height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
