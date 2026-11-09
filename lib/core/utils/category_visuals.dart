import 'package:flutter/material.dart';

import '../../data/models/system_benchmark.dart';

class CategoryVisual {
  const CategoryVisual(this.icon, this.color);

  final IconData icon;
  final Color color;
}

class CategoryVisuals {
  CategoryVisuals._();

  static CategoryVisual of(SystemBenchmark benchmark) {
    switch (benchmark.id) {
      case 'fashion_01':
        return const CategoryVisual(Icons.checkroom_rounded, Color(0xFFDB2777));
      case 'tech_02':
        return const CategoryVisual(Icons.devices_rounded, Color(0xFF2563EB));
      case 'cosmetics_03':
        return const CategoryVisual(Icons.spa_rounded, Color(0xFF9333EA));
      case 'food_04':
        return const CategoryVisual(Icons.restaurant_rounded, Color(0xFFEA580C));
      case 'home_05':
        return const CategoryVisual(Icons.chair_rounded, Color(0xFF0F766E));
      case 'accessories_06':
        return const CategoryVisual(Icons.watch_rounded, Color(0xFFCA8A04));
      default:
        return const CategoryVisual(Icons.storefront_rounded, Color(0xFF0F766E));
    }
  }
}
