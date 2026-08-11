import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/category_model.dart';
import '../presentation/widgets/expense_category_utils.dart';
import 'expense_providers.dart';

/// Backfills a real, collision-free color for every category that predates
/// the icon+color encoding in `expense_category_utils.dart` (a bare icon key,
/// or no icon at all). Per-widget color lookups only ever hash a single
/// category name in isolation, which can't guarantee uniqueness — this sees
/// the user's *entire* category list at once and can, so it's the mechanism
/// that actually delivers "no 2 categories share a color" for legacy rows.
///
/// There is no `PATCH /categories` endpoint, so the assignment can't be
/// pushed to the backend — it's cached in `SharedPreferences` on this device
/// only. Re-running is cheap and idempotent (existing assignments are kept
/// as long as they don't collide with a newer embedded color), so it's safe
/// to kick off on every home screen load rather than gating it behind a
/// one-time migration flag.
class CategoryColorSyncService {
  static Future<Map<String, Color>> sync(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = _readCache(prefs);

    final used = <Color>{};
    final result = <String, Color>{};

    // A category with an embedded color is its own source of truth — keep it
    // and reserve the color so nothing else picks the same one.
    for (final c in categories) {
      final embedded = decodeCategoryIcon(c.icon).color;
      if (embedded != null) {
        result[c.id] = embedded;
        used.add(embedded);
      }
    }

    var dirty = false;
    for (final c in categories) {
      if (result.containsKey(c.id)) continue;
      final previouslyAssigned = cached[c.id];
      if (previouslyAssigned != null && !used.contains(previouslyAssigned)) {
        result[c.id] = previouslyAssigned;
        used.add(previouslyAssigned);
        continue;
      }
      final assigned = _nextUnusedColor(used);
      result[c.id] = assigned;
      used.add(assigned);
      dirty = true;
    }

    if (dirty) await _writeCache(prefs, result);
    return result;
  }

  static Color _nextUnusedColor(Set<Color> used) {
    for (final c in AppColors.categoryPalette) {
      if (!used.contains(c)) return c;
    }
    // Palette exhausted (30+ categories) — a rare repeat beats crashing.
    return AppColors.categoryPalette[used.length % AppColors.categoryPalette.length];
  }

  static Map<String, Color> _readCache(SharedPreferences prefs) {
    final raw = prefs.getString(AppConstants.categoryColorSyncKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final map = <String, Color>{};
    for (final entry in decoded.entries) {
      final color = colorFromHexString(entry.value as String);
      if (color != null) map[entry.key] = color;
    }
    return map;
  }

  static Future<void> _writeCache(
    SharedPreferences prefs,
    Map<String, Color> colors,
  ) async {
    final toSave = <String, String>{
      for (final e in colors.entries) e.key: colorToHexString(e.value),
    };
    await prefs.setString(AppConstants.categoryColorSyncKey, json.encode(toSave));
  }
}

/// categoryId → assigned color. Watch this wherever a category's `id` is
/// available to get the fully backfilled color, not just the per-name hash.
final categoryColorSyncProvider = FutureProvider<Map<String, Color>>((ref) async {
  final categories = await ref.watch(categoriesProvider.future);
  return CategoryColorSyncService.sync(categories);
});

/// categoryId → CategoryModel. Expense payloads only ever carry a category id
/// + name (no icon) — this is what lets an expense tile resolve the *actual*
/// icon/color the user picked for that category, via `categoryVisualFor`,
/// instead of falling back to the generic name-based default.
final categoriesByIdProvider = Provider<Map<String, CategoryModel>>((ref) {
  final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
  return {for (final c in categories) c.id: c};
});
