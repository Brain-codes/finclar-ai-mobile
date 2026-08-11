import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/notification_model.dart';

IconData notificationIcon(NotificationType type) {
  switch (type) {
    case NotificationType.budgetNearLimit:
      return AppIcons.budget;
    case NotificationType.friendInvite:
      return AppIcons.addUser;
    case NotificationType.groupInvite:
    case NotificationType.groupActivity:
      return AppIcons.group;
    case NotificationType.bankSyncCompleted:
      return AppIcons.bank;
    case NotificationType.subscriptionActivated:
      return AppIcons.crown;
    case NotificationType.unknown:
      return AppIcons.info;
  }
}

Color notificationColor(NotificationType type) {
  switch (type) {
    case NotificationType.budgetNearLimit:
      return AppColors.warning;
    case NotificationType.friendInvite:
    case NotificationType.groupInvite:
    case NotificationType.groupActivity:
      return AppColors.info;
    case NotificationType.bankSyncCompleted:
      return AppColors.success;
    case NotificationType.subscriptionActivated:
      return AppColors.primary;
    case NotificationType.unknown:
      return AppColors.info;
  }
}

Color notificationBgColor(BuildContext context, NotificationType type) {
  switch (type) {
    case NotificationType.budgetNearLimit:
      return context.warningBg;
    case NotificationType.friendInvite:
    case NotificationType.groupInvite:
    case NotificationType.groupActivity:
      return context.infoBg;
    case NotificationType.bankSyncCompleted:
      return context.successBg;
    case NotificationType.subscriptionActivated:
      return context.primaryMuted;
    case NotificationType.unknown:
      return context.infoBg;
  }
}
