import 'package:expenses_tracker/src/imports/packages_imports.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 1)
class Budget extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String category;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final DateTime month;

  const Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
  });

  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? month,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      month: month ?? this.month,
    );
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Other',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      month: DateTime.tryParse(map['month']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(
            (map['monthMillis'] as num?)?.toInt() ?? 0,
          ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'month': month.toIso8601String(),
      'monthMillis': month.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [id, category, amount, month];
}
