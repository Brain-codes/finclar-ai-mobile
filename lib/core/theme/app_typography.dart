import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppFonts {
  // Bricolage Grotesque — headings, display, brand moments
  static const String display = 'BricolageGrotesque';

  // Geist — body text, labels, inputs, data, amounts
  static const String body = 'Geist';
}

abstract class AppTypography {
  // Display — Bricolage Grotesque (splash "Meet Clara" style)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.32, // 37px line height / 28px = ~1.32
    letterSpacing: 0,
  );

  // Headings — Bricolage Grotesque (screen titles e.g. "Create account", "Add income")
  static const TextStyle headingLarge = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.33, // 32px / 24px
    letterSpacing: 0,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.33,
    letterSpacing: 0,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0,
  );

  // Body — Geist
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5, // 24px / 16px
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.43, // 20px / 14px
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.33, // 16px / 12px
    letterSpacing: 0,
  );

  // Labels — Geist Medium
  static const TextStyle labelLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.43,
    letterSpacing: 0,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.33,
    letterSpacing: 0,
  );

  static const TextStyle labelXSmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.4,
  );

  // Financial amounts — Geist (balance card, transaction values)
  static const TextStyle amountLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.25, // 40px / 32px
    letterSpacing: 0,
  );

  static const TextStyle amountMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.33,
    letterSpacing: 0,
  );

  static const TextStyle amountSmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0,
  );

  // Keypad numbers — Geist Medium (income/passcode entry)
  static const TextStyle keypad = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textQuaternary,
    height: 1.5,
    letterSpacing: 0,
  );

  // Error / validation text
  static const TextStyle errorText = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.33,
    letterSpacing: 0,
  );

  // Link text (e.g. "Login", "Resend in 00:45")
  static const TextStyle link = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    height: 1.43,
    letterSpacing: 0,
  );
}
