import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppFonts {
  // Bricolage Grotesque — headings, display, brand moments (wght: 200–800)
  static const String display = 'BricolageGrotesque';

  // Geist — body text, labels, inputs, data, amounts (wght: 100–900)
  static const String body = 'Geist';
}

abstract class AppTypography {
  // Display — Bricolage Grotesque
  static const TextStyle displayLarge = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 32,
    fontVariations: [FontVariation('wght', 600)],
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 29,
    fontVariations: [FontVariation('wght', 700)],
    color: AppColors.textPrimary,
    height: 1.32,
    letterSpacing: 0,
  );

  // Headings — Bricolage Grotesque
  static const TextStyle headingLarge = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 24,
    fontVariations: [FontVariation('wght', 600)],
    color: AppColors.textPrimary,
    height: 1.33,
    letterSpacing: 0,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 24,
    fontVariations: [FontVariation('wght', 500)],
    color: AppColors.textPrimary,
    height: 1.33,
    letterSpacing: 0,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 20,
    fontVariations: [FontVariation('wght', 500)],
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0,
  );

  // Body — Geist
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontVariations: [FontVariation('wght', 400)],
    color: AppColors.textSecondary,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    fontVariations: [FontVariation('wght', 400)],
    color: AppColors.textSecondary,
    height: 1.43,
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    fontVariations: [FontVariation('wght', 400)],
    color: AppColors.textSecondary,
    height: 1.33,
    letterSpacing: 0,
  );

  // Labels — Geist Medium
  static const TextStyle labelLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontVariations: [FontVariation('wght', 500)],
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontVariations: [FontVariation('wght', 500)],
    color: AppColors.textPrimary,
    height: 1.43,
    // letterSpacing: 0,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    fontVariations: [FontVariation('wght', 400)],
    color: AppColors.textSecondary,
    height: 1.33,
    // letterSpacing: 0,
  );

  static const TextStyle labelXSmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 10,
    fontVariations: [FontVariation('wght', 500)],
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.4,
  );

  // Financial amounts — Geist
  static const TextStyle amountLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 32,
    fontVariations: [FontVariation('wght', 500)],
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle amountMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 24,
    fontVariations: [FontVariation('wght', 600)],
    color: AppColors.textPrimary,
    height: 1.33,
    letterSpacing: 0,
  );

  static const TextStyle amountSmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontVariations: [FontVariation('wght', 600)],
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0,
  );

  // Keypad numbers — Geist Medium
  static const TextStyle keypad = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 24,
    fontVariations: [FontVariation('wght', 500)],
    color: AppColors.textQuaternary,
    height: 1.5,
    letterSpacing: 0,
  );

  // Error / validation text
  static const TextStyle errorText = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontVariations: [FontVariation('wght', 400)],
    color: AppColors.error,
    height: 1.33,
    letterSpacing: 0,
  );

  // Button label
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontVariations: [FontVariation('wght', 500)],
    color: AppColors.white,
    height: 1.5,
    letterSpacing: 0,
  );

  // Link text
  static const TextStyle link = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontVariations: [FontVariation('wght', 400)],
    color: AppColors.primary,
    height: 1.43,
    letterSpacing: 0,
  );
}
