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
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => fromItem(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      items: items,
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? 1,
      pageSize: data['pageSize'] as int? ?? 20,
      hasMore: data['hasMore'] as bool? ?? false,
    );
  }
}
