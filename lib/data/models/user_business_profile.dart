class UserBusinessProfile {
  const UserBusinessProfile({
    required this.id,
    required this.userId,
    required this.selectedCategoryId,
    required this.initialCapital,
  });

  final String id;
  final String userId;
  final String selectedCategoryId;
  final double initialCapital;

  factory UserBusinessProfile.fromMap(Map<String, dynamic> map) {
    return UserBusinessProfile(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      selectedCategoryId: map['selected_category_id'] as String,
      initialCapital: (map['initial_capital'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'selected_category_id': selectedCategoryId,
      'initial_capital': initialCapital,
    };
  }

  UserBusinessProfile copyWith({
    String? id,
    String? userId,
    String? selectedCategoryId,
    double? initialCapital,
  }) {
    return UserBusinessProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      initialCapital: initialCapital ?? this.initialCapital,
    );
  }
}
