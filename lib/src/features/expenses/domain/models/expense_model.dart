import 'package:expenses_tracker/src/imports/packages_imports.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class Expense extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final String category;
  @HiveField(5)
  final String? note;
  @HiveField(6)
  final bool isIncome;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
    this.isIncome = false,
  });

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? note,
    bool? isIncome,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
      isIncome: isIncome ?? this.isIncome,
    );
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(map['date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(
            (map['dateMillis'] as num?)?.toInt() ?? 0,
          ),
      category: map['category']?.toString() ?? 'Other',
      note: map['note']?.toString(),
      isIncome: map['isIncome'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'dateMillis': date.millisecondsSinceEpoch,
      'category': category,
      'note': note,
      'isIncome': isIncome,
    };
  }

  @override
  List<Object?> get props =>
      [id, title, amount, date, category, note, isIncome];
}
