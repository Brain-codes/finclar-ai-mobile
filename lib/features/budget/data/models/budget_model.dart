import 'dart:convert';

List<BudgetModel> budgetModelListFromJson(String str) =>
    List<BudgetModel>.from(json.decode(str).map((x) => BudgetModel.fromJson(x)));

BudgetModel budgetModelFromJson(String str) =>
    BudgetModel.fromJson(json.decode(str));

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

class BudgetModel {
  final String id;
  final double amountAllocated;
  final double spent;
  final double remaining;
  final double pctUsed;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<AllocationModel> allocations;

  /// AI one-liner delivered inline with the budget — saves a separate call to
  /// `GET /budgets/{id}/insight`. Defaults to `""` on the backend.
  final String? claraInsight;

  const BudgetModel({
    required this.id,
    required this.amountAllocated,
    required this.spent,
    required this.remaining,
    required this.pctUsed,
    this.startDate,
    this.endDate,
    required this.allocations,
    this.claraInsight,
  });

  double get totalAllocatedToCategories =>
      allocations.fold(0, (sum, a) => sum + a.amountAllocated);

  double get unallocated =>
      (amountAllocated - totalAllocatedToCategories).clamp(0, amountAllocated);

  double get allocatedSpent => allocations.fold(0, (sum, a) => sum + a.spent);

  /// Deliberately not `remaining` (which the backend computes against the full
  /// budget) so the details sheet rows subtract exactly:
  /// allocated − allocatedSpent. Goes negative when categories are overspent.
  double get allocatedRemaining => totalAllocatedToCategories - allocatedSpent;

  int get daysLeft {
    if (endDate == null) return 0;
    final diff = endDate!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        id: json['id'] ?? '',
        amountAllocated: _toDouble(json['amount_allocated']),
        spent: _toDouble(json['spent']),
        remaining: _toDouble(json['remaining']),
        pctUsed: _toDouble(json['pct_used']),
        startDate: _toDate(json['start_date']),
        endDate: _toDate(json['end_date']),
        allocations: json['allocations'] != null
            ? List<AllocationModel>.from(
                json['allocations'].map((x) => AllocationModel.fromJson(x)))
            : [],
        claraInsight: json['clara_insight'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount_allocated': amountAllocated,
        'spent': spent,
        'remaining': remaining,
        'pct_used': pctUsed,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'allocations': List<dynamic>.from(allocations.map((x) => x.toJson())),
        'clara_insight': claraInsight,
      };
}

class AllocationModel {
  final String id;
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final double amountAllocated;
  final double spent;
  final double remaining;
  final double pctUsed;

  const AllocationModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    required this.amountAllocated,
    required this.spent,
    required this.remaining,
    required this.pctUsed,
  });

  factory AllocationModel.fromJson(Map<String, dynamic> json) => AllocationModel(
        id: json['id'] ?? '',
        categoryId: json['category_id'] ?? '',
        categoryName: json['category_name'] ?? '',
        categoryIcon: json['category_icon'],
        amountAllocated: _toDouble(json['amount_allocated']),
        spent: _toDouble(json['spent']),
        remaining: _toDouble(json['remaining']),
        pctUsed: _toDouble(json['pct_used']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'category_name': categoryName,
        'category_icon': categoryIcon,
        'amount_allocated': amountAllocated,
        'spent': spent,
        'remaining': remaining,
        'pct_used': pctUsed,
      };
}
