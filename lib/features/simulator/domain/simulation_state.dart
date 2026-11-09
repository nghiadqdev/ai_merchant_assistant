import '../../../core/constants/app_constants.dart';
import '../../../data/models/system_benchmark.dart';

class SimulationState {
  const SimulationState({
    required this.productName,
    required this.cogs,
    required this.sellingPrice,
    required this.adsRate,
    required this.platformFeeRate,
    required this.riskRate,
    required this.packagingFee,
    required this.benchmarkId,
    required this.riskLabel,
    required this.initialCapital,
  });

  final String productName;
  final double cogs;
  final double sellingPrice;
  final double adsRate;
  final double platformFeeRate;
  final double riskRate;
  final double packagingFee;
  final String benchmarkId;
  final String riskLabel;
  final double initialCapital;

  factory SimulationState.initial({
    required SystemBenchmark benchmark,
    required double initialCapital,
  }) {
    const cogs = AppConstants.defaultCogs;
    final minPrice = cogs;
    final maxPrice = cogs * 5;
    final sellingPrice = AppConstants.defaultSellingPrice
        .clamp(minPrice, maxPrice)
        .toDouble();

    return SimulationState(
      productName: 'Sản phẩm mẫu',
      cogs: cogs,
      sellingPrice: sellingPrice,
      adsRate: benchmark.defaultAdsCost,
      platformFeeRate: benchmark.defaultPlatformFee,
      riskRate: benchmark.defaultRiskRate,
      packagingFee: AppConstants.defaultPackagingFee,
      benchmarkId: benchmark.id,
      riskLabel: benchmark.dynamicRiskType,
      initialCapital: initialCapital,
    );
  }

  double get minSellingPrice => cogs;

  double get maxSellingPrice => cogs > 0 ? cogs * 5 : 1;

  bool get canPrice => cogs > 0;

  SimulationState copyWith({
    String? productName,
    double? cogs,
    double? sellingPrice,
    double? adsRate,
    double? platformFeeRate,
    double? riskRate,
    double? packagingFee,
    String? benchmarkId,
    String? riskLabel,
    double? initialCapital,
  }) {
    return SimulationState(
      productName: productName ?? this.productName,
      cogs: cogs ?? this.cogs,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      adsRate: adsRate ?? this.adsRate,
      platformFeeRate: platformFeeRate ?? this.platformFeeRate,
      riskRate: riskRate ?? this.riskRate,
      packagingFee: packagingFee ?? this.packagingFee,
      benchmarkId: benchmarkId ?? this.benchmarkId,
      riskLabel: riskLabel ?? this.riskLabel,
      initialCapital: initialCapital ?? this.initialCapital,
    );
  }
}
