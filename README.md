# indian_tax_utils

Tax and billing utilities for Indian ERP, accounting and point-of-sale apps:
GST, TDS/TCS, invoice totals, discounts, rounding, Indian currency formatting,
amount-to-words, financial years and PAN/GSTIN/TAN validation.

Pure Dart with no dependencies. It works in Flutter apps on every platform
(Android, iOS, web, macOS, Windows, Linux) and in server or CLI Dart code.

## Features

- **GST**: CGST/SGST (intra-state) or IGST (inter-state) on exclusive amounts,
  optionally rounded to paise so the components add up; base and tax
  extraction from inclusive amounts; standard rate slabs
- **Invoices**: single-rate totals or line items with mixed GST rates,
  pre-tax discounts, optional per-line tax rounding, rounded total and
  round-off
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

// Use the rate slabs: 0%, 5%, 18%, 40% and the special 3% rate for gold,
// silver and jewellery (GstRate.three). GstRate.twelve and
// GstRate.twentyEight are kept for historical invoices: 12% largely moved to
// 5% on 22 September 2025, and no goods carry 28% since 1 February 2026.
GstCalculator.calculate(
  amount: 1000,
  rate: GstRate.five.percentage,
  intraState: true,
);

// Rates that are not whole numbers, such as 0.25% (rough precious stones)
// and 1.5% (cut and polished diamonds), have no GstRate value: pass a double.
GstCalculator.calculate(amount: 1000, rate: 1.5, intraState: false);

// Tax-inclusive amount (e.g. an MRP): extract the base and the GST.
final parts = GstInclusiveCalculator.extractGST(amount: 118, rate: 18);
// parts['base'] == 100, parts['tax'] == 18

// Split a known tax amount.
final split = GstSplit.split(totalTax: parts['tax']!, intraState: true);
// split.cgst == 9, split.sgst == 9
```

#### GST rounded to paise

Results are not rounded by default. When you print GST on an invoice, pass
`roundToPaise: true` so that the printed amounts add up:

```dart
GstCalculator.calculate(
    amount: 10.25, rate: 18, intraState: true, roundToPaise: true);
// cgst 0.92, sgst 0.92, totalTax 1.84
GstCalculator.calculate(
    amount: 10.25, rate: 18, intraState: false, roundToPaise: true);
// igst 1.85, totalTax 1.85

// An MRP of ₹10 inclusive of 18% GST, sold intra-state.
final mrp = GstInclusiveCalculator.extractGST(amount: 10, rate: 18);
final gst = GstSplit.split(
    totalTax: mrp['tax']!, intraState: true, roundToPaise: true);
// gst.cgst == 0.76, gst.sgst == 0.76, gst.totalTax == 1.52
// Print the taxable value as 10 - gst.totalTax, which is 8.48.
```

CGST and SGST are separate levies at half the rate each, so each is rounded
to paise and `totalTax` is their sum. Rounding the unrounded results
yourself does not always add up: on 10.25 at 18%, CGST and SGST are 0.9225
each, which print as 0.92 + 0.92 = 1.84, but the total of 1.845 prints as
1.85.

A total that is already rounded to an odd number of paise cannot be split
into equal paise halves: `GstSplit.split(totalTax: 0.05, intraState: true,
roundToPaise: true)` gives 0.03 + 0.03 = 0.06. Where you have the taxable
value, use `GstCalculator.calculate` instead.

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

By default `tax` is the exact sum of the lines' `taxAmount`. If your invoice
prints each line's tax rounded to paise, pass `roundTaxPerLine: true` so
that the totals match the printed lines:

```dart
final pens = [
  for (var i = 0; i < 3; i++)
    InvoiceItem(description: 'Pen', quantity: 1, unitPrice: 10.25),
];
// Each line's tax is 1.845, printed as 1.85.
InvoiceCalculator.fromItems(pens);                        // tax 5.535, total 36.285
InvoiceCalculator.fromItems(pens, roundTaxPerLine: true); // tax 5.55, total 36.30
```

`roundedTotal` is the total rounded to paise, as printed, and then to the
nearest rupee, half away from zero: a total of 118.4956 prints as 118.50
and is rounded to 119. `roundOff` is `roundedTotal` minus the total rounded
to paise, so an invoice printed with paise-rounded amounts foots. For
example, 50.30 at 5% prints tax 2.52 (2.515) and round off 0.18, and
50.30 + 2.52 + 0.18 = 53.

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

Calculator results are **not** rounded by default, so you can decide where
rounding happens. Rounding each result on its own can leave a printed
invoice that does not add up, so for GST components pass
`roundToPaise: true` (see [GST rounded to paise](#gst-rounded-to-paise)),
and for invoices that print tax per line pass `roundTaxPerLine: true` to
`InvoiceCalculator.fromItems`. Rounding is half away from zero and corrects
for binary floating-point noise.

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
AmountToWords.convert(1);    // One Rupee Only
AmountToWords.convert(0.5);  // Fifty Paise Only
AmountToWords.convert(1.01); // One Rupee and One Paisa Only
AmountToWords.convert(0);    // Zero Rupees Only
```

