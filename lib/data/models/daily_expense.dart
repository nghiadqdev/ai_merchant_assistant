enum ExpenseType {
  ads('Tiền Ads', 'ads'),
  shipping('Tiền vận chuyển', 'shipping'),
  returns('Hoàn hàng', 'returns'),
  surcharge('Phụ phí', 'surcharge');

  const ExpenseType(this.label, this.code);

  final String label;
  final String code;

  static ExpenseType fromCode(String? code) {
    return values.firstWhere(
      (type) => type.code == code,
      orElse: () => ExpenseType.surcharge,
    );
  }
}

class DailyExpense {
  const DailyExpense({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.note,
  });

  final String id;
  final DateTime date;
  final ExpenseType type;
  final double amount;
  final String note;

  factory DailyExpense.fromMap(Map<String, dynamic> map) {
    return DailyExpense(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      type: ExpenseType.fromCode(map['type'] as String?),
      amount: (map['amount'] as num).toDouble(),
      note: (map['note'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.code,
      'amount': amount,
      'note': note,
    };
  }

  DailyExpense copyWith({
    String? id,
    DateTime? date,
    ExpenseType? type,
    double? amount,
    String? note,
  }) {
    return DailyExpense(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}
