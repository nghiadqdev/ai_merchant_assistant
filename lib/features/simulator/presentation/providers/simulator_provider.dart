import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/local/seed_data.dart';
import '../../../../data/models/product_simulation.dart';
import '../../../../providers/app_providers.dart';
import '../../domain/financial_calculator.dart';
import '../../domain/simulation_state.dart';

final simulatorProvider =
    NotifierProvider<SimulatorNotifier, SimulationState>(SimulatorNotifier.new);

class SimulatorNotifier extends Notifier<SimulationState> {
  @override
  SimulationState build() {
    final benchmark =
        ref.watch(selectedBenchmarkProvider) ?? SeedData.benchmarks.first;
    final profile = ref.watch(profileProvider);

    return SimulationState.initial(
      benchmark: benchmark,
      initialCapital: profile?.initialCapital ?? 0,
    );
  }

  void setName(String value) {
    state = state.copyWith(productName: value);
  }

  void setCogs(double value) {
    final cogs = value < 0 ? 0.0 : value;
    final minPrice = cogs;
    final maxPrice = cogs > 0 ? cogs * 5 : 0.0;
    final sellingPrice = maxPrice <= 0
        ? 0.0
        : state.sellingPrice.clamp(minPrice, maxPrice).toDouble();

    state = state.copyWith(cogs: cogs, sellingPrice: sellingPrice);
  }

  void setSellingPrice(double value) {
    if (!state.canPrice) return;
    state = state.copyWith(
      sellingPrice: value
          .clamp(state.minSellingPrice, state.maxSellingPrice)
          .toDouble(),
    );
  }

  void setAdsRate(double value) {
    state = state.copyWith(
      adsRate: value.clamp(0.0, AppConstants.maxRate).toDouble(),
    );
  }

  void setPlatformFee(double value) {
    state = state.copyWith(
      platformFeeRate: value.clamp(0.0, AppConstants.maxRate).toDouble(),
    );
  }

  void setRiskRate(double value) {
    state = state.copyWith(
      riskRate: value.clamp(0.0, AppConstants.maxRate).toDouble(),
    );
  }

  void setPackagingFee(double value) {
    state = state.copyWith(
      packagingFee: value < 0 ? 0.0 : value,
    );
  }

  Future<bool> save() async {
    final name = state.productName.trim();
    if (name.isEmpty) return false;

    final product = ProductSimulation(
      id: const Uuid().v4(),
      name: name,
      cogs: state.cogs,
      sellingPrice: state.sellingPrice,
      customAdsRate: state.adsRate,
      customPlatformFee: state.platformFeeRate,
      customRiskRate: state.riskRate,
      packagingFee: state.packagingFee,
    );

    await ref.read(productRepositoryProvider).save(product);
    return true;
  }
}

final simulatorResultProvider = Provider<FinancialResult>((ref) {
  final state = ref.watch(simulatorProvider);

  return FinancialCalculator.calculate(
    cogs: state.cogs,
    sellingPrice: state.sellingPrice,
    adsRate: state.adsRate,
    platformFeeRate: state.platformFeeRate,
    riskRate: state.riskRate,
    packagingFee: state.packagingFee,
    initialCapital: state.initialCapital,
  );
});
