import 'package:indian_tax_utils/indian_tax_utils.dart';
import 'package:test/test.dart';

void main() {
  group('CurrencyHelper', () {
    test('Format Indian Currency', () {
      expect(CurrencyHelper.format(123456.78), '₹ 1,23,456.78');
      expect(CurrencyHelper.format(100.50), '₹ 100.50');
      expect(CurrencyHelper.format(1000.50), '₹ 1,000.50');
      expect(CurrencyHelper.format(10000000), '₹ 1,00,00,000.00');
    });

    test('Format without symbol', () {
      expect(CurrencyHelper.format(123456.78, symbol: false), '1,23,456.78');
    });

    test('groups every length correctly', () {
      const expected = [
        '0.00',
        '1.00',
        '12.00',
        '123.00',
        '1,234.00',
        '12,345.00',
        '1,23,456.00',
        '12,34,567.00',
        '1,23,45,678.00',
        '12,34,56,789.00',
        '1,23,45,67,890.00',
      ];
      const inputs = [
        0.0,
        1.0,
        12.0,
        123.0,
        1234.0,
        12345.0,
        123456.0,
        1234567.0,
        12345678.0,
        123456789.0,
        1234567890.0,
      ];
      for (var i = 0; i < inputs.length; i++) {
        expect(CurrencyHelper.format(inputs[i], symbol: false), expected[i]);
      }
    });

    test('negative amounts put the sign before the symbol', () {
      expect(CurrencyHelper.format(-1234.5), '-₹ 1,234.50');
      expect(CurrencyHelper.format(-0.5), '-₹ 0.50');
      expect(CurrencyHelper.format(-1234.5, symbol: false), '-1,234.50');
    });

    test('amounts that round to zero are not shown as negative', () {
      expect(CurrencyHelper.format(-0.001), '₹ 0.00');
      expect(CurrencyHelper.format(-0.4, decimals: 0), '₹ 0');
    });

    test('rounds half away from zero, carrying into grouping', () {
      expect(CurrencyHelper.format(1.005), '₹ 1.01');
      expect(CurrencyHelper.format(999.999), '₹ 1,000.00');
      expect(CurrencyHelper.format(99999.995), '₹ 1,00,000.00');
    });

    test('decimals controls precision', () {
      expect(CurrencyHelper.format(1234567.6, decimals: 0), '₹ 12,34,568');
      expect(CurrencyHelper.format(12.5, decimals: 3), '₹ 12.500');
    });

    test('rejects values it cannot format', () {
      expect(() => CurrencyHelper.format(double.nan), throwsArgumentError);
      expect(() => CurrencyHelper.format(double.infinity), throwsArgumentError);
      expect(() => CurrencyHelper.format(1e21), throwsArgumentError);
      expect(() => CurrencyHelper.format(1, decimals: -1), throwsRangeError);
      expect(() => CurrencyHelper.format(1, decimals: 21), throwsRangeError);
    });
  });

  group('AmountToWords', () {
    test('Convert amount to words', () {
      expect(AmountToWords.convert(123456.78),
          'One Lakh Twenty Three Thousand Four Hundred and Fifty Six Rupees and Seventy Eight Paise Only');
      expect(AmountToWords.convert(100), 'One Hundred Rupees Only');
      expect(AmountToWords.convert(10000000), 'One Crore Rupees Only');
    });

    test('zero', () {
      expect(AmountToWords.convert(0), 'Zero Rupees Only');
      expect(AmountToWords.convert(0.004), 'Zero Rupees Only');
      expect(AmountToWords.convert(-0.004), 'Zero Rupees Only');
    });

    test('amounts below one rupee', () {
      expect(AmountToWords.convert(0.5), 'Fifty Paise Only');
      expect(AmountToWords.convert(0.01), 'One Paise Only');
      expect(AmountToWords.convert(-0.5), 'Minus Fifty Paise Only');
    });

    test('singular rupee', () {
      expect(AmountToWords.convert(1), 'One Rupee Only');
      expect(
          AmountToWords.convert(1.25), 'One Rupee and Twenty Five Paise Only');
    });

    test('negative amounts', () {
      expect(AmountToWords.convert(-1500),
          'Minus One Thousand Five Hundred Rupees Only');
    });

    test('rounds to the nearest paisa', () {
      expect(AmountToWords.convert(1.005), 'One Rupee and One Paise Only');
      expect(AmountToWords.convert(10.999), 'Eleven Rupees Only');
    });

    test('numbers across the Indian scale', () {
      expect(AmountToWords.convert(11), 'Eleven Rupees Only');
      expect(AmountToWords.convert(20), 'Twenty Rupees Only');
      expect(AmountToWords.convert(101), 'One Hundred and One Rupees Only');
      expect(AmountToWords.convert(100000), 'One Lakh Rupees Only');
      expect(
          AmountToWords.convert(2500050), 'Twenty Five Lakh Fifty Rupees Only');
      expect(AmountToWords.convert(1e12), 'One Lakh Crore Rupees Only');
      expect(AmountToWords.convert(123456789),
          'Twelve Crore Thirty Four Lakh Fifty Six Thousand Seven Hundred and Eighty Nine Rupees Only');
    });

    test('rejects non-finite and oversized amounts', () {
      expect(() => AmountToWords.convert(double.nan), throwsArgumentError);
      expect(() => AmountToWords.convert(double.infinity), throwsArgumentError);
      expect(() => AmountToWords.convert(1e20), throwsArgumentError);
      expect(() => AmountToWords.convert(-1e20), throwsArgumentError);
    });

    test('accepts the largest supported amount', () {
      expect(AmountToWords.convert(90071992547409.91), endsWith('Paise Only'));
    });
  });

  group('FinancialYear', () {
    test('Get Financial Year', () {
      expect(FinancialYear.get(DateTime(2023, 3, 31)), '2022-23');
      expect(FinancialYear.get(DateTime(2023, 4, 1)), '2023-24');
    });

    test('century rollover', () {
      expect(FinancialYear.get(DateTime(2099, 4, 1)), '2099-00');
      expect(FinancialYear.get(DateTime(2100, 3, 31)), '2099-00');
      expect(FinancialYear.get(DateTime(2009, 4, 1)), '2009-10');
    });

    test('isDateInFY', () {
      expect(
          FinancialYear.isDateInFY(DateTime(2024, 1, 15), '2023-24'), isTrue);
      expect(
          FinancialYear.isDateInFY(DateTime(2024, 4, 1), '2023-24'), isFalse);
    });

    test('current matches today', () {
      expect(FinancialYear.current(), FinancialYear.get(DateTime.now()));
    });
  });

  group('TaxValidators', () {
    test('Validate PAN', () {
      expect(TaxValidators.isValidPan('ABCPE1234F'), isTrue);
      expect(TaxValidators.isValidPan('abcpe1234f'), isTrue);
      expect(TaxValidators.isValidPan('ABCPE12345'), isFalse);
      expect(TaxValidators.isValidPan(''), isFalse);
      expect(TaxValidators.isValidPan(' ABCPE1234F'), isFalse);
      expect(TaxValidators.isValidPan('ABCPE1234FG'), isFalse);
    });

    test('PAN holder type (4th character) is checked', () {
      for (final type in 'ABCFGHJLPT'.split('')) {
        expect(TaxValidators.isValidPan('AAA${type}K1234Z'), isTrue,
            reason: type);
      }
      for (final type in 'DEIKMNOQRSUVWXYZ'.split('')) {
        expect(TaxValidators.isValidPan('AAA${type}K1234Z'), isFalse,
            reason: type);
      }
    });

    test('Validate GSTIN', () {
      expect(TaxValidators.isValidGstin('27ABCPE1234F1Z5'), isTrue);
      expect(TaxValidators.isValidGstin('27ABCPE1234F1'), isFalse);
      expect(TaxValidators.isValidGstin('27abcpe1234f1z5'), isTrue);
      expect(TaxValidators.isValidGstin('27ABCPE1234F0Z5'), isFalse);
      expect(TaxValidators.isValidGstin('27ABCPE1234F1Y5'), isFalse);
      // Embedded PAN with an invalid holder type (D).
      expect(TaxValidators.isValidGstin('27ABCDE1234F1Z5'), isFalse);
    });

    test('GSTIN checksum is opt-in', () {
      // Published sample GSTINs with correct check characters.
      expect(
          TaxValidators.isValidGstin('27AAPFU0939F1ZV', verifyChecksum: true),
          isTrue);
      expect(
          TaxValidators.isValidGstin('29AAGCB7383J1Z4', verifyChecksum: true),
          isTrue);
      expect(
          TaxValidators.isValidGstin('27aapfu0939f1zv', verifyChecksum: true),
          isTrue);
      // A single mistyped character is caught.
      expect(
          TaxValidators.isValidGstin('27AAPFU0939F1ZX', verifyChecksum: true),
          isFalse);
      expect(
          TaxValidators.isValidGstin('27AAPFU0938F1ZV', verifyChecksum: true),
          isFalse);
      // Format-only check accepts a wrong check character.
      expect(TaxValidators.isValidGstin('27ABCPE1234F1Z5'), isTrue);
      expect(
          TaxValidators.isValidGstin('27ABCPE1234F1Z5', verifyChecksum: true),
          isFalse);
    });

    test('Validate TAN', () {
      expect(TaxValidators.isValidTan('MUMA12345B'), isTrue);
      expect(TaxValidators.isValidTan('muma12345b'), isTrue);
      expect(TaxValidators.isValidTan('MUM123456B'), isFalse);
      expect(TaxValidators.isValidTan(''), isFalse);
    });
  });
}
