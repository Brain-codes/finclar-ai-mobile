import '../../../features/expenses/data/models/category_model.dart';
import 'app_local_defaults.dart';

class AppConfig {
  final String currencyCode;
  final String currencySymbol;
  final List<CategoryModel> categories;

  const AppConfig({
    required this.currencyCode,
    required this.currencySymbol,
    required this.categories,
  });

  /// The guaranteed safe fallback — always NGN + full local category list.
  /// Used on first launch and whenever the cache/backend haven't provided values.
  static const AppConfig defaults = AppConfig(
    currencyCode: AppLocalDefaults.currencyCode,
    currencySymbol: AppLocalDefaults.currencySymbol,
    categories: AppLocalDefaults.categories,
  );

  /// The currencies the app offers in pickers. Every code here must have a
  /// symbol in [symbolFor], otherwise the picker shows a bare code.
  static const List<({String code, String name})> supportedCurrencies = [
    (code: 'NGN', name: 'Nigerian Naira'),
    (code: 'USD', name: 'US Dollar'),
    (code: 'GBP', name: 'British Pound'),
    (code: 'EUR', name: 'Euro'),
    (code: 'GHS', name: 'Ghanaian Cedi'),
    (code: 'KES', name: 'Kenyan Shilling'),
    (code: 'ZAR', name: 'South African Rand'),
    (code: 'CAD', name: 'Canadian Dollar'),
    (code: 'AUD', name: 'Australian Dollar'),
  ];

  /// Maps an ISO 4217 currency code to its display symbol.
  static String symbolFor(String code) {
    switch (code.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'GHS':
        return '₵';
      case 'KES':
        return 'KSh';
      case 'ZAR':
        return 'R';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'A\$';
      default:
        return code;
    }
  }

  AppConfig copyWith({
    String? currencyCode,
    List<CategoryModel>? categories,
  }) {
    final code = currencyCode ?? this.currencyCode;
    return AppConfig(
      currencyCode: code,
      currencySymbol: symbolFor(code),
      // When backend sends an empty list, keep local defaults — never go blank.
      categories: (categories != null && categories.isNotEmpty)
          ? categories
          : this.categories,
    );
  }
}
