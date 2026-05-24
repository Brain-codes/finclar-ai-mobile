import 'package:intl/intl.dart';

/// Formats a numeric amount with optional abbreviation and comma separation.
///
/// [abbreviate] — when true, values ≥ 1,000 are shortened to k/m (e.g. 2,000,000 → 2.0m).
/// [withCommas] — when true, the raw number is formatted with comma separators.
/// Both can be combined: abbreviate takes precedence when the value qualifies.
String formatAmount(
  double value, {
  bool abbreviate = true,
  bool withCommas = false,
}) {
  if (abbreviate) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}m';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
  }

  if (withCommas) {
    return NumberFormat('#,##0.##').format(value);
  }

  return value % 1 == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}
