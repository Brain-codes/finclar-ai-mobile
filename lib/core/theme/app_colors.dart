import 'package:flutter/material.dart';

// Raw color palette — pure hex values only.
// Do NOT use these directly in widgets. Use context.* tokens from ContextX instead.
// Exception: colors that never change between modes (primary, white, black,
// semantic status colors, category colors) may be used directly.
abstract class AppColors {
  // ─── Brand / Primary ────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFFFF751F); // orange — same in both modes
  static const Color primaryHover   = Color(0xFFEF5F00); // pressed / hover state
  static const Color primaryDark    = Color(0xFFCC4E00); // darker variant for states

  // light
  static const Color primaryMuted   = Color(0xFFFFF7ED); // warm orange wash — light
  static const Color primaryLight   = Color(0xFFFFF8F7); // very light tint — light

  // dark
  static const Color primaryMutedDark  = Color(0xFF2D1800); // deep warm dark — dark
  static const Color primaryLightDark  = Color(0xFF1F1200); // deeper tint — dark

  // ─── Text ───────────────────────────────────────────────────────────────────
  // light
  static const Color textPrimary      = Color(0xFF101010);
  static const Color textSecondary    = Color(0xFF928F8B);
  static const Color textTertiary     = Color(0xFF65605C);
  static const Color textQuaternary   = Color(0xFF4D4845);

  // dark
  static const Color darkTextPrimary    = Color(0xFFFFFFFF);
  static const Color darkTextSecondary  = Color(0xFF8E8E93);
  static const Color darkTextTertiary   = Color(0xFF636366);
  static const Color darkTextQuaternary = Color(0xFF48484A);

  // ─── Surface & Background ───────────────────────────────────────────────────
  // light
  static const Color white          = Color(0xFFFFFFFF);
  static const Color background     = Color(0xFFFAFAFA);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF6F6F4);
  static const Color surfaceMuted   = Color(0xFFEFEFED);

  // dark
  static const Color darkBackground     = Color(0xFF0A0A0A);
  static const Color darkSurface        = Color(0xFF1C1C1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2E);
  static const Color darkSurfaceMuted   = Color(0xFF3A3A3C);

  // ─── Borders & Dividers ─────────────────────────────────────────────────────
  // light
  static const Color border       = Color(0xFFF4F4F2);
  static const Color borderStrong = Color(0xFFE7E7E4);

  // dark
  static const Color darkBorder       = Color(0xFF3A3A3C);
  static const Color darkBorderStrong = Color(0xFF48484A);

  // ─── Input ──────────────────────────────────────────────────────────────────
  // light
  static const Color inputFill        = Color(0xFFFFFFFF);
  static const Color inputBorder      = Color(0xFFF4F4F2);
  static const Color inputPlaceholder = Color(0xFFDBDBD8);

  // dark
  static const Color darkInputFill        = Color(0xFF2C2C2E);
  static const Color darkInputBorder      = Color(0xFF3A3A3C);
  static const Color darkInputPlaceholder = Color(0xFF636366);

  // ─── Semantic — same hue in both modes, bg differs ──────────────────────────
  static const Color error        = Color(0xFFC62828);
  static const Color errorLight   = Color(0xFFFFF8F7);   // light bg
  static const Color errorDark    = Color(0xFF3B0A0A);   // dark bg

  static const Color success      = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);   // light bg
  static const Color successDark  = Color(0xFF052E16);   // dark bg

  static const Color warning      = Color(0xFF9E6C00);
  static const Color warningLight = Color(0xFFFEFCE9);   // light bg
  static const Color warningDark  = Color(0xFF2D1F00);   // dark bg

  static const Color info         = Color(0xFF004AAD);
  static const Color infoLight    = Color(0xFFB8DFF2);   // light bg
  static const Color infoDark     = Color(0xFF00193D);   // dark bg

  // ─── Category Colors ────────────────────────────────────────────────────────
  // Foreground colors are the same in both modes.
  // Background chips differ.
  static const Color categoryFood         = Color(0xFFF8853D);
  static const Color categoryFoodBg       = Color(0xFFFFF7ED);      // light
  static const Color categoryFoodBgDark   = Color(0xFF2D1800);      // dark

  static const Color categoryTransport       = Color(0xFF004AAD);
  static const Color categoryTransportBg     = Color(0xFFB8DFF2);   // light
  static const Color categoryTransportBgDark = Color(0xFF00193D);   // dark

  static const Color categoryHealth       = Color(0xFFFA5874);
  static const Color categoryHealthBg     = Color(0xFFFDF2F4);      // light
  static const Color categoryHealthBgDark = Color(0xFF2D0A10);      // dark

  static const Color categoryShopping       = Color(0xFFA144AF);
  static const Color categoryShoppingBg     = Color(0xFFF9F0FA);    // light
  static const Color categoryShoppingBgDark = Color(0xFF1E0A22);    // dark

  // ─── Settings icon circle colors (same in both modes) ───────────────────────
  static const Color settingsRed   = Color(0xFF9A2329);
  static const Color settingsCoral = Color(0xFFE55959);
  static const Color settingsBrown = Color(0xFFA55F2B);
  static const Color settingsNavy     = Color(0xFF1C4771);
  static const Color settingsDeepNavy = Color(0xFF05294C);
  static const Color settingsAmber = Color(0xFFAC5500);
  static const Color toggleActive  = Color(0xFF34C759);

  // ─── Utility ────────────────────────────────────────────────────────────────
  static const Color black       = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ─── Clara AI gradients ──────────────────────────────────────────────────────
  static const LinearGradient claraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFA5874), Color(0xFF800080), Color(0xFFF8853D)],
    stops: [0.0, 0.53, 1.0],
  );

  static const LinearGradient claraBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF751F), Color(0xFFDA4EBB)],
  );
}
