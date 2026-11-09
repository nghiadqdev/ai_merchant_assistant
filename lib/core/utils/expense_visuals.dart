import 'package:flutter/material.dart';

import '../../data/models/daily_expense.dart';

class ExpenseVisuals {
  ExpenseVisuals._();

  static IconData icon(ExpenseType type) {
    switch (type) {
      case ExpenseType.ads:
        return Icons.campaign_rounded;
      case ExpenseType.shipping:
        return Icons.local_shipping_rounded;
      case ExpenseType.returns:
        return Icons.assignment_return_rounded;
      case ExpenseType.surcharge:
        return Icons.receipt_long_rounded;
    }
  }

  static Color color(ExpenseType type) {
    switch (type) {
      case ExpenseType.ads:
        return const Color(0xFF2563EB);
      case ExpenseType.shipping:
        return const Color(0xFF0F766E);
      case ExpenseType.returns:
        return const Color(0xFFDC2626);
      case ExpenseType.surcharge:
        return const Color(0xFFD97706);
    }
  }
}
