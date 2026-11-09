/// Extension to the PRD schema so the Executive Dashboard can compare
/// actual revenue with actual expenses over the last 7 days.
class DailySale {
  const DailySale({
    required this.id,
    required this.date,
    required this.revenue,
    required this.units,
  });

  final String id;
  final DateTime date;
  final double revenue;
  final int units;

  factory DailySale.fromMap(Map<String, dynamic> map) {
    return DailySale(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      revenue: (map['revenue'] as num).toDouble(),
      units: (map['units'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'revenue': revenue,
      'units': units,
    };
  }
}
