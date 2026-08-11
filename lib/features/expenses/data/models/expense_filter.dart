import 'package:intl/intl.dart';

/// Mirrors the optional query params of `GET /expenses`.
class ExpenseFilter {
  final String? search;
  final String? categoryId;
  final String? source;

  /// When set, this window replaces the month the summary card is showing —
  /// the two can't both scope the list, so the range wins while it's active.
  final DateTime? startDate;
  final DateTime? endDate;

  final String orderBy;
  final String orderDir;

  const ExpenseFilter({
    this.search,
    this.categoryId,
    this.source,
    this.startDate,
    this.endDate,
    this.orderBy = defaultOrderBy,
    this.orderDir = defaultOrderDir,
  });

  static const String defaultOrderBy = 'expense_date';
  static const String defaultOrderDir = 'desc';

  static const List<String> sources = ['manual', 'receipt', 'bank_sync'];

  static String sourceLabel(String source) => switch (source) {
        'manual' => 'Manual',
        'receipt' => 'Scanned',
        'bank_sync' => 'Bank',
        _ => source,
      };

  static String orderLabel(String orderBy, String orderDir) =>
      switch ((orderBy, orderDir)) {
        ('expense_date', 'desc') => 'Newest',
        ('expense_date', 'asc') => 'Oldest',
        ('amount', 'desc') => 'Highest',
        ('amount', 'asc') => 'Lowest',
        _ => 'Newest',
      };

  static const List<(String, String)> sortOptions = [
    ('expense_date', 'desc'),
    ('expense_date', 'asc'),
    ('amount', 'desc'),
    ('amount', 'asc'),
  ];

  bool get isSorted =>
      orderBy != defaultOrderBy || orderDir != defaultOrderDir;

  bool get hasDateRange => startDate != null && endDate != null;

  String get dateLabel {
    if (!hasDateRange) return 'Selected month';
    final start = startDate!;
    final end = endDate!;
    final sameDay =
        start.year == end.year && start.month == end.month && start.day == end.day;
    final formatted = sameDay
        ? DateFormat('d MMM y').format(start)
        : start.year == end.year
            ? '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM y').format(end)}'
            : '${DateFormat('d MMM y').format(start)} – ${DateFormat('d MMM y').format(end)}';
    return formatted;
  }

  /// Only the narrowing filters count — sort order changes what you see first,
  /// not what you see, so it doesn't earn a badge.
  int get activeCount => [
        search != null && search!.isNotEmpty,
        categoryId != null,
        source != null,
        hasDateRange,
      ].where((active) => active).length;

  bool get isActive => activeCount > 0 || isSorted;

  ExpenseFilter copyWith({
    String? search,
    String? categoryId,
    String? source,
    DateTime? startDate,
    DateTime? endDate,
    String? orderBy,
    String? orderDir,
    bool clearSearch = false,
    bool clearCategory = false,
    bool clearSource = false,
    bool clearDates = false,
  }) =>
      ExpenseFilter(
        search: clearSearch ? null : (search ?? this.search),
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        source: clearSource ? null : (source ?? this.source),
        startDate: clearDates ? null : (startDate ?? this.startDate),
        endDate: clearDates ? null : (endDate ?? this.endDate),
        orderBy: orderBy ?? this.orderBy,
        orderDir: orderDir ?? this.orderDir,
      );

  @override
  bool operator ==(Object other) =>
      other is ExpenseFilter &&
      other.search == search &&
      other.categoryId == categoryId &&
      other.source == source &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.orderBy == orderBy &&
      other.orderDir == orderDir;

  @override
  int get hashCode => Object.hash(
        search,
        categoryId,
        source,
        startDate,
        endDate,
        orderBy,
        orderDir,
      );
}
