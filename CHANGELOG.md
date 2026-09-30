## 0.0.3

This release contains **breaking changes**. See "Migrating from 0.0.2" in
the README for the short version.

### Breaking changes

- **Single public library.** Implementation files moved under `lib/src/`.
  Import `package:indian_tax_utils/indian_tax_utils.dart`; per-file imports
  such as `package:indian_tax_utils/gst/gst_calculator.dart` no longer exist.
- **`GstRate.twentyeight` renamed to `GstRate.twentyEight`** (Dart naming
  conventions).
- **`GstRate` gained a `forty` value**, so an exhaustive `switch` over
  `GstRate` needs a new case.
- **Utility classes are `abstract final`.** `GstCalculator`,
  `GstInclusiveCalculator`, `GstSplit`, `InvoiceCalculator`,
  `DiscountCalculator`, `TdsCalculator`, `TcsCalculator`, `RoundingHelper`,
  `CurrencyHelper`, `AmountToWords`, `FinancialYear` and `TaxValidators`
  only ever had static members. Their unused public constructors are gone,
  and they can no longer be extended or implemented.
- **Invalid input throws `ArgumentError`** instead of returning `NaN`,
  `Infinity` or negative taxes. Invalid input means:
  - a non-finite amount;
  - a negative rate;
  - a TDS/TCS rate or a discount percentage above 100;
  - a discount that is negative or larger than the amount it applies to.

  Negative amounts, such as credit notes, are still accepted.
  `AmountToWords.convert` and `CurrencyHelper.format` likewise throw an
  `ArgumentError` for `NaN`, infinite or out-of-range amounts. Previously
  they threw `UnsupportedError` or returned garbage.
- **`TaxValidators.isValidPan` checks the holder type.** The 4th character
  must be one of `A B C F G H J L P T`. `isValidGstin` applies the same check
  to the PAN inside the GSTIN. For example, `ABCDE1234F` is no longer a
  valid PAN.
- **Output changes:**
  - `CurrencyHelper.format` puts the minus sign before the symbol
    (`-₹ 1,234.50`, was `₹ -1,234.50`).
  - `AmountToWords.convert(0)` returns `Zero Rupees Only` (was `Zero`).
  - `AmountToWords.convert(1)` returns `One Rupee Only` (was `One Rupees Only`).
  - Decimal halves now round up as written (`1.005` → `1.01`).

### Bug fixes

- `AmountToWords.convert`: amounts under ₹1 no longer produce
  `" Rupees and Fifty Paise Only"` (now `"Fifty Paise Only"`), and negative
  ones no longer get a double space. Very large amounts no longer overflow
  into incorrect words.
- `CurrencyHelper.format`: small negative amounts no longer format as
  `₹ -0.00`, and decimal halves round up as written (`1.005` → `₹ 1.01`).
  Infinity and values ≥ 10^21 no longer produce garbled output, and a bad
  `decimals` value now reports `decimals` as the argument name.
- `RoundingHelper.roundToNearest` no longer returns `-0.0`, and no longer
  rounds noisy values such as `1.005 * 100` (`100.49999999999999`) down.

### New

- `InvoiceCalculator.fromItems` totals a list of `InvoiceItem`s with mixed
  GST rates and discounts.
- `InvoiceResult.roundOff`: the round-off adjustment printed on invoices.
- `RoundingHelper.roundTo` rounds to paise (or any number of decimals).
- `TaxValidators.isValidGstin(..., verifyChecksum: true)` verifies the GSTIN
  check character.
- `GstRate.forty` (the 40% slab effective 22 September 2025) and
  `GstRate.percentage` (the rate as a `double`, ready for the calculators).
- `GstResult`, `InvoiceResult`, `TdsResult` and `InvoiceItem` have `const`
  constructors and value equality (`==`/`hashCode`); `InvoiceItem` has a
  `toString`.

### Other

- Validator regular expressions are compiled once instead of on every call.
- Rewrote the README with an example for every API, plus sections on error
  handling, migration and limitations. Expanded the API documentation and the example.
- Adopted `package:lints` recommended rules and added CI (format, analyze,
  tests on Dart 3.0 and stable, publish dry-run).
- Added pub.dev topics and an issue tracker link.

## 0.0.2

- Enforced `public_member_api_docs` lint rule via `analysis_options.yaml` to ensure 100% documentation coverage.
- Added missing dartdoc comments for all public APIs (classes, methods, enums, models) across the entire repository to improve package documentation.

## 0.0.1

- Initial release.
- GST Calculator (CGST, SGST, IGST).
- GST Inclusive/Exclusive Calculator.
- TDS Calculator.
- Invoice Calculator.
- Discount Calculator.
- Rounding Helper.
