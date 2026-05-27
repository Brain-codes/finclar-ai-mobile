import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) return newValue.copyWith(text: '');

    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(raw)) return oldValue;

    final dotIndex = raw.indexOf('.');
    final intPart = dotIndex == -1 ? raw : raw.substring(0, dotIndex);
    final decPart = dotIndex == -1 ? '' : raw.substring(dotIndex);
    final formatted = _formatIntPart(intPart) + decPart;

    final rawCursor = _toRawOffset(newValue.text, newValue.selection.extentOffset);
    final newCursor = _toFormattedOffset(formatted, rawCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  String _formatIntPart(String s) {
    if (s.isEmpty) return '';
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  int _toRawOffset(String formatted, int offset) {
    var raw = 0;
    for (var i = 0; i < offset && i < formatted.length; i++) {
      if (formatted[i] != ',') raw++;
    }
    return raw;
  }

  int _toFormattedOffset(String formatted, int rawTarget) {
    var raw = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (formatted[i] != ',') raw++;
      if (raw == rawTarget) return i + 1;
    }
    return formatted.length;
  }
}

/// Formats a double as a display string with comma separators and 2 decimals.
/// e.g. 5000.0 → "5,000.00"
String formatAmountInput(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  buf.write('.${parts[1]}');
  return buf.toString();
}

/// Strips commas and parses back to double.
/// e.g. "5,000.00" → 5000.0
double parseAmountInput(String text, {double fallback = 0}) {
  return double.tryParse(text.replaceAll(',', '').trim()) ?? fallback;
}
