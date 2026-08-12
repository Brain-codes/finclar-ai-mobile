class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? meta;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.meta,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: fromData != null && json['data'] != null ? fromData(json['data']) : null,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  bool get hasData => data != null;
}

class PaginatedResponse<T> {
  final bool success;
  final String? message;
  final List<T> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  /// Sibling fields some list endpoints (currently `/expenses`) add alongside
  /// `pagination` — computed over every row matching the filters, not just
  /// the current page. Null on endpoints that don't send them.
  final double? totalAmount;
  final List<Map<String, dynamic>>? categoryBreakdown;

  const PaginatedResponse({
    required this.success,
    this.message,
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
    this.totalAmount,
    this.categoryBreakdown,
  });

  bool get hasMore => hasNext;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((e) => fromItem(e as Map<String, dynamic>))
        .toList();
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      items: items,
      page: pagination['page'] as int? ?? 1,
      pageSize: pagination['page_size'] as int? ?? 20,
      total: pagination['total'] as int? ?? 0,
      totalPages: pagination['total_pages'] as int? ?? 0,
      hasNext: pagination['has_next'] as bool? ?? false,
      hasPrev: pagination['has_prev'] as bool? ?? false,
      totalAmount: _toDouble(json['total_expenses']),
      categoryBreakdown: (json['category_breakdown'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>(),
    );
  }
}

/// Some backend `Decimal` fields (e.g. `total_expenses`) serialize as strings
/// (`"2099000.00"`) rather than JSON numbers — same reason `ExpenseModel`
/// parses `amount` this way instead of a plain `as num?` cast.
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
