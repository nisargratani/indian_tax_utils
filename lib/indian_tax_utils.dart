/// Tax and billing utilities for Indian apps: GST (CGST/SGST/IGST), TDS and
/// TCS, invoice totals, discounts, rounding, Indian currency formatting,
/// amount-to-words, financial years, and PAN/GSTIN/TAN validation.
///
/// All APIs are synchronous, stateless static methods, safe to call from any
/// isolate and on every platform.
library;

export 'src/gst/gst_calculator.dart';
export 'src/gst/gst_inclusive_calculator.dart';
export 'src/gst/gst_split.dart';
export 'src/gst/gst_rate.dart';

export 'src/tds/tds_calculator.dart';
export 'src/tds/tcs_calculator.dart';

export 'src/invoice/invoice_calculator.dart';
export 'src/invoice/invoice_item.dart';

export 'src/discount/discount_calculator.dart';

export 'src/rounding/rounding_helper.dart';

export 'src/utils/currency_helper.dart';
export 'src/utils/amount_to_words.dart';
export 'src/utils/financial_year.dart';
export 'src/utils/validators.dart';

export 'src/models/gst_result.dart';
export 'src/models/invoice_result.dart';
export 'src/models/tds_result.dart';
