class ProductSimulation {
  const ProductSimulation({
    required this.id,
    required this.name,
    required this.cogs,
    required this.sellingPrice,
    required this.customAdsRate,
    required this.customPlatformFee,
    required this.customRiskRate,
    this.packagingFee = 0,
  });

  final String id;
  final String name;
  final double cogs;
  final double sellingPrice;
  final double customAdsRate;
  final double customPlatformFee;
  final double customRiskRate;

  /// Extension to the PRD schema: the formula includes a fixed packaging fee.
  final double packagingFee;

  factory ProductSimulation.fromMap(Map<String, dynamic> map) {
    return ProductSimulation(
      id: map['id'] as String,
      name: map['name'] as String,
      cogs: (map['cogs'] as num).toDouble(),
      sellingPrice: (map['selling_price'] as num).toDouble(),
      customAdsRate: (map['custom_ads_rate'] as num).toDouble(),
      customPlatformFee: (map['custom_platform_fee'] as num).toDouble(),
      customRiskRate: (map['custom_risk_rate'] as num).toDouble(),
      packagingFee: (map['packaging_fee'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cogs': cogs,
      'selling_price': sellingPrice,
      'custom_ads_rate': customAdsRate,
      'custom_platform_fee': customPlatformFee,
      'custom_risk_rate': customRiskRate,
      'packaging_fee': packagingFee,
    };
  }

  ProductSimulation copyWith({
    String? id,
    String? name,
    double? cogs,
    double? sellingPrice,
    double? customAdsRate,
    double? customPlatformFee,
    double? customRiskRate,
    double? packagingFee,
  }) {
    return ProductSimulation(
      id: id ?? this.id,
      name: name ?? this.name,
      cogs: cogs ?? this.cogs,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      customAdsRate: customAdsRate ?? this.customAdsRate,
      customPlatformFee: customPlatformFee ?? this.customPlatformFee,
      customRiskRate: customRiskRate ?? this.customRiskRate,
      packagingFee: packagingFee ?? this.packagingFee,
    );
  }
}
