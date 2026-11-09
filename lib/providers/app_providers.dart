import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../data/local/local_store.dart';
import '../data/models/daily_expense.dart';
import '../data/models/daily_sale.dart';
import '../data/models/system_benchmark.dart';
import '../data/models/user_business_profile.dart';
import '../data/remote/benchmark_remote_data_source.dart';
import '../data/remote/sync_service.dart';
import '../data/repositories/benchmark_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/sale_repository.dart';
import '../features/dashboard/domain/dashboard_data.dart';
import '../features/dashboard/domain/dashboard_repository.dart';

class BootstrapData {
  const BootstrapData({
    required this.profile,
    required this.benchmarks,
  });

  final UserBusinessProfile? profile;
  final List<SystemBenchmark> benchmarks;
}

/// Overridden in main() after Hive has been opened.
final localStoreProvider = Provider<LocalStore>((ref) {
  throw UnimplementedError('localStoreProvider must be overridden in main()');
});

/// Overridden in main() with the synchronous Hive snapshot.
final bootstrapProvider = Provider<BootstrapData>((ref) {
  throw UnimplementedError('bootstrapProvider must be overridden in main()');
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.watch(localStoreProvider));
});

final benchmarkRemoteProvider = Provider<BenchmarkRemoteDataSource>((ref) {
  return BenchmarkRemoteDataSource();
});

final benchmarkRepositoryProvider = Provider<BenchmarkRepository>((ref) {
  return BenchmarkRepository(
    ref.watch(localStoreProvider),
    ref.watch(benchmarkRemoteProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    ref.watch(localStoreProvider),
    ref.watch(syncServiceProvider),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    ref.watch(localStoreProvider),
    ref.watch(syncServiceProvider),
  );
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(
    ref.watch(localStoreProvider),
    ref.watch(syncServiceProvider),
  );
});

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepository(
    ref.watch(localStoreProvider),
    ref.watch(syncServiceProvider),
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(localStoreProvider));
});

final profileProvider =
    NotifierProvider<ProfileNotifier, UserBusinessProfile?>(ProfileNotifier.new);

class ProfileNotifier extends Notifier<UserBusinessProfile?> {
  @override
  UserBusinessProfile? build() => ref.watch(bootstrapProvider).profile;

  Future<void> saveProfile({
    required String categoryId,
    required double initialCapital,
  }) async {
    final existing = state;
    final profile = UserBusinessProfile(
      id: existing?.id ?? const Uuid().v4(),
      userId: existing?.userId ?? AppConstants.localUserId,
      selectedCategoryId: categoryId,
      initialCapital: initialCapital,
    );

    await ref.read(profileRepositoryProvider).save(profile);
    state = profile;
  }
}

final benchmarksProvider = Provider<List<SystemBenchmark>>((ref) {
  return ref.watch(bootstrapProvider).benchmarks;
});

final selectedBenchmarkProvider = Provider<SystemBenchmark?>((ref) {
  final profile = ref.watch(profileProvider);
  if (profile == null) return null;

  for (final benchmark in ref.watch(benchmarksProvider)) {
    if (benchmark.id == profile.selectedCategoryId) return benchmark;
  }
  return null;
});

final expensesProvider =
    NotifierProvider<ExpenseNotifier, List<DailyExpense>>(ExpenseNotifier.new);

class ExpenseNotifier extends Notifier<List<DailyExpense>> {
  @override
  List<DailyExpense> build() => ref.watch(localStoreProvider).getExpenses();

  Future<void> add(DailyExpense expense) async {
    await ref.read(expenseRepositoryProvider).add(expense);
    state = ref.read(localStoreProvider).getExpenses();
  }
}

final salesProvider =
    NotifierProvider<SalesNotifier, List<DailySale>>(SalesNotifier.new);

class SalesNotifier extends Notifier<List<DailySale>> {
  @override
  List<DailySale> build() => ref.watch(localStoreProvider).getSales();

  Future<void> add(DailySale sale) async {
    await ref.read(saleRepositoryProvider).add(sale);
    state = ref.read(localStoreProvider).getSales();
  }
}

final dashboardDataProvider = Provider<DashboardData>((ref) {
  ref.watch(expensesProvider);
  ref.watch(salesProvider);
  return ref.watch(dashboardRepositoryProvider).lastSevenDays();
});
