import 'package:indian_tax_utils/indian_tax_utils.dart';

void main() {
  print("--- GST Calculation ---");
  final gst = GstCalculator.calculate(
    amount: 1000,
    rate: 18,
    intraState: true,
  );
  print("Amount: 1000, Rate: 18%, Intra-state: true");
  print("CGST: ${CurrencyHelper.format(gst.cgst)}");
  print("SGST: ${CurrencyHelper.format(gst.sgst)}");
  print("Total Tax: ${CurrencyHelper.format(gst.totalTax)}");

  print("\n--- Amount to Words ---");
  print("Total Tax in Words: ${AmountToWords.convert(gst.totalTax)}");

  print("\n--- Financial Year ---");
  print("FY for 2024-03-31: ${FinancialYear.get(DateTime(2024, 3, 31))}");
  print("FY for 2024-04-01: ${FinancialYear.get(DateTime(2024, 4, 1))}");
  print("Current FY: ${FinancialYear.current()}");

  print("\n--- Tax Validators ---");
  print("Is ABCDE1234F a valid PAN? ${TaxValidators.isValidPan("ABCDE1234F")}");
  print("Is 27ABCDE1234F1Z5 a valid GSTIN? ${TaxValidators.isValidGstin("27ABCDE1234F1Z5")}");

  print("\n--- GST Inclusive Extraction ---");
  final extracted = GstInclusiveCalculator.extractGST(
    amount: 118,
    rate: 18,
  );
  print("Inclusive Amount: 118, Rate: 18%");
  print("Base: ${extracted['base']}");
  print("Tax: ${extracted['tax']}");

  print("\n--- Invoice Calculation ---");
  final invoice = InvoiceCalculator.calculate(
    subtotal: 5000,
    discount: 200,
    gstRate: 18,
  );
  print("Subtotal: 5000, Discount: 200, GST: 18%");
  print("Tax: ${invoice.tax}");
  print("Total: ${invoice.total}");
  print("Rounded Total: ${invoice.roundedTotal}");

  print("\n--- TDS Calculation ---");
  final tds = TdsCalculator.calculate(
    amount: 10000,
    rate: 10,
  );
  print("Amount: 10000, Rate: 10%");
  print("TDS: ${tds.tds}");
  print("Net Amount: ${tds.netAmount}");

  print("\n--- Discount Calculation ---");
  final percDiscount = DiscountCalculator.percentage(amount: 1000, percent: 10);
  final fixedDiscount = DiscountCalculator.fixed(amount: 1000, discount: 100);
  print("Amount: 1000");
  print("10% Discount: $percDiscount");
  print("Fixed 100 Discount: $fixedDiscount");

  print("\n--- Rounding Helper ---");
  print("100.49 -> ${RoundingHelper.roundToNearest(100.49)}");
  print("100.50 -> ${RoundingHelper.roundToNearest(100.50)}");
}
