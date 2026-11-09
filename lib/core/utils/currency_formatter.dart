import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final NumberFormat _decimal = NumberFormat.decimalPattern('vi_VN');

  static String vnd(num value) => _currency.format(value);

  static String number(num value) => _decimal.format(value);

  /// Compact labels for chart axes: 850 k, 1,2 tr, 2,5 tỷ.
  static String compact(num value) {
    final absolute = value.abs();
    if (absolute >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1).replaceAll('.', ',')} tỷ';
    }
    if (absolute >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1).replaceAll('.', ',')} tr';
    }
    if (absolute >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} k';
    }
    return value.toStringAsFixed(0);
  }

  static String percent(double rate, {int digits = 0}) =>
      '${(rate * 100).toStringAsFixed(digits)}%';

  static double parseVnd(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return double.tryParse(digits) ?? 0;
  }
}

/// Formats digits as the user types: 50000000 -> 50.000.000.
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }

    final safeDigits = digits.length > 15 ? digits.substring(0, 15) : digits;
    final formatted = NumberFormat.decimalPattern('vi_VN').format(
      int.parse(safeDigits),
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
