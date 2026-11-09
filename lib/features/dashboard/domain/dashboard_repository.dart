import '../../../core/constants/app_constants.dart';
import '../../../data/local/local_store.dart';
import 'dashboard_data.dart';

class DashboardRepository {
  DashboardRepository(this._localStore);

  final LocalStore _localStore;

  DashboardData lastSevenDays([DateTime? now]) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final start = today.subtract(
      const Duration(days: AppConstants.dashboardDays - 1),
    );

    final revenueByDay = <String, double>{};
    final expenseByDay = <String, double>{};

    for (final sale in _localStore.getSales()) {
      final key = _dayKey(sale.date);
      revenueByDay[key] = (revenueByDay[key] ?? 0) + sale.revenue;
    }

    for (final expense in _localStore.getExpenses()) {
      final key = _dayKey(expense.date);
      expenseByDay[key] = (expenseByDay[key] ?? 0) + expense.amount;
    }

    var totalRevenue = 0.0;
    var totalExpense = 0.0;
    final points = <DailyFinancePoint>[];

    for (var i = 0; i < AppConstants.dashboardDays; i++) {
      final date = start.add(Duration(days: i));
      final key = _dayKey(date);
      final revenue = revenueByDay[key] ?? 0;
      final expense = expenseByDay[key] ?? 0;

      totalRevenue += revenue;
      totalExpense += expense;

      points.add(
        DailyFinancePoint(date: date, revenue: revenue, expense: expense),
      );
    }

    return DashboardData(
      points: points,
      totalRevenue: totalRevenue,
      totalExpense: totalExpense,
    );
  }

  String _dayKey(DateTime value) =>
      '${value.year}-${value.month}-${value.day}';
}
