import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// Single color API for widgets.
// Always use context.* here — never reach into AppColors directly for adaptive colors.
// Only AppColors.primary, AppColors.white, AppColors.black, semantic foregrounds,
// and category foregrounds are safe to use directly (they don't change between modes).
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ─── Brand ────────────────────────────────────────────────────────────────
  Color get primaryMuted => isDark ? AppColors.primaryMutedDark : AppColors.primaryMuted;
  Color get primaryLight => isDark ? AppColors.primaryLightDark : AppColors.primaryLight;

  // ─── Background & Surface ─────────────────────────────────────────────────
  Color get scaffoldColor    => isDark ? AppColors.darkBackground     : AppColors.background;
  Color get surfaceColor     => isDark ? AppColors.darkSurface        : AppColors.surface;
  Color get surfaceVariant   => isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
  Color get surfaceMuted     => isDark ? AppColors.darkSurfaceMuted   : AppColors.surfaceMuted;

  // ─── Border ───────────────────────────────────────────────────────────────
  Color get borderColor      => isDark ? AppColors.darkBorder       : AppColors.border;
  Color get borderStrong     => isDark ? AppColors.darkBorderStrong : AppColors.borderStrong;

  // ─── Text ─────────────────────────────────────────────────────────────────
  Color get textPrimary      => isDark ? AppColors.darkTextPrimary    : AppColors.textPrimary;
  Color get textSecondary    => isDark ? AppColors.darkTextSecondary  : AppColors.textSecondary;
  Color get textTertiary     => isDark ? AppColors.darkTextTertiary   : AppColors.textTertiary;
  Color get textQuaternary   => isDark ? AppColors.darkTextQuaternary : AppColors.textQuaternary;

  // ─── Input ────────────────────────────────────────────────────────────────
  Color get inputFill        => isDark ? AppColors.darkInputFill        : AppColors.inputFill;
  Color get inputBorder      => isDark ? AppColors.darkInputBorder      : AppColors.inputBorder;
  Color get inputPlaceholder => isDark ? AppColors.darkInputPlaceholder : AppColors.inputPlaceholder;

  // ─── Skeleton ─────────────────────────────────────────────────────────────
  Color get skeletonColor    => isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;

  // ─── Semantic backgrounds (foreground colors are fixed — use AppColors.*) ──
  Color get errorBg          => isDark ? AppColors.errorDark   : AppColors.errorLight;
  Color get successBg        => isDark ? AppColors.successDark : AppColors.successLight;
  Color get warningBg        => isDark ? AppColors.warningDark : AppColors.warningLight;
  Color get infoBg           => isDark ? AppColors.infoDark    : AppColors.infoLight;

  // Text/icon colors to pair with successBg / warningBg. Both directions clear
  // WCAG AA — the base hues do not (only ~3:1 on their own light backgrounds).
  Color get successOn        => isDark ? AppColors.successLight : AppColors.successOn;
  Color get warningOn        => isDark ? AppColors.warningLight : AppColors.warningOn;

  // ─── Category chip backgrounds ────────────────────────────────────────────
  Color get categoryFoodBg       => isDark ? AppColors.categoryFoodBgDark       : AppColors.categoryFoodBg;
  Color get categoryTransportBg  => isDark ? AppColors.categoryTransportBgDark  : AppColors.categoryTransportBg;
  Color get categoryHealthBg     => isDark ? AppColors.categoryHealthBgDark     : AppColors.categoryHealthBg;
  Color get categoryShoppingBg   => isDark ? AppColors.categoryShoppingBgDark   : AppColors.categoryShoppingBg;

  // ─── Clara AI card ────────────────────────────────────────────────────────
  Color get claraCardBg => isDark ? AppColors.claraCardBgDark : AppColors.claraCardBg;
  Color get claraLabel  => isDark ? AppColors.claraLabelDark  : AppColors.claraLabel;
}
