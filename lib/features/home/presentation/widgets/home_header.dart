import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String greeting;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final bool isLoading;

  const HomeHeader({
    super.key,
    this.userName = 'Chinasa',
    this.greeting = 'Good evening',
    this.onNotificationTap,
    this.onAvatarTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: AppAvatar(
            initials: userName,
            size: 40,
            icon: AppIcons.userFill,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
              ),
              Text(
                userName,
                style: AppTypography.labelLarge.copyWith(
                  color: context.textPrimary,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: CupertinoActivityIndicator(radius: 10),
            ),
          )
        else
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: context.borderColor),
              ),
              child: Icon(AppIcons.notification, color: context.textSecondary, size: 20),
            ),
          ),
      ],
    );
  }
}

class HomeHeaderWithRadius extends StatelessWidget {
  final String userName;
  final String greeting;
  final VoidCallback? onNotificationTap;

  const HomeHeaderWithRadius({
    super.key,
    this.userName = 'Chinasa',
    this.greeting = 'Good evening',
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        borderRadius: AppRadius.radiusCardLarge,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.base,
      ),
      child: HomeHeader(
        userName: userName,
        greeting: greeting,
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}
