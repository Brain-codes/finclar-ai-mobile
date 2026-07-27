import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../icons/app_icons.dart';

// Floating Clara chat launcher shown on every bottom-nav page (see AppShell).
class ClaraFab extends StatelessWidget {
  const ClaraFab({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.clara),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: AppColors.claraGradient,
          borderRadius: AppRadius.radiusFull,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.aiFill, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Ask Clara',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white,
                fontSize: 14,
                fontVariations: const [FontVariation('wght', 600)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
