import 'package:intl/intl.dart';

/// Formats a numeric amount with optional abbreviation and comma separation.
/// Does NOT prepend a currency symbol — use [formatCurrency] for that.
String formatAmount(
  double value, {
  bool abbreviate = true,
  bool withCommas = false,
}) {
  // Only millions abbreviate. Rounding thousands to "5k" printed a figure the
  // user could not reconcile with the percentages beside it (₦1,500 rendered
  // "₦2k" next to a correct "60% of allocation").
  if (abbreviate && value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}m';
  }

  if (withCommas || abbreviate) {
    return NumberFormat('#,##0.##').format(value);
  }

  return value % 1 == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

/// Formats a value with a currency symbol prefix.
/// Pass [symbol] explicitly (from [currencySymbolProvider]) or fall back to
/// the supplied default. Never hardcode '₦' — use this instead.
///
/// Example:
///   formatCurrency(1500000, symbol: ref.watch(currencySymbolProvider))
///   // → '₦1.5m'  or  '$1.5m'  depending on user's currency
String formatCurrency(
  double value,
  String symbol, {
  bool abbreviate = true,
  bool withCommas = false,
}) {
  return '$symbol${formatAmount(value, abbreviate: abbreviate, withCommas: withCommas)}';
}
