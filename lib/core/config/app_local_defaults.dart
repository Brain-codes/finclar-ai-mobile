import '../../features/expenses/data/models/category_model.dart';

/// Hardcoded local fallbacks the app can always rely on,
/// regardless of whether the backend has responded yet.
///
/// These are used as the seed values for [AppConfig.defaults]
/// and as the fallback in [AppConfigService] when the cache is empty.
abstract class AppLocalDefaults {
  // ─── Currency ──────────────────────────────────────────────────────────────

  /// Default currency code — NGN because this is a Nigerian fintech product.
  static const String currencyCode = 'NGN';

  /// Corresponding display symbol derived from [currencyCode].
  static const String currencySymbol = '₦';

  // ─── Categories ────────────────────────────────────────────────────────────

  /// All expense categories the app supports locally.
  ///
  /// The [id] field uses a stable lowercase slug so it matches the switch
  /// cases in expense_category_utils.dart and will align with backend values
  /// once the categories endpoint is live.
  ///
  /// Order matters — it determines display order in pickers.
  static const List<CategoryModel> categories = [
    CategoryModel(id: 'food', name: 'Food'),
    CategoryModel(id: 'transport', name: 'Transport'),
    CategoryModel(id: 'health', name: 'Health'),
    CategoryModel(id: 'shopping', name: 'Shopping'),
    CategoryModel(id: 'utilities', name: 'Utilities'),
    CategoryModel(id: 'entertainment', name: 'Entertainment'),
    CategoryModel(id: 'education', name: 'Education'),
    CategoryModel(id: 'savings', name: 'Savings'),
    CategoryModel(id: 'others', name: 'Others'),
  ];
}
