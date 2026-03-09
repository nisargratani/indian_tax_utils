import 'package:test/test.dart';
    import 'package:indian_tax_utils/indian_tax_utils.dart';
    
    void main() {
      group('CurrencyHelper', () {
        test("Format Indian Currency", () {
          expect(CurrencyHelper.format(123456.78), "₹ 1,23,456.78");
          expect(CurrencyHelper.format(100.50), "₹ 100.50");
          expect(CurrencyHelper.format(1000.50), "₹ 1,000.50");
          expect(CurrencyHelper.format(10000000), "₹ 1,00,00,000.00");
        });
    
        test("Format without symbol", () {
          expect(CurrencyHelper.format(123456.78, symbol: false), "1,23,456.78");
        });
      });
    
      group('AmountToWords', () {
        test("Convert amount to words", () {
          expect(AmountToWords.convert(123456.78), "One Lakh Twenty Three Thousand Four Hundred and Fifty Six Rupees and Seventy Eight Paise Only");
          expect(AmountToWords.convert(100), "One Hundred Rupees Only");
          expect(AmountToWords.convert(10000000), "One Crore Rupees Only");
        });
      });
    
      group('FinancialYear', () {
        test("Get Financial Year", () {
          expect(FinancialYear.get(DateTime(2023, 3, 31)), "2022-23");
          expect(FinancialYear.get(DateTime(2023, 4, 1)), "2023-24");
        });
      });
    
      group('TaxValidators', () {
        test("Validate PAN", () {
          expect(TaxValidators.isValidPan("ABCDE1234F"), isTrue);
          expect(TaxValidators.isValidPan("abcde1234f"), isTrue);
          expect(TaxValidators.isValidPan("ABCDE12345"), isFalse);
        });
    
        test("Validate GSTIN", () {
          expect(TaxValidators.isValidGstin("27ABCDE1234F1Z5"), isTrue);
          expect(TaxValidators.isValidGstin("27ABCDE1234F1"), isFalse);
        });
      });
    }
    
