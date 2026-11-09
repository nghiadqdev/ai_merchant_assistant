import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/daily_expense.dart';
import '../models/daily_sale.dart';
import '../models/product_simulation.dart';
import '../models/system_benchmark.dart';
import '../models/user_business_profile.dart';
import 'local_store.dart';
import 'seed_data.dart';

/// Hive CE implementation.
///
/// Hive CE was chosen over Isar 3.x: Isar's codegen/analyzer stack is no longer
/// maintained for Dart 3.13, while Hive CE is pure Dart, has no native build
/// step, and gives the same synchronous local reads required by the PRD.
class HiveLocalStore implements LocalStore {
  HiveLocalStore._({
    required this._profileBox,
    required this._benchmarkBox,
    required this._productBox,
    required this._expenseBox,
    required this._saleBox,
  });

  final Box<dynamic> _profileBox;
  final Box<dynamic> _benchmarkBox;
  final Box<dynamic> _productBox;
  final Box<dynamic> _expenseBox;
  final Box<dynamic> _saleBox;

  static Future<HiveLocalStore> open() async {
    await Hive.initFlutter();

    final store = HiveLocalStore._(
      profileBox: await Hive.openBox<dynamic>('user_business_profile'),
      benchmarkBox: await Hive.openBox<dynamic>('system_benchmarks'),
      productBox: await Hive.openBox<dynamic>('products_simulations'),
      expenseBox: await Hive.openBox<dynamic>('daily_expenses'),
      saleBox: await Hive.openBox<dynamic>('daily_sales'),
    );

    await store._seed();
    return store;
  }

  Future<void> _seed() async {
    if (_benchmarkBox.isEmpty) {
      await saveBenchmarks(SeedData.benchmarks);
    }

    if (kDebugMode && _expenseBox.isEmpty && _saleBox.isEmpty) {
      final now = DateTime.now();
      for (final expense in SeedData.demoExpenses(now)) {
        await addExpense(expense);
      }
      for (final sale in SeedData.demoSales(now)) {
        await addSale(sale);
      }
    }
  }

  @override
  Future<void> saveProfile(UserBusinessProfile profile) async {
    await _profileBox.put('current', profile.toMap());
  }

  @override
  UserBusinessProfile? getProfile() {
    final raw = _profileBox.get('current');
    if (raw is! Map) return null;
    return UserBusinessProfile.fromMap(Map<String, dynamic>.from(raw));
  }

  @override
  List<SystemBenchmark> getBenchmarks() {
    final benchmarks = _benchmarkBox.values
        .whereType<Map>()
        .map((row) => SystemBenchmark.fromMap(Map<String, dynamic>.from(row)))
        .toList();

    // Hive does not guarantee insertion order; keep the curated onboarding order.
    final order = <String, int>{
      for (var i = 0; i < SeedData.benchmarks.length; i++)
        SeedData.benchmarks[i].id: i,
    };
    benchmarks.sort((a, b) {
      final aOrder = order[a.id] ?? 1000;
      final bOrder = order[b.id] ?? 1000;
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);
      return a.categoryName.compareTo(b.categoryName);
    });

    return benchmarks;
  }

  @override
  Future<void> saveBenchmarks(List<SystemBenchmark> benchmarks) async {
    await _benchmarkBox.clear();
    for (final benchmark in benchmarks) {
      await _benchmarkBox.put(benchmark.id, benchmark.toMap());
    }
  }

  @override
  List<ProductSimulation> getProducts() {
    return _productBox.values
        .whereType<Map>()
        .map((row) => ProductSimulation.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  @override
  Future<void> saveProduct(ProductSimulation product) async {
    await _productBox.put(product.id, product.toMap());
  }

  @override
  List<DailyExpense> getExpenses() {
    final expenses = _expenseBox.values
        .whereType<Map>()
        .map((row) => DailyExpense.fromMap(Map<String, dynamic>.from(row)))
        .toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<void> addExpense(DailyExpense expense) async {
    await _expenseBox.put(expense.id, expense.toMap());
  }

  @override
  List<DailySale> getSales() {
    return _saleBox.values
        .whereType<Map>()
        .map((row) => DailySale.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  @override
  Future<void> addSale(DailySale sale) async {
    await _saleBox.put(sale.id, sale.toMap());
  }
}
