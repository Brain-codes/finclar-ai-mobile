// Single source of truth for all SVG asset paths used in the app.
//
// Rules:
//   - Never reference an SVG path string directly in feature code.
//   - Always use AppSvg.<name> here, then render via AppSvgImage.
//   - To rename or move an SVG file, only this file needs to change.
//
// Adding a new SVG:
//   1. Drop the .svg file into assets/svg/
//   2. Add a static const here with a semantic name.
//   3. Use AppSvg.yourName inside AppSvgImage(...) everywhere else.
abstract class AppSvg {
  static const String _base = 'assets/svg';

  // ─── Brand ────────────────────────────────────────────────────────────────
  static const String logo         = '$_base/logo.svg';
  static const String logomark     = '$_base/logomark.svg';

  // ─── Social / Auth ────────────────────────────────────────────────────────
  static const String google       = '$_base/google.svg';
  static const String apple        = '$_base/apple.svg';

  // ─── Illustrations ────────────────────────────────────────────────────────
  // static const String emptyState    = '$_base/empty_state.svg';
  // static const String errorState    = '$_base/error_state.svg';
  // static const String successState  = '$_base/success_state.svg';

  // ─── Category icons ───────────────────────────────────────────────────────
  // static const String categoryFood      = '$_base/category_food.svg';
  // static const String categoryTransport = '$_base/category_transport.svg';
  // static const String categoryHealth    = '$_base/category_health.svg';
  // static const String categoryShopping  = '$_base/category_shopping.svg';
}
