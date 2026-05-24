import 'dart:convert';

ExpenseModel expenseModelFromJson(String str) =>
    ExpenseModel.fromJson(json.decode(str));

String expenseModelToJson(ExpenseModel data) => json.encode(data.toJson());

class ExpenseModel {
  final String id;
  final String name;
  final double amount;
  final String category;
  final String? merchant;
  final String? note;
  final String? recurrence;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.merchant,
    this.note,
    this.recurrence,
    required this.date,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'],
        name: json['name'],
        amount: (json['amount'] as num).toDouble(),
        category: json['category'],
        merchant: json['merchant'],
        note: json['note'],
        recurrence: json['recurrence'],
        date: DateTime.parse(json['date']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'category': category,
        'merchant': merchant,
        'note': note,
        'recurrence': recurrence,
        'date': date.toIso8601String(),
      };

  ExpenseModel copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
    String? merchant,
    String? note,
    String? recurrence,
    DateTime? date,
  }) =>
      ExpenseModel(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        merchant: merchant ?? this.merchant,
        note: note ?? this.note,
        recurrence: recurrence ?? this.recurrence,
        date: date ?? this.date,
      );
}
