import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/category_model.dart';

/// Curated icon keys for the category icon picker.
/// Keys are the actual Remix icon field names — the exact string stored in
/// `CategoryModel.icon` and sent to `POST /categories`.
const List<(String, String)> categoryPickerIcons = [
  ('restaurant_line', 'Food'),
  ('car_line', 'Transport'),
  ('heart_pulse_line', 'Health'),
  ('shopping_bag_line', 'Shopping'),
  ('movie_line', 'Fun'),
  ('flashlight_line', 'Bills'),
  ('plane_line', 'Travel'),
  ('home_6_line', 'Home'),
  ('briefcase_4_fill', 'Work'),
  ('bank_line', 'Finance'),
  ('wallet_line', 'Wallet'),
  ('bar_chart_fill', 'Stats'),
  ('calendar_line', 'Events'),
  ('star_line', 'Savings'),
  ('more_2_line', 'Other'),
];

/// Maps a Remix icon name string (e.g. `"star_line"`) back to an [IconData].
/// Returns null for keys we don't render, so callers can fall back to the
/// name-based mapping instead of showing a meaningless "other" icon.
IconData? _iconDataForKey(String? key) {
  switch (key) {
    case 'restaurant_line':  return AppIcons.categoryFood;
    case 'car_line':         return AppIcons.categoryTransport;
    case 'heart_pulse_line': return AppIcons.categoryHealth;
    case 'shopping_bag_line': return AppIcons.categoryShopping;
    case 'movie_line':       return AppIcons.categoryEntertainment;
    // Backend seeds Utilities with `flash_line`; the picker sends
    // `flashlight_line`. Both mean the same icon here.
    case 'flash_line':
    case 'flashlight_line':  return AppIcons.categoryUtilities;
    case 'plane_line':       return AppIcons.categoryTravel;
    case 'home_line':
    case 'home_6_line':      return AppIcons.home;
    case 'briefcase_4_fill': return AppIcons.briefcase;
    case 'bank_line':        return AppIcons.bank;
    case 'wallet_line':      return AppIcons.walletLine;
    case 'bar_chart_fill':   return AppIcons.chart;
    case 'chart_line':
    case 'line_chart_line':  return AppIcons.categoryInvestment;
    case 'book_line':
    case 'book_2_line':      return AppIcons.categoryEducation;
    case 'piggy_bank_line':
    case 'safe_2_line':      return AppIcons.categorySavings;
    case 'grid_line':        return AppIcons.categoryGrid;
    case 'calendar_line':    return AppIcons.calendar;
    case 'star_line':        return AppIcons.star;
    case 'more_2_line':      return AppIcons.categoryOther;
    default:                 return null;
  }
}

IconData categoryIconFromString(String? key) =>
    _iconDataForKey(key) ?? AppIcons.categoryOther;

/// Backend categories carry no color (`CategoryModel` has only
/// id/name/description/icon), so color is assigned entirely client-side. The
/// 5 default categories below keep their branded look; every other category
/// (including all user-created ones) gets a deterministic pick from
/// `AppColors.categoryPalette` (30 colors) keyed by name, so distinct
/// categories reliably land on distinct colors instead of all collapsing
/// onto the same default `AppColors.primary`.
///
/// This is a hash, not a true no-collision allocator — with 30 colors,
/// collisions are rare below ~15-20 custom categories but not impossible. A
/// guaranteed-unique scheme would need to assign colors from the user's full
/// category list (via `categoriesProvider`) rather than hashing a name in
/// isolation, which would require every call site to read from Riverpod.
Color expenseCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return AppColors.categoryFood;
    case 'transport':
    case 'transportation':
      return AppColors.categoryTransport;
    case 'health':
      return AppColors.categoryHealth;
    case 'shopping':
      return AppColors.categoryShopping;
    case 'utilities':
    case 'bills':
      return AppColors.categoryUtilities;
    default:
      return _paletteColorFor(category);
  }
}

Color expenseCategoryBgColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return AppColors.categoryFoodBg;
    case 'transport':
    case 'transportation':
      return AppColors.categoryTransportBg;
    case 'health':
      return AppColors.categoryHealthBg;
    case 'shopping':
      return AppColors.categoryShoppingBg;
    case 'utilities':
    case 'bills':
      return AppColors.categoryUtilitiesBg;
    default:
      return _paletteColorFor(category).withValues(alpha: 0.12);
  }
}

Color _paletteColorFor(String category) {
  final palette = AppColors.categoryPalette;
  final index = category.trim().toLowerCase().hashCode.abs() % palette.length;
  return palette[index];
}

IconData expenseCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return AppIcons.categoryFood;
    case 'transport':
    case 'transportation':
      return AppIcons.categoryTransport;
    case 'health':
      return AppIcons.categoryHealth;
    case 'shopping':
      return AppIcons.categoryShopping;
    case 'utilities':
    case 'bills':
      return AppIcons.categoryUtilities;
    case 'entertainment':
      return AppIcons.categoryEntertainment;
    case 'education':
      return AppIcons.categoryEducation;
    case 'investment':
    case 'investments':
      return AppIcons.categoryInvestment;
    case 'savings':
      return AppIcons.categorySavings;
    case 'rent':
    case 'housing':
      return AppIcons.categoryRent;
    case 'travel':
      return AppIcons.categoryTravel;
    case 'other':
      return AppIcons.categoryGrid;
    default:
      return AppIcons.wallet;
  }
}

