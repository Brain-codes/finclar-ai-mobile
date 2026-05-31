import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/expenses/data/models/category_model.dart';
import 'app_config.dart';
import 'app_config_service.dart';

class AppConfigNotifier extends AsyncNotifier<AppConfig> {
  @override
  Future<AppConfig> build() => AppConfigService.load();

  /// Call after a successful login/register with the user's default_currency.
  Future<void> applyCurrency(String currencyCode) async {
    await AppConfigService.saveCurrency(currencyCode);
    final current = state.valueOrNull ?? AppConfig.defaults;
    state = AsyncData(current.copyWith(currencyCode: currencyCode));
  }

  /// Call after fetching categories from the backend.
  Future<void> applyCategories(List<CategoryModel> categories) async {
    await AppConfigService.saveCategories(categories);
    final current = state.valueOrNull ?? AppConfig.defaults;
    state = AsyncData(current.copyWith(categories: categories));
  }

  /// Force a reload from cache (e.g. after logout + login with different account).
  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(AppConfigService.load);
  }

  /// Wipe config on logout.
  Future<void> reset() async {
    await AppConfigService.clear();
    state = const AsyncData(AppConfig.defaults);
  }
}

final appConfigProvider =
    AsyncNotifierProvider<AppConfigNotifier, AppConfig>(AppConfigNotifier.new);

/// Convenience provider — returns the current currency symbol synchronously,
/// falling back to the default while the config is loading.
final currencySymbolProvider = Provider<String>((ref) {
  return ref.watch(appConfigProvider).valueOrNull?.currencySymbol ??
      AppConfig.defaults.currencySymbol;
});

/// Convenience provider for categories.
final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(appConfigProvider).valueOrNull?.categories ?? const [];
});
