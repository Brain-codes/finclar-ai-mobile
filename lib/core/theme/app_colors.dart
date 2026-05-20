import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand / Primary — orange from Figma buttons, balance card
  static const Color primary = Color(0xFFFF751F);
  static const Color primaryLight = Color(0xFFFFF8F7);  // very light orange tint
  static const Color primaryMuted = Color(0xFFFFF7ED);  // orange wash background
  static const Color primaryDark = Color(0xFFCC4E00);   // darker orange for states
  static const Color primaryHover = Color(0xFFEF5F00);  // hover/pressed state

  // Text
  static const Color textPrimary = Color(0xFF101010);   // headings, main content
  static const Color textSecondary = Color(0xFF928F8B); // subtitles, hints, labels
  static const Color textTertiary = Color(0xFF65605C);  // placeholder, muted values
  static const Color textQuaternary = Color(0xFF4D4845); // keypad numbers, lightest text

  // Surface & Background
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAFA);    // screen background
  static const Color surface = Color(0xFFFFFFFF);       // cards, sheets
  static const Color surfaceVariant = Color(0xFFF6F6F4); // secondary surface
  static const Color surfaceMuted = Color(0xFFEFEFED);  // muted surface

  // Borders & Dividers
  static const Color border = Color(0xFFF4F4F2);        // default input border, dividers
  static const Color borderStrong = Color(0xFFE7E7E4);  // stronger borders, close buttons

  // Input
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFF4F4F2);
  static const Color inputPlaceholder = Color(0xFFDBDBD8);

  // Semantic — Error
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFF8F7);

  // Semantic — Success
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);

  // Semantic — Warning
  static const Color warning = Color(0xFF9E6C00);
  static const Color warningLight = Color(0xFFFEFCE9);

  // Semantic — Info
  static const Color info = Color(0xFF004AAD);
  static const Color infoLight = Color(0xFFB8DFF2);

  // Category Colors (from transaction/budget chips in Figma)
  static const Color categoryFood = Color(0xFFF8853D);         // food - orange
  static const Color categoryFoodBg = Color(0xFFFFF7ED);
  static const Color categoryTransport = Color(0xFF004AAD);    // transport - blue
  static const Color categoryTransportBg = Color(0xFFB8DFF2);
  static const Color categoryHealth = Color(0xFFFA5874);       // health - pink/red
  static const Color categoryHealthBg = Color(0xFFFDF7FD);
  static const Color categoryShopping = Color(0xFFA144AF);     // shopping - purple
  static const Color categoryShoppingBg = Color(0xFFFDF7FD);

  // Utility
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Dark mode surfaces
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2E);
  static const Color darkBorder = Color(0xFF3A3A3C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
}
