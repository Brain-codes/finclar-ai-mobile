const _units = [
  '',
  'One',
  'Two',
  'Three',
  'Four',
  'Five',
  'Six',
  'Seven',
  'Eight',
  'Nine',
  'Ten',
  'Eleven',
  'Twelve',
  'Thirteen',
  'Fourteen',
  'Fifteen',
  'Sixteen',
  'Seventeen',
  'Eighteen',
  'Nineteen',
];

const _tens = [
  '',
  '',
  'Twenty',
  'Thirty',
  'Forty',
  'Fifty',
  'Sixty',
  'Seventy',
  'Eighty',
  'Ninety',
];

// Indexed by how many groups of 1000 deep we are.
const _scales = ['', 'Thousand', 'Million', 'Billion', 'Trillion'];

/// Major/minor unit names per ISO 4217 code, for the spelled-out amount.
/// Falls back to the bare number when a code isn't listed.
const _currencyNames = <String, ({String major, String minor})>{
  'NGN': (major: 'Naira', minor: 'Kobo'),
  'USD': (major: 'Dollars', minor: 'Cents'),
  'GBP': (major: 'Pounds', minor: 'Pence'),
  'EUR': (major: 'Euros', minor: 'Cents'),
  'GHS': (major: 'Cedis', minor: 'Pesewas'),
  'KES': (major: 'Shillings', minor: 'Cents'),
  'ZAR': (major: 'Rand', minor: 'Cents'),
  'CAD': (major: 'Dollars', minor: 'Cents'),
  'AUD': (major: 'Dollars', minor: 'Cents'),
};

String _threeDigitsToWords(int n) {
  if (n == 0) return '';
  if (n < 20) return _units[n];
  if (n < 100) {
    final rest = n % 10;
    return _tens[n ~/ 10] + (rest == 0 ? '' : '-${_units[rest].toLowerCase()}');
  }
  final rest = n % 100;
  final hundreds = '${_units[n ~/ 100]} hundred';
  return rest == 0 ? hundreds : '$hundreds and ${_threeDigitsToWords(rest).toLowerCase()}';
}

String _intToWords(int value) {
  if (value == 0) return 'Zero';

  final groups = <String>[];
  var remaining = value;
  var scale = 0;

  while (remaining > 0 && scale < _scales.length) {
    final group = remaining % 1000;
    if (group != 0) {
      final words = _threeDigitsToWords(group);
      groups.insert(
        0,
        scale == 0 ? words : '$words ${_scales[scale]}',
      );
    }
    remaining ~/= 1000;
    scale++;
  }

  // Anything past trillions is beyond what this app will ever display.
  if (remaining > 0) return '';

  final joined = groups.join(' ').trim();
  // Only the first word stays capitalised — "Two hundred and fifty Thousand"
  // reads wrong, so scale words are lowercased after the join.
  return joined.isEmpty ? 'Zero' : _capitaliseFirst(joined.toLowerCase());
}

String _capitaliseFirst(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Spells out [amount] for display under a numeric input, e.g.
/// `250000.50` + `NGN` → "Two hundred and fifty thousand naira, fifty kobo".
///
/// Returns an empty string for zero/negative amounts and for values too large
/// to spell, so callers can hide the line without a null check.
String amountInWords(double amount, {String? currencyCode}) {
  if (amount <= 0 || !amount.isFinite) return '';

  final major = amount.floor();
  final minor = ((amount - major) * 100).round();
  // .995 and up rounds the minor unit into a whole one.
  if (minor >= 100) return amountInWords(major + 1.0, currencyCode: currencyCode);

  final names = _currencyNames[currencyCode?.toUpperCase() ?? ''];
  final majorWords = _intToWords(major);
  if (majorWords.isEmpty) return '';

  final buffer = StringBuffer(majorWords);
  if (names != null) buffer.write(' ${names.major.toLowerCase()}');

  if (minor > 0) {
    final minorWords = _intToWords(minor).toLowerCase();
    buffer.write(', $minorWords');
    if (names != null) buffer.write(' ${names.minor.toLowerCase()}');
  }

  return buffer.toString();
}
