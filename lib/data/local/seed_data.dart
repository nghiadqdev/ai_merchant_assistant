import '../models/daily_expense.dart';
import '../models/daily_sale.dart';
import '../models/system_benchmark.dart';

class SeedData {
  SeedData._();

  static const List<SystemBenchmark> benchmarks = [
    SystemBenchmark(
      id: 'fashion_01',
      categoryName: 'Thời trang',
      defaultPlatformFee: 0.12,
      defaultAdsCost: 0.15,
      dynamicRiskType: 'Tỷ lệ hoàn hàng',
      defaultRiskRate: 0.10,
    ),
    SystemBenchmark(
      id: 'tech_02',
      categoryName: 'Điện tử',
      defaultPlatformFee: 0.08,
      defaultAdsCost: 0.10,
      dynamicRiskType: 'Phí bảo hành',
      defaultRiskRate: 0.05,
    ),
    SystemBenchmark(
      id: 'cosmetics_03',
      categoryName: 'Mỹ phẩm',
      defaultPlatformFee: 0.15,
      defaultAdsCost: 0.20,
      dynamicRiskType: 'Hàng hư hỏng',
      defaultRiskRate: 0.08,
    ),
    SystemBenchmark(
      id: 'food_04',
      categoryName: 'Thực phẩm',
      defaultPlatformFee: 0.10,
      defaultAdsCost: 0.12,
      dynamicRiskType: 'Hao hụt',
      defaultRiskRate: 0.06,
    ),
    SystemBenchmark(
      id: 'home_05',
      categoryName: 'Gia dụng',
      defaultPlatformFee: 0.11,
      defaultAdsCost: 0.14,
      dynamicRiskType: 'Bảo hành',
      defaultRiskRate: 0.04,
    ),
    SystemBenchmark(
      id: 'accessories_06',
      categoryName: 'Phụ kiện',
      defaultPlatformFee: 0.13,
      defaultAdsCost: 0.16,
      dynamicRiskType: 'Đổi trả',
      defaultRiskRate: 0.09,
    ),
  ];

  /// Debug-only demo rows so the dashboard chart is useful on first launch.
  /// Release builds start with an empty chart until real data exists.
  static List<DailyExpense> demoExpenses(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    const amounts = [620000.0, 910000.0, 450000.0, 1250000.0, 780000.0, 640000.0, 1100000.0];
    const types = [
      ExpenseType.ads,
      ExpenseType.shipping,
      ExpenseType.returns,
      ExpenseType.ads,
      ExpenseType.shipping,
      ExpenseType.surcharge,
      ExpenseType.ads,
    ];

    return List.generate(7, (index) {
      return DailyExpense(
        id: 'demo-expense-$index',
        date: today.subtract(Duration(days: 6 - index)),
        type: types[index],
        amount: amounts[index],
        note: 'Dữ liệu mẫu (debug)',
      );
    });
  }

  static List<DailySale> demoSales(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    const revenues = [1850000.0, 2400000.0, 1200000.0, 3100000.0, 2750000.0, 2100000.0, 3450000.0];
    const units = [8, 10, 5, 14, 12, 9, 15];

    return List.generate(7, (index) {
      return DailySale(
        id: 'demo-sale-$index',
        date: today.subtract(Duration(days: 6 - index)),
        revenue: revenues[index],
        units: units[index],
      );
    });
  }
}
