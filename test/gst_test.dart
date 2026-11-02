import 'dart:math';

import 'package:indian_tax_utils/indian_tax_utils.dart';
import 'package:test/test.dart';

void main() {
  group('GstCalculator', () {
    test('GST split intra state', () {
      final result = GstCalculator.calculate(
        amount: 1000,
        rate: 18,
        intraState: true,
      );

      expect(result.cgst, 90);
      expect(result.sgst, 90);
      expect(result.igst, 0);
      expect(result.totalTax, 180);
    });

    test('GST split inter state', () {
      final result = GstCalculator.calculate(
        amount: 1000,
        rate: 18,
        intraState: false,
      );

      expect(result.cgst, 0);
      expect(result.sgst, 0);
      expect(result.igst, 180);
      expect(result.totalTax, 180);
    });

    test('zero rate and zero amount give zero tax', () {
      expect(
        GstCalculator.calculate(amount: 1000, rate: 0, intraState: true)
            .totalTax,
        0,
      );
      expect(
        GstCalculator.calculate(amount: 0, rate: 18, intraState: false)
            .totalTax,
        0,
      );
    });

    test('negative amount (credit note) gives negative tax', () {
      final result =
          GstCalculator.calculate(amount: -1000, rate: 18, intraState: true);
      expect(result.cgst, -90);
      expect(result.totalTax, -180);
    });

    test('accepts GstRate.percentage', () {
      final result = GstCalculator.calculate(
        amount: 1000,
        rate: GstRate.forty.percentage,
        intraState: false,
      );
      expect(result.igst, 400);
    });

    test('rejects non-finite amount and invalid rate', () {
      expect(
        () => GstCalculator.calculate(
            amount: double.nan, rate: 18, intraState: true),
        throwsArgumentError,
      );
      expect(
        () => GstCalculator.calculate(
            amount: double.infinity, rate: 18, intraState: true),
        throwsArgumentError,
      );
      expect(
        () => GstCalculator.calculate(amount: 100, rate: -5, intraState: true),
        throwsArgumentError,
      );
    });

    test('rejects a result that is not finite', () {
      // amount * rate overflows although the tax itself would be finite.
      expect(
        () =>
            GstCalculator.calculate(amount: 1e307, rate: 18, intraState: false),
        throwsA(isA<ArgumentError>()
            .having((e) => e.name, 'name', 'amount')
            .having((e) => e.message, 'message', contains('not finite'))),
      );
      expect(
        () =>
            GstCalculator.calculate(amount: 1e307, rate: 18, intraState: true),
        throwsArgumentError,
      );
    });

    test('never returns negative zero', () {
      // A credit note on a nil-rated supply.
      for (final intraState in [true, false]) {
        final r = GstCalculator.calculate(
            amount: -100, rate: 0, intraState: intraState);
        for (final v in [r.cgst, r.sgst, r.igst, r.totalTax]) {
          expect(v.isNegative, isFalse);
        }
        expect(r.toString(), isNot(contains('-0.0')));
      }
    });
  });

  group('GstInclusiveCalculator', () {
    test('Extract GST from inclusive amount', () {
      final result = GstInclusiveCalculator.extractGST(
        amount: 118,
        rate: 18,
      );

      expect(result['base'], 100);
      expect(result['tax'], 18);
    });

    test('base + tax equals the inclusive amount', () {
      final result = GstInclusiveCalculator.extractGST(amount: 1000, rate: 18);
      expect(result['base']! + result['tax']!, closeTo(1000, 1e-9));
      expect(result['base'], closeTo(847.4576, 1e-4));
    });

    test('zero rate leaves everything in base', () {
      final result = GstInclusiveCalculator.extractGST(amount: 500, rate: 0);
      expect(result['base'], 500);
      expect(result['tax'], 0);
    });

    test('rejects a negative rate instead of returning Infinity', () {
      expect(
        () => GstInclusiveCalculator.extractGST(amount: 100, rate: -100),
        throwsArgumentError,
      );
    });
  });

  group('GstSplit', () {
    test('Split total tax intra state', () {
      final result = GstSplit.split(
        totalTax: 180,
        intraState: true,
      );

      expect(result.cgst, 90);
      expect(result.sgst, 90);
      expect(result.igst, 0);
    });

    test('Split total tax inter state', () {
      final result = GstSplit.split(totalTax: 180, intraState: false);
      expect(result.cgst, 0);
      expect(result.sgst, 0);
      expect(result.igst, 180);
      expect(result.totalTax, 180);
    });

    test('rejects non-finite tax', () {
      expect(
        () => GstSplit.split(totalTax: double.nan, intraState: true),
        throwsArgumentError,
      );
    });

    test('never returns negative zero', () {
      for (final intraState in [true, false]) {
        final r = GstSplit.split(totalTax: -0.0, intraState: intraState);
        for (final v in [r.cgst, r.sgst, r.igst, r.totalTax]) {
          expect(v.isNegative, isFalse);
        }
        expect(r.toString(), isNot(contains('-0.0')));
      }
      // Halving the smallest negative double underflows to -0.0.
      final tiny = GstSplit.split(totalTax: -5e-324, intraState: true);
      expect(tiny.cgst.isNegative, isFalse);
    });
  });

  group('GstRate', () {
    test('keeps existing values and indexes', () {
      expect(GstRate.values.take(5).map((r) => r.rate), [0, 5, 12, 18, 28]);
      expect(GstRate.twentyEight.index, 4);
    });

    test('has the 40% slab and a double percentage', () {
      expect(GstRate.forty.rate, 40);
      expect(GstRate.eighteen.percentage, 18.0);
    });
  });

  group('GstResult', () {
    test('has value equality', () {
      final a =
          GstCalculator.calculate(amount: 100, rate: 18, intraState: true);
      final b = GstSplit.split(totalTax: 18, intraState: true);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(GstSplit.split(totalTax: 18, intraState: false)));
    });
  });

  test('ITU-02: roundToPaise gives CGST + SGST that add up to totalTax', () {
    // Unrounded, 10.25 at 18% is 0.9225 + 0.9225 = 1.845, which prints as
    // 0.92 + 0.92 = 1.84 against a total of 1.85.
    expect(
      GstCalculator.calculate(
          amount: 10.25, rate: 18, intraState: true, roundToPaise: true),
      const GstResult(cgst: 0.92, sgst: 0.92, igst: 0, totalTax: 1.84),
    );
    expect(
      GstCalculator.calculate(
          amount: 10.25, rate: 18, intraState: false, roundToPaise: true),
      const GstResult(cgst: 0, sgst: 0, igst: 1.85, totalTax: 1.85),
    );
    // The default is unchanged.
    expect(
      GstCalculator.calculate(amount: 10.25, rate: 18, intraState: true),
      const GstResult(cgst: 0.9225, sgst: 0.9225, igst: 0, totalTax: 1.845),
    );

    // MRP 10 inclusive of 18%: tax 1.5254... splits as 0.76 + 0.76.
    final tax = GstInclusiveCalculator.extractGST(amount: 10, rate: 18)['tax']!;
    expect(
      GstSplit.split(totalTax: tax, intraState: true, roundToPaise: true),
      const GstResult(cgst: 0.76, sgst: 0.76, igst: 0, totalTax: 1.52),
    );
    expect(
      GstSplit.split(totalTax: tax, intraState: false, roundToPaise: true),
      const GstResult(cgst: 0, sgst: 0, igst: 1.53, totalTax: 1.53),
    );
    // An odd number of paise cannot be halved into whole paise (documented).
    expect(
      GstSplit.split(totalTax: 0.05, intraState: true, roundToPaise: true),
      const GstResult(cgst: 0.03, sgst: 0.03, igst: 0, totalTax: 0.06),
    );

    // No negative zero, for example on a tiny credit note.
    for (final intraState in [true, false]) {
      final r = GstCalculator.calculate(
          amount: -0.01, rate: 5, intraState: intraState, roundToPaise: true);
      final s = GstSplit.split(
          totalTax: -0.0001, intraState: intraState, roundToPaise: true);
      for (final v in [r.cgst, r.sgst, r.igst, r.totalTax, s.cgst, s.igst]) {
        expect(v, 0);
        expect(v.isNegative, isFalse);
      }
    }

    int paise(double v) => (v * 100).round();
    final random = Random(2);
    for (var i = 0; i < 5000; i++) {
      final amount =
          (random.nextBool() ? 1 : -1) * (1 + random.nextInt(10000000)) / 100;
      for (final rate in [3.0, 5.0, 18.0, 40.0]) {
        final exact = GstCalculator.calculate(
            amount: amount, rate: rate, intraState: true);
        final intra = GstCalculator.calculate(
            amount: amount, rate: rate, intraState: true, roundToPaise: true);
        expect(intra.cgst, RoundingHelper.roundTo(exact.cgst));
        expect(intra.sgst, intra.cgst);
        expect(paise(intra.cgst) + paise(intra.sgst), paise(intra.totalTax),
            reason: '$amount @ $rate%');

        final inter = GstCalculator.calculate(
            amount: amount, rate: rate, intraState: false, roundToPaise: true);
        expect(inter.igst, RoundingHelper.roundTo(exact.totalTax));
        expect(inter.totalTax, inter.igst);
      }
    }
  });

  test('ITU-09: GstRate offers the 3% special rate (gold, jewellery)', () {
    expect(GstRate.three.rate, 3);
    expect(GstRate.three.percentage, 3.0);
    expect(GstRate.values.map((r) => r.percentage), contains(3.0));
    // Appended last, so existing indexes are unchanged.
    expect(GstRate.values.last, GstRate.three);
    expect(GstRate.forty.index, 5);
  });
}
