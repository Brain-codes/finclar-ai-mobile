import 'package:flutter_test/flutter_test.dart';
import 'package:finclar_ai/core/utils/number_to_words.dart';

void main() {
  group('amountInWords', () {
    test('returns empty for zero and negatives so callers can hide the line',
        () {
      expect(amountInWords(0), '');
      expect(amountInWords(-5), '');
    });

    test('spells simple amounts', () {
      expect(amountInWords(1, currencyCode: 'NGN'), 'One naira');
      expect(amountInWords(19, currencyCode: 'NGN'), 'Nineteen naira');
      expect(amountInWords(20, currencyCode: 'NGN'), 'Twenty naira');
      expect(amountInWords(42, currencyCode: 'NGN'), 'Forty-two naira');
    });

    test('handles hundreds with the "and"', () {
      expect(amountInWords(100, currencyCode: 'NGN'), 'One hundred naira');
      expect(
        amountInWords(250, currencyCode: 'NGN'),
        'Two hundred and fifty naira',
      );
    });

    test('handles scale words', () {
      expect(amountInWords(1000, currencyCode: 'NGN'), 'One thousand naira');
      expect(
        amountInWords(250000, currencyCode: 'NGN'),
        'Two hundred and fifty thousand naira',
      );
      expect(
        amountInWords(1500000, currencyCode: 'NGN'),
        'One million five hundred thousand naira',
      );
    });

    test('includes the minor unit only when there is one', () {
      expect(amountInWords(5.50, currencyCode: 'NGN'), 'Five naira, fifty kobo');
      expect(amountInWords(5.00, currencyCode: 'NGN'), 'Five naira');
    });

    test('rounds a minor unit that reaches 100 into the major unit', () {
      expect(amountInWords(4.999, currencyCode: 'NGN'), 'Five naira');
    });

    test('uses the right unit names per currency', () {
      expect(amountInWords(2.05, currencyCode: 'USD'), 'Two dollars, five cents');
      expect(amountInWords(2, currencyCode: 'GBP'), 'Two pounds');
    });

    test('falls back to a bare number for an unknown currency', () {
      expect(amountInWords(12, currencyCode: 'XYZ'), 'Twelve');
      expect(amountInWords(12), 'Twelve');
    });

    test('does not crash on absurd values', () {
      expect(amountInWords(double.infinity), '');
      expect(amountInWords(double.nan), '');
      expect(amountInWords(9999999999999999.0), isA<String>());
    });
  });
}
