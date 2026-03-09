# indian_tax_utils

Tax calculation utilities for Indian ERP and accounting apps.

## Features

✔ GST calculator  
✔ GST inclusive/exclusive calculator  
✔ CGST / SGST / IGST split  
✔ Invoice totals calculator  
✔ Discount helper  
✔ TDS and TCS calculator  
✔ Rounding utilities  
✔ Indian Currency Formatting (₹ #,##,###.##)
✔ Amount to Words (Lakhs, Crores)
✔ Financial Year Calculator
✔ PAN / GSTIN / TAN Validators

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  indian_tax_utils: ^0.0.1
```

## Usage

```dart
import 'package:indian_tax_utils/indian_tax_utils.dart';

void main() {
  final gst = GstCalculator.calculate(
    amount: 1000,
    rate: 18,
    intraState: true,
  );

  print("CGST: ${gst.cgst}");
  print("SGST: ${gst.sgst}");

  final invoice = InvoiceCalculator.calculate(
    subtotal: 5000,
    discount: 200,
    gstRate: 18,
  );

  print(invoice.total);

  final tds = TdsCalculator.calculate(
    amount: 10000,
    rate: 10,
  );

  print(tds.netAmount);
}
```

## Modules

- **GST**: CGST, SGST, IGST calculations and inclusive to exclusive extraction.
- **TDS**: Tax Deducted at Source calculations.
- **Invoice**: Subtotal, discount, tax, total, and rounded total.
- **Discount**: Percentage and fixed discount helpers.
- **Rounding**: Round to nearest integer.
