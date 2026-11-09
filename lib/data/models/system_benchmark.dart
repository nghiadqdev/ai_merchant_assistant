/// Benchmark pulled from Supabase `system_benchmarks`.
class SystemBenchmark {
  const SystemBenchmark({
    required this.id,
    required this.categoryName,
    required this.defaultPlatformFee,
    required this.defaultAdsCost,
    required this.dynamicRiskType,
    required this.defaultRiskRate,
  });

  final String id;
  final String categoryName;
  final double defaultPlatformFee;
  final double defaultAdsCost;
  final String dynamicRiskType;
  final double defaultRiskRate;

  factory SystemBenchmark.fromMap(Map<String, dynamic> map) {
    return SystemBenchmark(
      id: map['id'] as String,
      categoryName: map['category_name'] as String,
      defaultPlatformFee: (map['default_platform_fee'] as num).toDouble(),
      defaultAdsCost: (map['default_ads_cost'] as num).toDouble(),
      dynamicRiskType: map['dynamic_risk_type'] as String,
      defaultRiskRate: (map['default_risk_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_name': categoryName,
      'default_platform_fee': defaultPlatformFee,
      'default_ads_cost': defaultAdsCost,
      'dynamic_risk_type': dynamicRiskType,
      'default_risk_rate': defaultRiskRate,
    };
  }

  SystemBenchmark copyWith({
    String? id,
    String? categoryName,
    double? defaultPlatformFee,
    double? defaultAdsCost,
    String? dynamicRiskType,
    double? defaultRiskRate,
  }) {
    return SystemBenchmark(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      defaultPlatformFee: defaultPlatformFee ?? this.defaultPlatformFee,
      defaultAdsCost: defaultAdsCost ?? this.defaultAdsCost,
      dynamicRiskType: dynamicRiskType ?? this.dynamicRiskType,
      defaultRiskRate: defaultRiskRate ?? this.defaultRiskRate,
    );
  }
}
