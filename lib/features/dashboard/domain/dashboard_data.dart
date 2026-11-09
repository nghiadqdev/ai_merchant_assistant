class DailyFinancePoint {
  const DailyFinancePoint({
    required this.date,
    required this.revenue,
    required this.expense,
  });

  final DateTime date;
  final double revenue;
  final double expense;

  double get profit => revenue - expense;
}

class DashboardData {
  const DashboardData({
    required this.points,
    required this.totalRevenue,
    required this.totalExpense,
  });

  final List<DailyFinancePoint> points;
  final double totalRevenue;
  final double totalExpense;

  double get totalProfit => totalRevenue - totalExpense;

  double get maxValue {
    var maxValue = 1.0;
    for (final point in points) {
      if (point.revenue > maxValue) maxValue = point.revenue;
      if (point.expense > maxValue) maxValue = point.expense;
    }
    return maxValue;
  }

  bool get isEmpty => points.every((point) => point.revenue == 0 && point.expense == 0);
}
