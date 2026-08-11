import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ClaraEmptyState extends StatelessWidget {
  const ClaraEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: context.borderColor),
            ),
            child: Image.asset(
              'assets/images/clara-chat-dp.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'No Insights Yet',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
              fontSize: 14,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Add your expenses, income, and Clara AI will start giving you smart money insights.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
