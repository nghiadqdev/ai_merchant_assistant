import 'package:flutter_test/flutter_test.dart';

import 'package:ai_merchant_assistant/features/simulator/domain/financial_calculator.dart';

void main() {
  group('FinancialCalculator (PRD formula)', () {
    test('computes cost, gross profit, margin and break-even', () {
      final result = FinancialCalculator.calculate(
        cogs: 100000,
        sellingPrice: 250000,
        adsRate: 0.15,
        platformFeeRate: 0.12,
        riskRate: 0.10,
        packagingFee: 5000,
        initialCapital: 50000000,
      );

      expect(result.platformCost, closeTo(30000, 0.001));
      expect(result.adsCost, closeTo(37500, 0.001));
      expect(result.riskCost, closeTo(25000, 0.001));
      expect(result.totalUnitCost, closeTo(197500, 0.001));
      expect(result.grossProfit, closeTo(52500, 0.001));
      expect(result.marginPercent, closeTo(21.0, 0.001));
      expect(result.breakEvenUnits, 953); // ceil(50,000,000 / 52,500)
      expect(result.isLoss, isFalse);
      expect(result.canBreakEven, isTrue);
    });

    test('returns null break-even when every unit loses money', () {
      final result = FinancialCalculator.calculate(
        cogs: 200000,
        sellingPrice: 200000,
        adsRate: 0.20,
        platformFeeRate: 0.10,
        riskRate: 0.10,
        packagingFee: 5000,
        initialCapital: 10000000,
      );

      expect(result.totalUnitCost, closeTo(285000, 0.001));
      expect(result.grossProfit, closeTo(-85000, 0.001));
      expect(result.marginPercent, closeTo(-42.5, 0.001));
      expect(result.breakEvenUnits, isNull);
      expect(result.isLoss, isTrue);
    });

    test('avoids NaN at zero selling price', () {
      final result = FinancialCalculator.calculate(
        cogs: 100000,
        sellingPrice: 0,
        adsRate: 0,
        platformFeeRate: 0,
        riskRate: 0,
        packagingFee: 0,
        initialCapital: 1000000,
      );

      expect(result.marginPercent, 0);
      expect(result.breakEvenUnits, isNull);
      expect(result.isLoss, isTrue);
    });

    test('rounds break-even units up', () {
      final result = FinancialCalculator.calculate(
        cogs: 100000,
        sellingPrice: 200000,
        adsRate: 0,
        platformFeeRate: 0,
        riskRate: 0,
        packagingFee: 0,
        initialCapital: 1000000,
      );

      expect(result.grossProfit, closeTo(100000, 0.001));
      expect(result.breakEvenUnits, 10);
    });

    test('clamps invalid percentages', () {
      final result = FinancialCalculator.calculate(
        cogs: 100000,
        sellingPrice: 200000,
        adsRate: 2.0,
        platformFeeRate: -1,
        riskRate: 0.5,
        packagingFee: 0,
        initialCapital: 0,
      );

      expect(result.adsCost, closeTo(200000, 0.001)); // ads clamped to 100%
      expect(result.platformCost, 0); // platform clamped to 0%
      expect(result.riskCost, closeTo(100000, 0.001));
    });
  });
}
