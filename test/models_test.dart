import 'package:flutter_test/flutter_test.dart';

import 'package:ai_merchant_assistant/data/models/daily_expense.dart';
import 'package:ai_merchant_assistant/data/models/daily_sale.dart';
import 'package:ai_merchant_assistant/data/models/product_simulation.dart';
import 'package:ai_merchant_assistant/data/models/system_benchmark.dart';
import 'package:ai_merchant_assistant/data/models/user_business_profile.dart';

void main() {
  test('SystemBenchmark map round-trip', () {
    const benchmark = SystemBenchmark(
      id: 'fashion_01',
      categoryName: 'Thời trang',
      defaultPlatformFee: 0.12,
      defaultAdsCost: 0.15,
      dynamicRiskType: 'Tỷ lệ hoàn hàng',
      defaultRiskRate: 0.10,
    );

    final copy = SystemBenchmark.fromMap(benchmark.toMap());

    expect(copy.id, benchmark.id);
    expect(copy.categoryName, benchmark.categoryName);
    expect(copy.defaultPlatformFee, benchmark.defaultPlatformFee);
    expect(copy.defaultAdsCost, benchmark.defaultAdsCost);
    expect(copy.dynamicRiskType, benchmark.dynamicRiskType);
    expect(copy.defaultRiskRate, benchmark.defaultRiskRate);
  });

  test('UserBusinessProfile map round-trip', () {
    const profile = UserBusinessProfile(
      id: 'profile-1',
      userId: 'user-1',
      selectedCategoryId: 'tech_02',
      initialCapital: 50000000,
    );

    final copy = UserBusinessProfile.fromMap(profile.toMap());

    expect(copy.id, profile.id);
    expect(copy.userId, profile.userId);
    expect(copy.selectedCategoryId, profile.selectedCategoryId);
    expect(copy.initialCapital, profile.initialCapital);
  });

  test('ProductSimulation map round-trip keeps packaging fee', () {
    const product = ProductSimulation(
      id: 'product-1',
      name: 'Áo thun',
      cogs: 100000,
      sellingPrice: 250000,
      customAdsRate: 0.15,
      customPlatformFee: 0.12,
      customRiskRate: 0.10,
      packagingFee: 5000,
    );

    final copy = ProductSimulation.fromMap(product.toMap());

    expect(copy.name, product.name);
    expect(copy.cogs, product.cogs);
    expect(copy.sellingPrice, product.sellingPrice);
    expect(copy.customAdsRate, product.customAdsRate);
    expect(copy.customPlatformFee, product.customPlatformFee);
    expect(copy.customRiskRate, product.customRiskRate);
    expect(copy.packagingFee, product.packagingFee);
  });

  test('DailyExpense map round-trip preserves type and date', () {
    final expense = DailyExpense(
      id: 'expense-1',
      date: DateTime(2026, 11, 9),
      type: ExpenseType.returns,
      amount: 450000,
      note: '3 đơn hoàn',
    );

    final copy = DailyExpense.fromMap(expense.toMap());

    expect(copy.id, expense.id);
    expect(copy.date, expense.date);
    expect(copy.type, ExpenseType.returns);
    expect(copy.amount, expense.amount);
    expect(copy.note, expense.note);
  });

  test('DailySale map round-trip', () {
    final sale = DailySale(
      id: 'sale-1',
      date: DateTime(2026, 11, 9),
      revenue: 3450000,
      units: 15,
    );

    final copy = DailySale.fromMap(sale.toMap());

    expect(copy.date, sale.date);
    expect(copy.revenue, sale.revenue);
    expect(copy.units, sale.units);
  });
}
