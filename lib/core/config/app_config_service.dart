import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../features/expenses/data/models/category_model.dart';
import 'app_config.dart';
import 'app_local_defaults.dart';

class AppConfigService {
  static Future<AppConfig> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Currency — use cached code or fall back to local default (NGN).
    final cachedCode = prefs.getString(AppConstants.currencyCodeKey);
    final currencyCode = (cachedCode != null && cachedCode.isNotEmpty)
        ? cachedCode
        : AppLocalDefaults.currencyCode;

    // Categories — use cached list or fall back to local default list.
    final cachedCategoriesJson = prefs.getString(AppConstants.categoriesKey);
    List<CategoryModel> categories;
    if (cachedCategoriesJson != null && cachedCategoriesJson.isNotEmpty) {
      final parsed = categoryModelListFromJson(cachedCategoriesJson);
      categories = parsed.isNotEmpty ? parsed : AppLocalDefaults.categories;
    } else {
      categories = AppLocalDefaults.categories;
    }

    return AppConfig(
      currencyCode: currencyCode,
      currencySymbol: AppConfig.symbolFor(currencyCode),
      categories: categories,
    );
  }

  static Future<void> saveCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.currencyCodeKey, code);
  }

  static Future<void> saveCategories(List<CategoryModel> categories) async {
    // Never persist an empty list — local defaults are always the floor.
    if (categories.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.categoriesKey,
      categoryModelListToJson(categories),
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.currencyCodeKey);
    await prefs.remove(AppConstants.categoriesKey);
  }
}
