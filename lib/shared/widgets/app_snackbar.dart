import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../icons/app_icons.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _SnackbarContent(
          message: message,
          type: type,
          title: title,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(AppSpacing.base),
        padding: EdgeInsets.zero,
      ),
    );
  }

  static void success(BuildContext context, String message, {String? title}) =>
      show(context, message: message, type: SnackbarType.success, title: title);

  static void error(BuildContext context, String message, {String? title}) =>
      show(context, message: message, type: SnackbarType.error, title: title);

  static void warning(BuildContext context, String message, {String? title}) =>
      show(context, message: message, type: SnackbarType.warning, title: title);

  static void info(BuildContext context, String message, {String? title}) =>
      show(context, message: message, type: SnackbarType.info, title: title);
}

class _SnackbarContent extends StatelessWidget {
  final String message;
  final SnackbarType type;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SnackbarContent({
    required this.message,
    required this.type,
    this.title,
    this.actionLabel,
    this.onAction,
  });

  _SnackbarStyle get _style => switch (type) {
        SnackbarType.success => _SnackbarStyle(
            background: AppColors.textPrimary,
            iconColor: AppColors.success,
            icon: AppIcons.success,
            indicator: AppColors.success,
          ),
        SnackbarType.error => _SnackbarStyle(
            background: AppColors.textPrimary,
            iconColor: AppColors.error,
            icon: AppIcons.error,
            indicator: AppColors.error,
          ),
        SnackbarType.warning => _SnackbarStyle(
            background: AppColors.textPrimary,
            iconColor: AppColors.warning,
            icon: AppIcons.warning,
            indicator: AppColors.warning,
          ),
        SnackbarType.info => _SnackbarStyle(
            background: AppColors.textPrimary,
            iconColor: AppColors.info,
            icon: AppIcons.info,
            indicator: AppColors.info,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return Container(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: AppRadius.radiusCard,
        border: Border(
          left: BorderSide(color: style.indicator, width: 4),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(style.icon, color: style.iconColor, size: 20),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTypography.labelLarge.copyWith(color: AppColors.white),
                  ),
                  AppSpacing.verticalXs,
                ],
                Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            AppSpacing.horizontalMd,
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.labelMedium.copyWith(color: style.indicator),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SnackbarStyle {
  final Color background;
  final Color iconColor;
  final IconData icon;
  final Color indicator;

  const _SnackbarStyle({
    required this.background,
    required this.iconColor,
    required this.icon,
    required this.indicator,
  });
}
