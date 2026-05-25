import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_svg_image.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/extensions/context_extensions.dart';

enum AppButtonVariant {
  /// Orange filled — primary CTA
  primary,

  /// surfaceVariant filled — social / secondary actions
  secondary,

  /// Transparent with border — outline actions
  outline,

  /// Text only, no background or border — ghost / skip actions
  ghost,

  /// Red filled — destructive actions (delete, account removal)
  danger,
}

/// The single button widget used across the entire app.
///
/// Usage:
/// ```dart
/// AppButton(label: 'Continue', onTap: _submit)
/// AppButton(label: 'Continue', onTap: _submit, isLoading: true)
/// AppButton(label: 'Google', onTap: _google, variant: AppButtonVariant.secondary, icon: AppIcons.email)
/// AppButton(label: 'Skip for now', onTap: _skip, variant: AppButtonVariant.ghost)
/// AppButton(label: 'Create account', onTap: null) // disabled
/// ```
class AppButton extends StatelessWidget {
  final String label;

  /// Null = disabled state
  final VoidCallback? onTap;

  final bool isLoading;
  final AppButtonVariant variant;

  /// Optional leading icon (remixicon)
  final IconData? icon;

  /// Optional leading SVG icon — use AppSvg.* for the path
  final String? svgIcon;

  /// Defaults true — stretches to full available width
  final bool fullWidth;

  /// Fixed height — defaults to 52 (design system standard)
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.svgIcon,
    this.fullWidth = true,
    this.height = 52,
  });

  bool get _isDisabled => onTap == null;

  @override
  Widget build(BuildContext context) {
    final inner = SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: switch (variant) {
        AppButtonVariant.primary => _PrimaryButton(button: this),
        AppButtonVariant.secondary => _SecondaryButton(
          button: this,
          context: context,
        ),
        AppButtonVariant.outline => _OutlineButton(
          button: this,
          context: context,
        ),
        AppButtonVariant.ghost => _GhostButton(button: this, context: context),
        AppButtonVariant.danger => _DangerButton(button: this),
      },
    );
    return fullWidth ? inner : IntrinsicWidth(child: inner);
  }
}

// ─── Primary ──────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final AppButton button;
  const _PrimaryButton({required this.button});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: button.isLoading ? 0.6 : 1.0,
      child: ElevatedButton(
        onPressed: (button._isDisabled || button.isLoading)
            ? null
            : button.onTap,
        child: _ButtonChild(button: button, textColor: AppColors.white),
      ),
    );
  }
}

// ─── Secondary ────────────────────────────────────────────────────────────────

class _SecondaryButton extends StatelessWidget {
  final AppButton button;
  final BuildContext context;
  const _SecondaryButton({required this.button, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: button._isDisabled ? null : button.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: button._isDisabled
              ? ctx.surfaceVariant.withValues(alpha: 0.5)
              : ctx.surfaceVariant,
          borderRadius: AppRadius.radiusFull,
        ),
        alignment: Alignment.center,
        child: _ButtonChild(button: button, textColor: ctx.textSecondary),
      ),
    );
  }
}

// ─── Outline ──────────────────────────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  final AppButton button;
  final BuildContext context;
  const _OutlineButton({required this.button, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: button._isDisabled ? null : button.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppRadius.radiusFull,
          border: Border.all(
            color: button._isDisabled ? ctx.borderColor : AppColors.primary,
          ),
        ),
        alignment: Alignment.center,
        child: _ButtonChild(
          button: button,
          textColor: button._isDisabled ? ctx.textSecondary : AppColors.primary,
        ),
      ),
    );
  }
}

// ─── Danger ───────────────────────────────────────────────────────────────────

class _DangerButton extends StatelessWidget {
  final AppButton button;
  const _DangerButton({required this.button});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: button._isDisabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: button._isDisabled ? null : button.onTap,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.error,
            borderRadius: AppRadius.radiusFull,
          ),
          alignment: Alignment.center,
          child: _ButtonChild(button: button, textColor: AppColors.white),
        ),
      ),
    );
  }
}

// ─── Ghost ────────────────────────────────────────────────────────────────────

class _GhostButton extends StatelessWidget {
  final AppButton button;
  final BuildContext context;
  const _GhostButton({required this.button, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: button._isDisabled ? null : button.onTap,
      child: Container(
        alignment: Alignment.center,
        child: _ButtonChild(
          button: button,
          textColor: button._isDisabled ? ctx.textSecondary : ctx.textSecondary,
        ),
      ),
    );
  }
}

// ─── Shared child ─────────────────────────────────────────────────────────────

class _ButtonChild extends StatelessWidget {
  final AppButton button;
  final Color textColor;

  const _ButtonChild({required this.button, required this.textColor});

  @override
  Widget build(BuildContext context) {
    if (button.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            button.label,
            style: AppTypography.buttonLabel.copyWith(color: textColor),
          ),
          const SizedBox(width: 10),
          CupertinoActivityIndicator(color: textColor, radius: 9),
        ],
      );
    }

    if (button.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(button.icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Text(
            button.label,
            style: AppTypography.buttonLabel.copyWith(color: textColor),
          ),
        ],
      );
    }

    if (button.svgIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgImage(button.svgIcon!, width: 20, height: 20),
          const SizedBox(width: 8),
          Text(
            button.label,
            style: AppTypography.buttonLabel.copyWith(color: textColor),
          ),
        ],
      );
    }

    return Text(
      button.label,
      style: AppTypography.buttonLabel.copyWith(color: textColor),
    );
  }
}
