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
  static const Color onPrimary      = Color(0xFF1A0A00); // text/icons on primary bg

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

  // Text/icon colors for use ON the tinted *Light backgrounds above. The base
  // `success`/`warning` hues only reach ~3:1 there, which fails WCAG AA for
  // text — these darker shades clear 4.5:1. On dark backgrounds the pale
  // *Light constants serve as the foreground instead (see context extensions).
  static const Color successOn    = Color(0xFF166534);   // 6.49:1 on successLight
  static const Color warningOn    = Color(0xFF854D0E);   // 6.63:1 on warningLight

  // ─── Category Colors ────────────────────────────────────────────────────────
  // Foreground colors are the same in both modes.
  // Background chips differ.
  static const Color categoryFood         = Color(0xFFF8853D);
  static const Color categoryFoodBg       = Color(0xFFFFF7ED);      // light
  static const Color categoryFoodBgDark   = Color(0xFF2D1800);      // dark

  static const Color categoryTransport       = Color(0xFF004AAD);
  static const Color categoryPurple          = Color(0xFF8347B9);
  static const Color categoryTransportBg     = Color(0xFFB8DFF2);   // light
  static const Color categoryTransportBgDark = Color(0xFF00193D);   // dark

  static const Color categoryHealth       = Color(0xFFFA5874);
  static const Color categoryHealthBg     = Color(0xFFFDF2F4);      // light
  static const Color categoryHealthBgDark = Color(0xFF2D0A10);      // dark

  static const Color categoryShopping       = Color(0xFFA144AF);
  static const Color categoryShoppingBg     = Color(0xFFF9F0FA);    // light
  static const Color categoryShoppingBgDark = Color(0xFF1E0A22);    // dark

  static const Color categoryUtilities       = Color(0xFF008080);   // teal
  static const Color categoryUtilitiesBg     = Color(0xFFE6F4F4);   // light
  static const Color categoryUtilitiesBgDark = Color(0xFF002B2B);   // dark

  /// Fallback palette for categories with no dedicated brand color above
  /// (i.e. every user-created category, and any default beyond the 5 named
  /// ones). 30 hues spread around the color wheel, deliberately clear of the
  /// 5 branded colors above so a custom category never visually collides with
  /// Food/Transport/Health/Shopping/Utilities. Assignment is deterministic
  /// per category name — see `expenseCategoryColor` in expense_category_utils.
  /// Background chips are derived from these at 12% alpha rather than hand
  /// picked, so this list is the only thing to extend if more are needed.
  static const List<Color> categoryPalette = [
    Color(0xFFE63946), // red
    Color(0xFF2A9D8F), // jade
    Color(0xFFE9A319), // gold
    Color(0xFF6D597A), // plum
    Color(0xFF1D8A99), // deep cyan
    Color(0xFFB56576), // dusty rose
    Color(0xFF43AA8B), // sea green
    Color(0xFFC44536), // rust
    Color(0xFF5E60CE), // indigo
    Color(0xFFF3722C), // tangerine
    Color(0xFF277DA1), // steel blue
    Color(0xFF9C6644), // walnut
    Color(0xFF90BE6D), // moss
    Color(0xFFD62828), // crimson
    Color(0xFF4D908E), // slate teal
    Color(0xFFCB997E), // clay
    Color(0xFF577590), // denim
    Color(0xFFF9844A), // coral orange
    Color(0xFF7209B7), // violet
    Color(0xFF06A77D), // emerald
    Color(0xFFB5838D), // mauve
    Color(0xFF3A86FF), // azure
    Color(0xFF8D6A9F), // heather
    Color(0xFF457B9D), // ocean blue
    Color(0xFFE85D75), // watermelon
    Color(0xFF386641), // forest
    Color(0xFFBC6C25), // amber brown
    Color(0xFF6A4C93), // grape
    Color(0xFF2B9348), // pine
    Color(0xFFAE2012), // brick
  ];

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

  // ─── Gamification ───────────────────────────────────────────────────────────
  static const Color streakGold        = Color(0xFFFE9400); // streak counter + active day
  static const Color streakGoldMuted   = Color(0xFFFFF3E0); // streak day bg light
  static const Color challengePurple   = Color(0xFF844FAE); // category budget challenge
  static const Color challengePurpleMuted = Color(0xFFF2EAF7); // category budget wash
  static const Color onChallengePurple = Color(0xFFFFFFFF); // text on purple buttons
  static const Color onPrimaryDeep     = Color(0xFF4D1E00); // text on orange gamification buttons
  static const Color badgeTealStart    = Color(0xFF49F0BC); // badge front gradient start
  static const Color badgeTealEnd      = Color(0xFF29DCCC); // badge front gradient end

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
