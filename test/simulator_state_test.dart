import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_merchant_assistant/data/local/seed_data.dart';
import 'package:ai_merchant_assistant/data/models/user_business_profile.dart';
import 'package:ai_merchant_assistant/features/simulator/domain/simulation_state.dart';
import 'package:ai_merchant_assistant/features/simulator/presentation/providers/simulator_provider.dart';
import 'package:ai_merchant_assistant/providers/app_providers.dart';

void main() {
  test('SimulationState.initial follows benchmark defaults', () {
    final state = SimulationState.initial(
      benchmark: SeedData.benchmarks.first,
      initialCapital: 50000000,
    );

    expect(state.cogs, 100000);
    expect(state.sellingPrice, 250000);
    expect(state.minSellingPrice, 100000);
    expect(state.maxSellingPrice, 500000);
    expect(state.adsRate, SeedData.benchmarks.first.defaultAdsCost);
    expect(state.platformFeeRate, SeedData.benchmarks.first.defaultPlatformFee);
    expect(state.riskRate, SeedData.benchmarks.first.defaultRiskRate);
    expect(state.riskLabel, SeedData.benchmarks.first.dynamicRiskType);
  });

  test('simulator notifier clamps sliders and cogs', () {
    final container = ProviderContainer(
      overrides: [
        bootstrapProvider.overrideWithValue(
          const BootstrapData(
            profile: UserBusinessProfile(
              id: 'profile-1',
              userId: 'local-user',
              selectedCategoryId: 'fashion_01',
              initialCapital: 50000000,
            ),
            benchmarks: SeedData.benchmarks,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(simulatorProvider.notifier);
    expect(container.read(simulatorProvider).sellingPrice, 250000);

    notifier.setCogs(200000);
    expect(container.read(simulatorProvider).sellingPrice, 250000);

    notifier.setCogs(0);
    expect(container.read(simulatorProvider).sellingPrice, 0);
    expect(container.read(simulatorProvider).canPrice, isFalse);

    notifier.setCogs(100000);
    notifier.setSellingPrice(9999999);
    expect(container.read(simulatorProvider).sellingPrice, 500000);

    notifier.setAdsRate(0.5);
    notifier.setPlatformFee(0.5);
    notifier.setRiskRate(0.5);
    expect(container.read(simulatorProvider).adsRate, 0.30);
    expect(container.read(simulatorProvider).platformFeeRate, 0.30);
    expect(container.read(simulatorProvider).riskRate, 0.30);
  });
}
