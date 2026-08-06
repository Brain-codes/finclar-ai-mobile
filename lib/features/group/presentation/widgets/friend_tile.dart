import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_profile_avatar.dart';
import '../../data/models/friendship_model.dart';

class FriendTile extends StatelessWidget {
  final FriendshipModel friendship;
  final VoidCallback? onTap;

  const FriendTile({super.key, required this.friendship, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusCard,
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            AppProfileAvatar(
              profileIcon: friendship.friendProfileIcon,
              name: friendship.friendUsername,
              size: 40,
              seedWhenEmpty: true,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    friendship.friendUsername,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textPrimary,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                  Text(
                    friendship.friendEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall
                        .copyWith(color: context.textSecondary),
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
