# indian_tax_utils

Tax and billing utilities for Indian ERP, accounting and point-of-sale apps:
GST, TDS/TCS, invoice totals, discounts, rounding, Indian currency formatting,
amount-to-words, financial years and PAN/GSTIN/TAN validation.

Pure Dart with no dependencies. It works in Flutter apps on every platform
(Android, iOS, web, macOS, Windows, Linux) and in server or CLI Dart code.

## Features

- **GST**: CGST/SGST (intra-state) or IGST (inter-state) on exclusive amounts;
  base and tax extraction from inclusive amounts; standard rate slabs
- **Invoices**: single-rate totals or line items with mixed GST rates,
  pre-tax discounts, rounded total and round-off
- **TDS and TCS**
- **Discounts**: percentage and flat
- **Rounding**: to the rupee or to paise, half away from zero, safe against
  floating-point noise
- **Currency formatting**: `₹ 1,23,45,678.90`
- **Amount to words**: `One Lakh Twenty Three Thousand ... Rupees Only`
- **Financial year**: `2024-25`
- **Validators**: PAN, TAN, and GSTIN with optional checksum verification

## Installation

```sh
dart pub add indian_tax_utils
# or, in a Flutter app
flutter pub add indian_tax_utils
```

Or add it to `pubspec.yaml` yourself:

```yaml
dependencies:
  indian_tax_utils: ^0.1.0
```

## Quick start

```dart
import 'package:indian_tax_utils/indian_tax_utils.dart';

void main() {
  final gst = GstCalculator.calculate(
    amount: 1000,
    rate: 18,
    intraState: true,
  );
  print(gst.cgst); // 90.0
  print(gst.sgst); // 90.0

  final invoice = InvoiceCalculator.calculate(
    subtotal: 5000,
    discount: 200,
    gstRate: 18,
  );
  print(invoice.total); // 5664.0

  final tds = TdsCalculator.calculate(amount: 10000, rate: 10);
  print(tds.netAmount); // 9000.0
}
```

All APIs are synchronous static methods with no state, so there is nothing
to initialise or dispose (the utility classes cannot be instantiated).
Result and item classes have `const` constructors and value equality. They are safe to call from `build` methods, from
isolates and concurrently.

## Usage

### GST

```dart
// Tax-exclusive amount: intra-state splits into CGST + SGST.
final intra = GstCalculator.calculate(amount: 1000, rate: 18, intraState: true);
// intra.cgst == 90, intra.sgst == 90, intra.igst == 0, intra.totalTax == 180

// Inter-state charges IGST.
final inter = GstCalculator.calculate(amount: 1000, rate: 18, intraState: false);
// inter.igst == 180

// Use the rate slabs (5%, 18%, 40%, plus legacy 12% and 28%:
// GstRate.twelve, GstRate.twentyEight).
GstCalculator.calculate(
  amount: 1000,
  rate: GstRate.five.percentage,
  intraState: true,
);

// Tax-inclusive amount (e.g. an MRP): extract the base and the GST.
final parts = GstInclusiveCalculator.extractGST(amount: 118, rate: 18);
// parts['base'] == 100, parts['tax'] == 18

// Split a known tax amount.
final split = GstSplit.split(totalTax: parts['tax']!, intraState: true);
// split.cgst == 9, split.sgst == 9
```

### Invoices

A single GST rate:

```dart
final r = InvoiceCalculator.calculate(
  subtotal: 5000,
  discount: 200, // applied before tax
  gstRate: 18,   // default
);
// r.tax == 864, r.total == 5664, r.roundedTotal == 5664, r.roundOff == 0
```

Line items with different rates:

```dart
final bill = InvoiceCalculator.fromItems([
  InvoiceItem(description: 'Rice', quantity: 10, unitPrice: 60, taxRate: 5),
  InvoiceItem(description: 'Soap', quantity: 3, unitPrice: 45.5, taxRate: 18),
  InvoiceItem(
    description: 'Oil',
    quantity: 1,
    unitPrice: 200,
    taxRate: 5,
    discount: 20, // flat, on the whole line
  ),
]);
// bill.subtotal == 936.5, bill.discount == 20, bill.tax ≈ 63.57
// bill.total ≈ 980.07, bill.roundedTotal == 980, bill.roundOff == -0.07
```

Each `InvoiceItem` also exposes `subtotal`, `taxableAmount`, `taxAmount` and
`total` for printing line details.

### TDS and TCS

```dart
final tds = TdsCalculator.calculate(amount: 10000, rate: 10);
// tds.tds == 1000, tds.netAmount == 9000 (amount - TDS)

final tcs = TcsCalculator.calculate(amount: 10000, rate: 0.1);
// tcs.tds == 10 (the TCS amount), tcs.netAmount == 10010 (amount + TCS)
```

Both return a `TdsResult`; for TCS its `tds` field holds the TCS amount.
Section thresholds are not applied.

### Discounts

