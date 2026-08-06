import 'dart:convert';
import 'expense_model.dart';

ScannedItemModel scannedItemModelFromJson(String str) =>
    ScannedItemModel.fromJson(json.decode(str));

String scannedItemModelToJson(ScannedItemModel data) =>
    json.encode(data.toJson());

class ScannedItemModel {
  final String id;
  final String name;
  final String category;
  final double amount;
  final int quantity;
  final double unitPrice;
  // Backend identifiers. Null for a freshly-scanned receipt that hasn't been
  // saved yet — such items can't be sent to PATCH /expenses/{id} → items.
  final String? serverId;
  final String? categoryId;

  ScannedItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.quantity,
    required this.unitPrice,
    this.serverId,
    this.categoryId,
  });

  factory ScannedItemModel.fromJson(Map<String, dynamic> json) =>
      ScannedItemModel(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        amount: (json['amount'] as num).toDouble(),
        quantity: json['quantity'],
        unitPrice: (json['unit_price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'amount': amount,
        'quantity': quantity,
        'unit_price': unitPrice,
      };

  ScannedItemModel copyWith({
    String? id,
    String? name,
    String? category,
    double? amount,
    int? quantity,
    double? unitPrice,
    String? serverId,
    String? categoryId,
  }) =>
      ScannedItemModel(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        serverId: serverId ?? this.serverId,
        categoryId: categoryId ?? this.categoryId,
      );
}

class ScannedReceiptModel {
  final String merchantName;
  final double totalAmount;
  final String? imagePath;
  // Remote receipt image, present on expenses loaded from the backend.
  final String? receiptUrl;
  final List<ScannedItemModel> items;
  // Set when the receipt was already saved to the backend (backend scan path).
  // Used to PATCH the expense amount when the user edits item quantities/prices.
  final String? expenseId;
  // The backend expense this receipt was built from. Present only when opened
  // from an existing saved expense — used to drive the parent edit sheet.
  final ExpenseModel? sourceExpense;

  ScannedReceiptModel({
    required this.merchantName,
    required this.totalAmount,
    this.imagePath,
    this.receiptUrl,
    required this.items,
    this.expenseId,
    this.sourceExpense,
  });

  factory ScannedReceiptModel.fromExpenseModel(
    ExpenseModel expense, {
    String? imagePath,
  }) {
    final mappedItems = expense.items.map((item) {
      final total = item.totalPrice ?? (item.unitPrice * item.quantity.toDouble());
      return ScannedItemModel(
        id: item.id ?? '${item.name}_${item.unitPrice}',
        name: item.name,
        category: 'Other',
        amount: total,
        quantity: item.quantity.toInt(),
        unitPrice: item.unitPrice,
        serverId: item.id,
        categoryId: item.categoryId,
      );
    }).toList();

    return ScannedReceiptModel(
      merchantName: expense.description ?? 'Receipt',
      totalAmount: expense.amount,
      imagePath: imagePath,
      receiptUrl: expense.receiptUrl,
      items: mappedItems,
      expenseId: expense.id,
      sourceExpense: expense,
    );
  }

  ScannedReceiptModel copyWith({
    String? merchantName,
    double? totalAmount,
    String? imagePath,
    String? receiptUrl,
    List<ScannedItemModel>? items,
    String? expenseId,
    ExpenseModel? sourceExpense,
  }) =>
      ScannedReceiptModel(
        merchantName: merchantName ?? this.merchantName,
        totalAmount: totalAmount ?? this.totalAmount,
        imagePath: imagePath ?? this.imagePath,
        receiptUrl: receiptUrl ?? this.receiptUrl,
        items: items ?? this.items,
        expenseId: expenseId ?? this.expenseId,
        sourceExpense: sourceExpense ?? this.sourceExpense,
      );
}