### Financial year

```dart
FinancialYear.get(DateTime(2024, 3, 31));                   // 2023-24
FinancialYear.get(DateTime(2024, 4, 1));                    // 2024-25
FinancialYear.get(DateTime.parse('2026-03-31T19:00:00Z'));  // 2026-27
FinancialYear.isDateInFY(DateTime(2024, 1, 15), '2023-24'); // true
FinancialYear.current();                                    // FY for today in India
```

The financial year follows the date in India. A UTC `DateTime`, such as a
timestamp parsed from an API with `Z` or an offset, is converted to Indian
Standard Time (UTC+05:30) first: 2026-03-31T19:00Z is 00:30 IST on 1 April
2026, so it is in 2026-27. A local `DateTime` is used as a calendar date
without conversion, so a date a user picked never shifts. `current()` uses
today's date in India, whatever the device's or server's time zone.

### Validators

```dart
TaxValidators.isValidPan('ABCPE1234F');      // true (case-insensitive)
TaxValidators.isValidPan('ABCDE1234F');      // false: D is not a holder type
TaxValidators.isValidTan('MUMA12345B');      // true
TaxValidators.isValidGstin('27AAPFU0939F1ZV'); // true (format only)
TaxValidators.isValidGstin('00AAPFU0939F1ZB'); // false: 00 is not a state code
TaxValidators.isValidPan('ABıPE1234F');        // false: ı is not ASCII

// Also verify the GSTIN check character to catch typing mistakes.
TaxValidators.isValidGstin('27AAPFU0939F1ZV', verifyChecksum: true); // true
TaxValidators.isValidGstin('27AAPFU0939F1ZX', verifyChecksum: true); // false
```

A PAN's 4th character must be a valid holder type (`P` individual, `C`
company, `H` HUF, `F` firm/LLP, `T` trust, `A`, `B`, `G`, `J` or `L`); the
PAN inside a GSTIN is checked the same way. A GSTIN's state code must be one
in use: `01` to `38`, `97` (Other Territory) or `99` (Centre Jurisdiction).
Validators check structure only; they cannot tell you whether an identifier
has actually been issued. Input must contain only ASCII letters and digits:
spaces, and look-alikes such as `ı` (dotless i), are rejected, so trim user
input first.

## Error handling

Invalid input throws an `ArgumentError` whose `name` identifies the bad
argument, instead of silently returning `NaN`, `Infinity` or a negative tax:

- amounts that are `NaN` or infinite
- negative tax rates (TDS/TCS rates and discount percentages must also be
  at most 100)
- discounts that are negative or larger than the amount they apply to
  (an excess of floating-point noise is ignored, so a discount of 139.93 on
  `7 × 19.99`, which is `139.92999999999998`, is a full discount)
- amounts so large that a result would not be finite, such as
  `GstCalculator.calculate(amount: 1e307, rate: 18, intraState: false)`,
  where `amount * rate` overflows

```dart
try {
  InvoiceCalculator.calculate(subtotal: 100, discount: 150);
} on ArgumentError catch (e) {
  print('${e.name}: ${e.message}'); // discount: Must not exceed ...
}
```

Negative amounts are allowed (for example on credit notes), as long as any
discount is zero.

## Migrating from 0.0.4

0.1.0 changes some results; see the [changelog](CHANGELOG.md) for details.
New parameters are opt-in, but these changes apply without any code change:

- `InvoiceResult.roundedTotal` is rounded from the total as printed (to
  paise). About 1 invoice in 200 changes: a total of 118.4956, printed
  118.50, now gives 119 and a round off of 0.50 (was 118 and -0.50).
- `FinancialYear.get` and `isDateInFY` convert UTC `DateTime`s to IST, so a
  UTC timestamp between 00:00 and 05:30 IST on 1 April is now in the new
  financial year. `current()` uses today's date in India. Local
  `DateTime`s are unchanged.
- `TaxValidators.isValidGstin` rejects state codes that are never issued
  (`00`, `39` to `96`, and `98`).
- `isValidPan`, `isValidGstin` and `isValidTan` reject non-ASCII input such
  as `ABıPE1234F`, which they accepted because `ı` upper-cases to `I`.
- `AmountToWords.convert` says `One Paisa` instead of `One Paise`.
- `GstRate` has a new value, `three`, so an exhaustive `switch` over
  `GstRate` needs a new case.
- `RoundingHelper`, `CurrencyHelper` and `AmountToWords` no longer round
  some amounts above ₹10^11 up by a paisa: `956791942000.264` now rounds to
  `956791942000.26`.

## Migrating from 0.0.2

0.0.3 contains breaking changes; see the [changelog](CHANGELOG.md) for the
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