```dart
DiscountCalculator.percentage(amount: 1000, percent: 10); // 100.0, the discount
DiscountCalculator.fixed(amount: 1000, discount: 100);    // 900.0, the amount after it
```

### Rounding

```dart
RoundingHelper.roundToNearest(100.49); // 100.0
RoundingHelper.roundToNearest(100.50); // 101.0
RoundingHelper.roundTo(8.9991);        // 9.0  (nearest paisa)
RoundingHelper.roundTo(1.005);         // 1.01 (not 1.00)
```

Calculator results are **not** rounded, so you can decide where rounding
happens (per line, per invoice, or per tax component). Rounding is half away
from zero and corrects for binary floating-point noise.

### Currency formatting

```dart
CurrencyHelper.format(12345678.9);                  // ₹ 1,23,45,678.90
CurrencyHelper.format(1500, symbol: false);         // 1,500.00
CurrencyHelper.format(1234567.6, decimals: 0);      // ₹ 12,34,568
CurrencyHelper.format(-1234.5);                     // -₹ 1,234.50
```

### Amount to words

```dart
AmountToWords.convert(123456.78);
// One Lakh Twenty Three Thousand Four Hundred and Fifty Six Rupees and Seventy Eight Paise Only
AmountToWords.convert(1);   // One Rupee Only
AmountToWords.convert(0.5); // Fifty Paise Only
AmountToWords.convert(0);   // Zero Rupees Only
```

### Financial year

```dart
FinancialYear.get(DateTime(2024, 3, 31));                 // 2023-24
FinancialYear.get(DateTime(2024, 4, 1));                  // 2024-25
FinancialYear.isDateInFY(DateTime(2024, 1, 15), '2023-24'); // true
FinancialYear.current();                                  // FY for today
```

### Validators

```dart
TaxValidators.isValidPan('ABCPE1234F');      // true (case-insensitive)
TaxValidators.isValidPan('ABCDE1234F');      // false: D is not a holder type
TaxValidators.isValidTan('MUMA12345B');      // true
TaxValidators.isValidGstin('27AAPFU0939F1ZV'); // true (format only)

// Also verify the GSTIN check character to catch typing mistakes.
TaxValidators.isValidGstin('27AAPFU0939F1ZV', verifyChecksum: true); // true
TaxValidators.isValidGstin('27AAPFU0939F1ZX', verifyChecksum: true); // false
```

A PAN's 4th character must be a valid holder type (`P` individual, `C`
company, `H` HUF, `F` firm/LLP, `T` trust, `A`, `B`, `G`, `J` or `L`); the
PAN inside a GSTIN is checked the same way. Validators check structure only;
they cannot tell you whether an identifier has actually been issued. Input must not contain spaces, so trim user input
first.

## Error handling

Invalid input throws an `ArgumentError` whose `name` identifies the bad
argument, instead of silently returning `NaN`, `Infinity` or a negative tax:

- amounts that are `NaN` or infinite
- negative tax rates (TDS/TCS rates and discount percentages must also be
  at most 100)
- discounts that are negative or larger than the amount they apply to

```dart
try {
  InvoiceCalculator.calculate(subtotal: 100, discount: 150);
} on ArgumentError catch (e) {
  print('${e.name}: ${e.message}'); // discount: Must not exceed ...
}
```

Negative amounts are allowed (for example on credit notes), as long as any
discount is zero.

## Migrating from 0.0.x

0.1.0 contains breaking changes; see the [changelog](CHANGELOG.md) for the
full list. The ones most likely to need code changes:

- Import only `package:indian_tax_utils/indian_tax_utils.dart`. Imports
  such as `package:indian_tax_utils/gst/gst_calculator.dart` no longer exist.
- `GstRate.twentyeight` is now `GstRate.twentyEight`.
- Utility classes such as `GstCalculator` can no longer be instantiated or
  extended. Their methods were always static, so `GstCalculator.calculate(...)`
  calls are unaffected; only remove any `GstCalculator()` constructor calls.
- Invalid input throws `ArgumentError`; see [Error handling](#error-handling).
- Output changes: negative amounts format as `-₹ 1,234.50`,
  `AmountToWords.convert(0)` returns `Zero Rupees Only`, and PANs/GSTINs
  with an invalid holder type are rejected.

## Limitations

- Values are `double`s. That is precise enough for invoice amounts, but
  round results with `RoundingHelper` before you store or display them.
- `AmountToWords` supports amounts up to about 90 lakh crore
  (2^53 − 1 paise), and `CurrencyHelper` supports amounts below 10^21.
- GSTIN validation covers regular taxpayer GSTINs (with `Z` as the 14th
  character). Special registrations such as TDS/TCS deductors are rejected.
- Tax rules such as TDS thresholds, reverse charge and cess are not modelled.
  Pass the rate that applies.

## Compatibility

Requires Dart 3.0 or later (Flutter 3.10 or later). No platform-specific code.
