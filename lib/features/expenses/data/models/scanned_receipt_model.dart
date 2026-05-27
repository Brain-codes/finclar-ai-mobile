import 'dart:convert';

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

  ScannedItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.quantity,
    required this.unitPrice,
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
  }) =>
      ScannedItemModel(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
      );
}

class ScannedReceiptModel {
  final String merchantName;
  final double totalAmount;
  final String? imagePath;
  final List<ScannedItemModel> items;

  ScannedReceiptModel({
    required this.merchantName,
    required this.totalAmount,
    this.imagePath,
    required this.items,
  });

  ScannedReceiptModel copyWith({
    String? merchantName,
    double? totalAmount,
    String? imagePath,
    List<ScannedItemModel>? items,
  }) =>
      ScannedReceiptModel(
        merchantName: merchantName ?? this.merchantName,
        totalAmount: totalAmount ?? this.totalAmount,
        imagePath: imagePath ?? this.imagePath,
        items: items ?? this.items,
      );
}
