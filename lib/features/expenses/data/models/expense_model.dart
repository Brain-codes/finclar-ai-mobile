import 'dart:convert';

ExpenseModel expenseModelFromJson(String str) =>
    ExpenseModel.fromJson(json.decode(str));

String expenseModelToJson(ExpenseModel data) => json.encode(data.toJson());

class ExpenseCategoryRef {
  final String id;
  final String name;

  const ExpenseCategoryRef({required this.id, required this.name});

  factory ExpenseCategoryRef.fromJson(Map<String, dynamic> json) =>
      ExpenseCategoryRef(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class ExpenseItem {
  final String? id;
  final String name;
  final num quantity;
  final double unitPrice;
  final double? totalPrice;
  final String? categoryId;

  const ExpenseItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.totalPrice,
    this.categoryId,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
        id: json['id'],
        name: json['name'] ?? '',
        quantity: json['quantity'] ?? 1,
        unitPrice: _toDouble(json['unit_price']),
        totalPrice:
            json['total_price'] != null ? _toDouble(json['total_price']) : null,
        categoryId: json['category_id'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit_price': unitPrice,
        'category_id': categoryId,
      };
}

/// Payload for a single entry in `PATCH /expenses/{id}` → `items`
/// (`UpdateExpenseItemDto`). Only `id` is required; omitted fields are left
/// untouched by the backend.
class ExpenseItemUpdate {
  final String id;
  final String? name;
  final int? quantity;
  final double? unitPrice;
  final String? categoryId;

  const ExpenseItemUpdate({
    required this.id,
    this.name,
    this.quantity,
    this.unitPrice,
    this.categoryId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        if (name != null) 'name': name,
        if (quantity != null) 'quantity': quantity,
        if (unitPrice != null) 'unit_price': unitPrice,
        if (categoryId != null) 'category_id': categoryId,
      };
}

/// How trustworthy an expense's figures are. `verified` means a receipt scan or
/// bank sync backs it; `self_reported` means the user typed it in.
enum ExpenseVerificationLevel {
  verified,
  selfReported;

  static ExpenseVerificationLevel fromString(String? value) =>
      value == 'verified'
          ? ExpenseVerificationLevel.verified
          : ExpenseVerificationLevel.selfReported;

  String get value =>
      this == ExpenseVerificationLevel.verified ? 'verified' : 'self_reported';
}

class ExpenseModel {
  final String id;
  final double amount;
  final String? description;
  final DateTime date;
  final String? source;
  final String? status;
  final String? currency;
  final List<ExpenseCategoryRef> categories;
  final List<ExpenseItem> items;
  final String? receiptUrl;
  final String? claraInsight;
  final ExpenseVerificationLevel verificationLevel;

  /// Backend-computed nudge: true for large self-reported expenses. Actionable
  /// since 2026-08-03 — `PATCH /expenses/{id}` accepts a receipt, so this can
  /// drive an "attach proof" prompt (see docs/API.md).
  final bool evidenceSuggested;

  ExpenseModel({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    this.source,
    this.status,
    this.currency,
    this.categories = const [],
    this.items = const [],
    this.receiptUrl,
    this.claraInsight,
    this.verificationLevel = ExpenseVerificationLevel.selfReported,
    this.evidenceSuggested = false,
  });

  // ── Compat getters used by existing UI widgets ──────────────────────────────
  String get name =>
      (description != null && description!.trim().isNotEmpty)
          ? description!
          : (categories.isNotEmpty ? categories.first.name : 'Expense');

  String get category =>
      categories.isNotEmpty ? categories.first.name : 'Other';

  String? get categoryId =>
      categories.isNotEmpty ? categories.first.id : null;

  // Backend has no dedicated merchant/note fields; kept for UI compatibility.
  String? get merchant => null;
  String? get note => description;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'] ?? '',
        amount: _toDouble(json['amount']),
        description: json['description'],
        date: json['expense_date'] != null
            ? DateTime.parse(json['expense_date']).toLocal()
            : DateTime.now(),
        source: json['source'],
        status: json['status'],
        currency: json['currency'],
        categories: (json['categories'] as List<dynamic>? ?? [])
            .map((e) => ExpenseCategoryRef.fromJson(e as Map<String, dynamic>))
            .toList(),
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        receiptUrl: json['receipt_url'],
        claraInsight: json['clara_insight'],
        verificationLevel:
            ExpenseVerificationLevel.fromString(json['verification_level']),
        evidenceSuggested: json['evidence_suggested'] as bool? ?? false,
      );

  bool get isVerified => verificationLevel == ExpenseVerificationLevel.verified;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'description': description,
        'expense_date': date.toUtc().toIso8601String(),
        'source': source,
        'status': status,
        'currency': currency,
        'categories': categories.map((e) => e.toJson()).toList(),
        'items': items.map((e) => e.toJson()).toList(),
        'receipt_url': receiptUrl,
        'clara_insight': claraInsight,
        'verification_level': verificationLevel.value,
        'evidence_suggested': evidenceSuggested,
      };
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
