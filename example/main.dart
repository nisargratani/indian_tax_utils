import 'package:indian_tax_utils/indian_tax_utils.dart';

void main() {
  print('--- GST Calculation ---');
  final gst = GstCalculator.calculate(
    amount: 1000,
    rate: GstRate.eighteen.percentage,
    intraState: true,
  );
  print('Amount: 1000, Rate: 18%, Intra-state: true');
  print('CGST: ${CurrencyHelper.format(gst.cgst)}');
  print('SGST: ${CurrencyHelper.format(gst.sgst)}');
  print('Total Tax: ${CurrencyHelper.format(gst.totalTax)}');

  print('\n--- GST Inclusive Extraction ---');
  final extracted = GstInclusiveCalculator.extractGST(amount: 118, rate: 18);
  final split = GstSplit.split(totalTax: extracted['tax']!, intraState: false);
  print('Inclusive Amount: 118, Rate: 18%, Inter-state');
  print('Base: ${CurrencyHelper.format(extracted['base']!)}');
  print('IGST: ${CurrencyHelper.format(split.igst)}');

  print('\n--- Invoice (single rate) ---');
  final invoice = InvoiceCalculator.calculate(
    subtotal: 5000,
    discount: 200,
    gstRate: 18,
  );
  print('Subtotal: 5000, Discount: 200, GST: 18%');
  print('Tax: ${CurrencyHelper.format(invoice.tax)}');
  print('Total: ${CurrencyHelper.format(invoice.total)}');
  print('Rounded Total: ${CurrencyHelper.format(invoice.roundedTotal)}');

  print('\n--- Invoice (line items, mixed rates) ---');
  final items = [
    InvoiceItem(description: 'Rice', quantity: 10, unitPrice: 60, taxRate: 5),
    InvoiceItem(description: 'Soap', quantity: 3, unitPrice: 45.5),
    InvoiceItem(
      description: 'Oil',
      quantity: 1,
      unitPrice: 200,
      taxRate: 5,
      discount: 20,
    ),
  ];
  for (final item in items) {
    print('${item.description.padRight(6)} '
        '${CurrencyHelper.format(item.taxableAmount).padLeft(10)} '
        '+ GST ${item.taxRate}%');
  }
  final bill = InvoiceCalculator.fromItems(items);
  print('Taxable:   ${CurrencyHelper.format(bill.subtotal - bill.discount)}');
  print('GST:       ${CurrencyHelper.format(bill.tax)}');
  print('Round off: ${CurrencyHelper.format(bill.roundOff)}');
  print('Total:     ${CurrencyHelper.format(bill.roundedTotal)}');
  print('In words:  ${AmountToWords.convert(bill.roundedTotal)}');

  print('\n--- TDS / TCS ---');
  final tds = TdsCalculator.calculate(amount: 10000, rate: 10);
  print('TDS @10% on 10000: ${tds.tds}, net payable: ${tds.netAmount}');
  final tcs = TcsCalculator.calculate(amount: 10000, rate: 0.1);
  print('TCS @0.1% on 10000: ${tcs.tds}, receivable: ${tcs.netAmount}');

  print('\n--- Discount ---');
  print('10% of 1000: '
      '${DiscountCalculator.percentage(amount: 1000, percent: 10)}');
  print('1000 less 100: '
      '${DiscountCalculator.fixed(amount: 1000, discount: 100)}');

  print('\n--- Rounding ---');
  print('100.49 -> ${RoundingHelper.roundToNearest(100.49)}');
  print('100.50 -> ${RoundingHelper.roundToNearest(100.50)}');
  print('8.9991 -> ${RoundingHelper.roundTo(8.9991)} (to paise)');

  print('\n--- Amount to Words ---');
  print(AmountToWords.convert(123456.78));

  print('\n--- Financial Year ---');
  print('FY for 2024-03-31: ${FinancialYear.get(DateTime(2024, 3, 31))}');
  print('FY for 2024-04-01: ${FinancialYear.get(DateTime(2024, 4, 1))}');
  print('Current FY: ${FinancialYear.current()}');

  print('\n--- Validators ---');
  print('PAN ABCPE1234F: ${TaxValidators.isValidPan('ABCPE1234F')}');
  print('GSTIN 27AAPFU0939F1ZV (with checksum): '
      '${TaxValidators.isValidGstin('27AAPFU0939F1ZV', verifyChecksum: true)}');
  print('TAN MUMA12345B: ${TaxValidators.isValidTan('MUMA12345B')}');

  print('\n--- Error handling ---');
  try {
    InvoiceCalculator.calculate(subtotal: 100, discount: 150);
  } on ArgumentError catch (e) {
    print('Rejected: ${e.name} - ${e.message}');
  }
}
