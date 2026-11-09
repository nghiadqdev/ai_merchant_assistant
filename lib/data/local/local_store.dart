import '../models/daily_expense.dart';
import '../models/daily_sale.dart';
import '../models/product_simulation.dart';
import '../models/system_benchmark.dart';
import '../models/user_business_profile.dart';

/// Storage contract so the UI/providers never depend on Hive directly.
abstract class LocalStore {
  Future<void> saveProfile(UserBusinessProfile profile);
  UserBusinessProfile? getProfile();

  List<SystemBenchmark> getBenchmarks();
  Future<void> saveBenchmarks(List<SystemBenchmark> benchmarks);

  List<ProductSimulation> getProducts();
  Future<void> saveProduct(ProductSimulation product);

  List<DailyExpense> getExpenses();
  Future<void> addExpense(DailyExpense expense);

  List<DailySale> getSales();
  Future<void> addSale(DailySale sale);
}
