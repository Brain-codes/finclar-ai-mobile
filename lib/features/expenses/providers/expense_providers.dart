import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/logger_service.dart';
import '../../gamification/providers/streak_providers.dart';
import '../../home/providers/home_dashboard_provider.dart';
import '../data/models/category_model.dart';
import '../data/models/expense_filter.dart';
import '../data/models/expense_model.dart';
import '../data/models/expense_summary_model.dart';
import '../data/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(apiClientProvider));
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(expenseRepositoryProvider).getCategories();
});

class CategoryPageState {
  final List<CategoryModel> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const CategoryPageState({
    this.items = const [],
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  CategoryPageState copyWith({
    List<CategoryModel>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return CategoryPageState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Server-paged categories for the picker. [categoriesProvider] still walks
/// every page for the places that need name/colour lookups across the whole
/// set — this one exists so the picker doesn't block on all of them.
class CategoryPageNotifier extends AsyncNotifier<CategoryPageState> {
  ExpenseRepository get _repo => ref.read(expenseRepositoryProvider);

  @override
  Future<CategoryPageState> build() => _loadFirstPage();

  Future<CategoryPageState> _loadFirstPage() async {
    final res = await _repo.getCategoriesPage(page: 1);
    return CategoryPageState(
      items: res.items,
      page: res.page,
      hasMore: res.hasNext,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_loadFirstPage);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final res = await _repo.getCategoriesPage(page: current.page + 1);
      state = AsyncData(current.copyWith(
        items: [...current.items, ...res.items],
        page: res.page,
        hasMore: res.hasNext,
        isLoadingMore: false,
      ));
    } on AppException catch (e) {
      Log.e('Load more categories failed', error: e);
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final categoryPageProvider =
    AsyncNotifierProvider<CategoryPageNotifier, CategoryPageState>(
  CategoryPageNotifier.new,
);

class ExpenseListState {
  final List<ExpenseModel> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final int month;
  final int year;

  /// Computed server-side over every expense matching the current filters,
  /// not just the loaded pages — `/expenses` returns these as siblings of
  /// `pagination` (see [PaginatedResponse.totalAmount] /
  /// [PaginatedResponse.categoryBreakdown]).
  final double total;
  final List<CategorySummaryModel> categoryBreakdown;

  const ExpenseListState({
    this.items = const [],
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    required this.month,
    required this.year,
    this.total = 0,
    this.categoryBreakdown = const [],
  });

  bool get isEmpty => items.isEmpty;

  ExpenseListState copyWith({
    List<ExpenseModel>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    int? month,
    int? year,
    double? total,
    List<CategorySummaryModel>? categoryBreakdown,
  }) =>
      ExpenseListState(
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        month: month ?? this.month,
        year: year ?? this.year,
        total: total ?? this.total,
        categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      );
}

/// Lives outside [ExpenseListState] on purpose: the list goes to `AsyncLoading`
/// while a filter is being applied, and the header badge and filter chips have
/// to keep rendering through that.
class ExpenseFilterNotifier extends Notifier<ExpenseFilter> {
  @override
  ExpenseFilter build() => const ExpenseFilter();

  void set(ExpenseFilter filter) => state = filter;
}

final expenseFilterProvider =
    NotifierProvider<ExpenseFilterNotifier, ExpenseFilter>(
  ExpenseFilterNotifier.new,
);

class ExpenseListNotifier extends AsyncNotifier<ExpenseListState> {
  ExpenseRepository get _repo => ref.read(expenseRepositoryProvider);

  late int _month;
  late int _year;

  ExpenseFilter get _filter => ref.read(expenseFilterProvider);

  @override
  Future<ExpenseListState> build() async {
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    return _loadFirstPage(_month, _year);
  }

  (DateTime, DateTime) _monthRange(int month, int year) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1).subtract(const Duration(seconds: 1));
    return (start, end);
  }

  /// A custom range from the filter replaces the month window entirely —
  /// intersecting the two would silently return nothing whenever they don't
  /// overlap, which reads as a broken filter.
  (DateTime, DateTime) _range(int month, int year) {
    final filter = _filter;
    if (filter.hasDateRange) return (filter.startDate!, filter.endDate!);
    return _monthRange(month, year);
  }

  Future<ExpenseListState> _loadFirstPage(int month, int year) async {
    final (start, end) = _range(month, year);
    final res = await _repo.getExpenses(
      page: 1,
      pageSize: AppConstants.defaultPageSize,
      startDate: start,
      endDate: end,
      search: _filter.search,
      categoryId: _filter.categoryId,
      source: _filter.source,
      orderBy: _filter.orderBy,
      orderDir: _filter.orderDir,
    );
    return ExpenseListState(
      items: res.items,
      page: res.page,
      hasMore: res.hasNext,
      month: month,
      year: year,
      total: res.totalAmount ?? 0,
      categoryBreakdown: (res.categoryBreakdown ?? [])
          .map(CategorySummaryModel.fromJson)
          .toList(),
    );
  }

  Future<void> setMonth(int month) async {
    _month = month;
    // Picking a month while a custom range is active would leave the summary
    // card showing one window and the list showing another — the month the
    // user just tapped wins.
    if (_filter.hasDateRange) {
      ref
          .read(expenseFilterProvider.notifier)
          .set(_filter.copyWith(clearDates: true));
    }
    // Fresh load (no previous value) so the screen shows the skeleton, not
    // the stale list, while the new month's expenses are fetched.
    state = const AsyncLoading<ExpenseListState>();
    state = await AsyncValue.guard(() => _loadFirstPage(month, _year));
  }

  Future<void> setFilter(ExpenseFilter filter) async {
    if (filter == _filter) return;
    ref.read(expenseFilterProvider.notifier).set(filter);
    state = const AsyncLoading<ExpenseListState>();
    state = await AsyncValue.guard(() => _loadFirstPage(_month, _year));
  }

  Future<void> clearFilter() => setFilter(const ExpenseFilter());

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _loadFirstPage(_month, _year));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final (start, end) = _range(current.month, current.year);
      final res = await _repo.getExpenses(
        page: current.page + 1,
        pageSize: AppConstants.defaultPageSize,
        startDate: start,
        endDate: end,
        search: _filter.search,
        categoryId: _filter.categoryId,
        source: _filter.source,
        orderBy: _filter.orderBy,
        orderDir: _filter.orderDir,
      );
      state = AsyncData(current.copyWith(
        items: [...current.items, ...res.items],
        page: res.page,
        hasMore: res.hasNext,
        isLoadingMore: false,
        // total/categoryBreakdown are already whole-filter values from page 1;
        // later pages carry the same numbers, no need to overwrite.
      ));
    } on AppException catch (e) {
      Log.e('Load more expenses failed', error: e);
      state = AsyncData(current.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  /// Backend receipt scan: uploads the photo to `POST /expenses/receipt`,
  /// which creates the expense server-side, then refreshes the list.
  Future<ExpenseModel> scanReceipt(File image) async {
    final created = await _repo.uploadReceipt(image);
    Analytics.receiptScanned();
    Analytics.expenseAdded(
      method: 'receipt',
      amount: created.amount,
      currency: created.currency,
    );
    ref.invalidate(expenseStreakProvider);
    await refresh();
    return created;
  }

  Future<ExpenseModel> create({
    required double amount,
    String? description,
    List<String> categoryIds = const [],
    required DateTime expenseDate,
    String? currency,
    File? receipt,
  }) async {
    final created = await _repo.createExpense(
      amount: amount,
      description: description,
      categoryIds: categoryIds,
      expenseDate: expenseDate,
      currency: currency,
      receipt: receipt,
    );
    Analytics.expenseAdded(
      method: receipt != null ? 'manual_with_receipt' : 'manual',
      amount: created.amount,
      currency: created.currency,
    );
    ref.invalidate(expenseStreakProvider);
    await refresh();
    return created;
  }

  Future<ExpenseModel> edit(
    String id, {
    double? amount,
    String? description,
    List<String>? categoryIds,
    DateTime? expenseDate,
    String? currency,
    List<ExpenseItemUpdate>? items,
    File? receipt,
  }) async {
    final updated = await _repo.updateExpense(
      id,
      amount: amount,
      description: description,
      categoryIds: categoryIds,
      expenseDate: expenseDate,
      currency: currency,
      items: items,
      receipt: receipt,
    );
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(
        items: [
          for (final e in current.items) if (e.id == id) updated else e,
        ],
      ));
    }
    await _refreshTotals();
    return updated;
  }

  Future<void> delete(String id) async {
    await _repo.deleteExpense(id);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(
        items: current.items.where((e) => e.id != id).toList(),
      ));
    }
    await _refreshTotals();
    ref.invalidate(homeSummaryProvider);
    ref.invalidate(homeInsightProvider);
    ref.invalidate(spendingSummaryProvider);
  }

  /// Re-fetches page 1 purely to pick up the fresh `total`/`categoryBreakdown`
  /// after an edit/delete shifts them, without resetting pagination or the
  /// already-loaded pages the way a full [refresh] would.
  Future<void> _refreshTotals() async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final (start, end) = _range(current.month, current.year);
      final res = await _repo.getExpenses(
        page: 1,
        pageSize: AppConstants.defaultPageSize,
        startDate: start,
        endDate: end,
        search: _filter.search,
        categoryId: _filter.categoryId,
        source: _filter.source,
        orderBy: _filter.orderBy,
        orderDir: _filter.orderDir,
      );
      final latest = state.valueOrNull;
      if (latest == null) return;
      state = AsyncData(latest.copyWith(
        total: res.totalAmount ?? 0,
        categoryBreakdown: (res.categoryBreakdown ?? [])
            .map(CategorySummaryModel.fromJson)
            .toList(),
      ));
    } on AppException catch (e) {
      Log.e('Refresh expense totals failed', error: e);
    }
  }
}

final expenseListProvider =
    AsyncNotifierProvider<ExpenseListNotifier, ExpenseListState>(
  ExpenseListNotifier.new,
);
