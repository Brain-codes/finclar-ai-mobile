import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
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
    final style = _styleFor(type);

    toastification.show(
      context: context,
      type: style.toastType,
      style: ToastificationStyle.flat,
      title: title != null
          ? Text(
              title,
              style: AppTypography.labelLarge.copyWith(color: AppColors.white),
            )
          : null,
      description: Text(
        message,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.white.withValues(alpha: 0.75),
        ),
      ),
      icon: Icon(style.icon, color: style.iconColor, size: 20),
      primaryColor: style.indicatorColor,
      backgroundColor: AppColors.textPrimary,
      foregroundColor: AppColors.white,
      borderRadius: AppRadius.radiusCard,
      showProgressBar: false,
      autoCloseDuration: duration,
      alignment: Alignment.topLeft,
      dragToClose: true,
      applyBlurEffect: true,
      animationBuilder: (context, animation, alignment, child) =>
          FadeTransition(opacity: animation, child: child),
      callbacks: ToastificationCallbacks(
        onTap: onAction != null && actionLabel != null
            ? (_) => onAction()
            : null,
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

  static _SnackbarStyle _styleFor(SnackbarType type) => switch (type) {
    SnackbarType.success => _SnackbarStyle(
      toastType: ToastificationType.success,
      icon: AppIcons.success,
      iconColor: AppColors.success,
      indicatorColor: AppColors.success,
    ),
    SnackbarType.error => _SnackbarStyle(
      toastType: ToastificationType.error,
      icon: AppIcons.error,
      iconColor: AppColors.error,
      indicatorColor: AppColors.error,
    ),
    SnackbarType.warning => _SnackbarStyle(
      toastType: ToastificationType.warning,
      icon: AppIcons.warning,
      iconColor: AppColors.warning,
      indicatorColor: AppColors.warning,
    ),
    SnackbarType.info => _SnackbarStyle(
      toastType: ToastificationType.info,
      icon: AppIcons.info,
      iconColor: AppColors.info,
      indicatorColor: AppColors.info,
    ),
  };
}

class _SnackbarStyle {
  final ToastificationType toastType;
  final IconData icon;
  final Color iconColor;
  final Color indicatorColor;

  const _SnackbarStyle({
    required this.toastType,
    required this.icon,
    required this.iconColor,
    required this.indicatorColor,
  });
}
