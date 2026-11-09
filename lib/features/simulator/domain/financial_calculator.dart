import 'dart:math' as math;

/// Immutable result of the per-unit financial model.
///
/// All monetary values are VND per unit.
class FinancialResult {
  const FinancialResult({
    required this.cogs,
    required this.sellingPrice,
    required this.platformCost,
    required this.adsCost,
    required this.riskCost,
    required this.packagingFee,
    required this.totalUnitCost,
    required this.grossProfit,
    required this.marginPercent,
    required this.breakEvenUnits,
    required this.initialCapital,
  });

  final double cogs;
  final double sellingPrice;
  final double platformCost;
  final double adsCost;
  final double riskCost;
  final double packagingFee;
  final double totalUnitCost;
  final double grossProfit;
  final double marginPercent;

  /// null means "cannot break even" because gross profit is <= 0.
  final int? breakEvenUnits;
  final double initialCapital;

  bool get hasValidPrice => sellingPrice > 0;
  bool get isLoss => grossProfit < 0;
  bool get isBreakEven => grossProfit == 0;
  bool get canBreakEven => breakEvenUnits != null;
}

class FinancialCalculator {
  FinancialCalculator._();

  /// PRD formula, calculated per unit:
  ///
  /// Cost = COGS
  ///      + Selling_Price * platformFee
  ///      + Selling_Price * adsRate
  ///      + Selling_Price * riskRate
  ///      + packagingFee
  ///
  /// Gross_Profit = Selling_Price - Cost
  /// Margin       = Gross_Profit / Selling_Price * 100
  /// Break_Even   = ceil(initialCapital / Gross_Profit)
  static FinancialResult calculate({
    required double cogs,
    required double sellingPrice,
    required double adsRate,
    required double platformFeeRate,
    required double riskRate,
    required double packagingFee,
    required double initialCapital,
  }) {
    final safeSelling = math.max(0.0, sellingPrice);
    final safeCogs = math.max(0.0, cogs);
    final safePackaging = math.max(0.0, packagingFee);
    final safeAds = adsRate.clamp(0.0, 1.0);
    final safePlatform = platformFeeRate.clamp(0.0, 1.0);
    final safeRisk = riskRate.clamp(0.0, 1.0);

    // Variable costs are percentages of the selling price.
    final platformCost = safeSelling * safePlatform;
    final adsCost = safeSelling * safeAds;
    final riskCost = safeSelling * safeRisk;

    // Total cost of one delivered order.
    final totalUnitCost =
        safeCogs + platformCost + adsCost + riskCost + safePackaging;

    // Gross profit per unit.
    final grossProfit = safeSelling - totalUnitCost;

    // Margin is undefined at zero price; show 0 instead of NaN.
    final marginPercent =
        safeSelling > 0 ? (grossProfit / safeSelling) * 100 : 0.0;

    // Break-even quantity: how many units recover the initial capital.
    // If each unit loses money, no finite quantity can break even.
    final breakEvenUnits = grossProfit > 0
        ? (math.max(0.0, initialCapital) / grossProfit).ceil()
        : null;

    return FinancialResult(
      cogs: safeCogs,
      sellingPrice: safeSelling,
      platformCost: platformCost,
      adsCost: adsCost,
      riskCost: riskCost,
      packagingFee: safePackaging,
      totalUnitCost: totalUnitCost,
      grossProfit: grossProfit,
      marginPercent: marginPercent,
      breakEvenUnits: breakEvenUnits,
      initialCapital: initialCapital,
    );
  }
}
