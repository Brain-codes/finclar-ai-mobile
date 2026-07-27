import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/notification_model.dart';

IconData notificationIcon(NotificationType type) {
  switch (type) {
    case NotificationType.transaction:
      return AppIcons.transfer;
    case NotificationType.budget:
      return AppIcons.budget;
    case NotificationType.group:
      return AppIcons.group;
    case NotificationType.insight:
      return AppIcons.ai;
    case NotificationType.system:
      return AppIcons.info;
  }
}

Color notificationColor(NotificationType type) {
  switch (type) {
    case NotificationType.transaction:
      return AppColors.primary;
    case NotificationType.budget:
      return AppColors.warning;
    case NotificationType.group:
      return AppColors.info;
    case NotificationType.insight:
      return AppColors.success;
    case NotificationType.system:
      return AppColors.info;
  }
}

Color notificationBgColor(BuildContext context, NotificationType type) {
  switch (type) {
    case NotificationType.transaction:
      return context.primaryMuted;
    case NotificationType.budget:
      return context.warningBg;
    case NotificationType.group:
      return context.infoBg;
    case NotificationType.insight:
      return context.successBg;
    case NotificationType.system:
      return context.infoBg;
  }
}