// ─── Icon+color encoding (backward compatible) ─────────────────────────────
//
// `CategoryModel.icon` / `AllocationModel.categoryIcon` are a single backend
// string field — same constraint the avatar picker works under with
// `profile_icon` (see `AppProfileAvatar`). New categories pack both the icon
// key and a user-chosen color into that one string as `iconKey::#RRGGBB`
// (e.g. `restaurant_line::#E63946`), the same "one field, custom-encoded"
// pattern used there.
//
// Existing categories only ever stored a bare icon key (or nothing), so
// decoding must accept both shapes: `decodeCategoryIcon` splits on `::` when
// present and falls back to treating the whole string as a legacy icon key
// (or empty) when it isn't — old rows keep working unchanged, they just don't
// get a custom color and fall back to the hash-based palette below.
const String _categoryIconColorSeparator = '::';

class CategoryIconSpec {
  final String iconKey;
  final Color? color;

  const CategoryIconSpec({required this.iconKey, this.color});
}

String encodeCategoryIcon(String iconKey, Color color) =>
    '$iconKey$_categoryIconColorSeparator${colorToHexString(color)}';

CategoryIconSpec decodeCategoryIcon(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) {
    return const CategoryIconSpec(iconKey: '');
  }
  final parts = value.split(_categoryIconColorSeparator);
  if (parts.length == 2) {
    final color = colorFromHexString(parts[1]);
    if (color != null) return CategoryIconSpec(iconKey: parts[0], color: color);
  }
  // Legacy row: plain icon key (or garbage) with no embedded color.
  return CategoryIconSpec(iconKey: value);
}

String colorToHexString(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

Color? colorFromHexString(String hex) {
  var h = hex.trim();
  if (h.startsWith('#')) h = h.substring(1);
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  final value = int.tryParse(h, radix: 16);
  return value != null ? Color(value) : null;
}

/// Preferred entry points once a category's raw `icon` string is available
/// (i.e. anywhere a `CategoryModel`/`AllocationModel` is in scope, not just a
/// bare category name).
///
/// Color resolution order:
/// 1. [syncedColors]`[categoryId]` — the background backfill assigned by
///    `CategoryColorSyncService` for legacy categories that predate the
///    icon+color encoding (see that file). Only present once that sync has
///    run and only when [categoryId] is supplied.
/// 2. The color embedded in [icon] itself, for categories created after the
///    encoding shipped.
/// 3. The legacy name-based scheme (`expenseCategoryColor`), for anywhere
///    that only ever has a bare category name — expense list tiles and Clara
///    chat, whose payloads carry no `icon`/`categoryId` at all.
Color categoryColorFor({
  required String name,
  String? icon,
  String? categoryId,
  Map<String, Color>? syncedColors,
}) {
  if (categoryId != null) {
    final synced = syncedColors?[categoryId];
    if (synced != null) return synced;
  }
  return decodeCategoryIcon(icon).color ?? expenseCategoryColor(name);
}

Color categoryBgColorFor({
  required String name,
  String? icon,
  String? categoryId,
  Map<String, Color>? syncedColors,
}) {
  // Only alpha-blend when a synced/embedded override is actually in play —
  // the 5 branded categories otherwise keep their hand-picked (and dark-mode
  // aware) `*Bg`/`*BgDark` constants rather than a generic tint.
  Color? synced;
  if (categoryId != null) synced = syncedColors?[categoryId];
  final embedded = decodeCategoryIcon(icon).color;
  final override = synced ?? embedded;
  if (override != null) return override.withValues(alpha: 0.12);
  return expenseCategoryBgColor(name);
}

IconData categoryIconFor({required String name, String? icon}) {
  final key = decodeCategoryIcon(icon).iconKey;
  return _iconDataForKey(key) ?? expenseCategoryIcon(name);
}

/// icon + fg + bg for a category, resolved the same way everywhere.
class CategoryVisual {
  final IconData icon;
  final Color color;
  final Color bgColor;

  const CategoryVisual({
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

/// Resolves a category's icon/colors by id when possible instead of name
/// alone. Expenses only ever carry a `category_id` + `category_name` (no
/// `icon`), so anywhere an expense is rendered needs to look its category up
/// in [categoriesById] to get the *actual* icon/color the user picked —
/// without this, expense tiles fall back to the crude name-based defaults
/// (`expenseCategoryIcon`/`Color`) and visibly disagree with the category
/// picker, which always had the real `CategoryModel.icon` in hand.
///
/// Falls back gracefully at every step: unknown/missing category id → name
/// only; category has no embedded color yet → the sync backfill in
/// [syncedColors] → the legacy name hash.
CategoryVisual categoryVisualFor({
  required String name,
  String? categoryId,
  Map<String, CategoryModel>? categoriesById,
  Map<String, Color>? syncedColors,
}) {
  CategoryModel? category;
  if (categoryId != null) category = categoriesById?[categoryId];
  final icon = category?.icon;
  return CategoryVisual(
    icon: categoryIconFor(name: name, icon: icon),
    color: categoryColorFor(
      name: name,
      icon: icon,
      categoryId: categoryId,
      syncedColors: syncedColors,
    ),
    bgColor: categoryBgColorFor(
      name: name,
      icon: icon,
      categoryId: categoryId,
      syncedColors: syncedColors,
    ),
  );
}
