import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../data/models/budget_model.dart';
import '../data/repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(apiClientProvider));
});

class BudgetState {
  /// Budget for the selected month. Null when none exists for that month —
  /// it is never back-filled from another month.
  final BudgetModel? budget;

  /// Most recent budget strictly before the selected month, used to show a
  /// carry-over summary above the empty state.
  final BudgetModel? previous;

  final int month;
  final int year;
  final bool hasAnyBudget;

  const BudgetState({
    this.budget,
    this.previous,
    required this.month,
    required this.year,
    this.hasAnyBudget = false,
  });

  bool get isCurrentMonth {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }
}

class BudgetNotifier extends AsyncNotifier<BudgetState> {
  BudgetRepository get _repo => ref.read(budgetRepositoryProvider);

  List<BudgetModel> _all = [];
  int? _month;
  int? _year;

  @override
  Future<BudgetState> build() async {
    _all = await _repo.getBudgets();
    return _resolve();
  }

  BudgetState _resolve() {
    final now = DateTime.now();
    final month = _month ?? now.month;
    final year = _year ?? now.year;

    final forMonth = _all.where(
      (b) => b.startDate?.month == month && b.startDate?.year == year,
    );

    final earlier = _all
        .where((b) => b.startDate != null)
        .where((b) => _key(b.startDate!) < year * 12 + (month - 1))
        .toList()
      ..sort((a, b) => _key(b.startDate!).compareTo(_key(a.startDate!)));

    return BudgetState(
      budget: forMonth.isNotEmpty ? forMonth.first : null,
      previous: earlier.isNotEmpty ? earlier.first : null,
      month: month,
      year: year,
      hasAnyBudget: _all.isNotEmpty,
    );
  }

  int _key(DateTime d) => d.year * 12 + (d.month - 1);

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      _all = await _repo.getBudgets();
      return _resolve();
    });
  }

  void selectMonth(int month, int year) {
    _month = month;
    _year = year;
    state = AsyncData(_resolve());
  }

  /// Replaces [budget] in the cached list so the selected-month view and the
  /// previous-month summary stay consistent without a refetch.
  void _upsert(BudgetModel budget) {
    final i = _all.indexWhere((b) => b.id == budget.id);
    if (i >= 0) {
      _all[i] = budget;
    } else {
      _all.add(budget);
    }
    state = AsyncData(_resolve());
  }

  Future<BudgetModel> create({required double amountAllocated}) async {
    final created = await _repo.createBudget(amountAllocated: amountAllocated);
    Analytics.budgetCreated(amount: amountAllocated);
    // A new budget always lands in the month the backend stamped it with —
    // jump the view there so the user sees what they just created.
    if (created.startDate != null) {
      _month = created.startDate!.month;
      _year = created.startDate!.year;
    }
    _upsert(created);
    return created;
  }

  Future<BudgetModel> updateAmount(double amountAllocated) async {
    final current = state.valueOrNull?.budget;
    if (current == null) throw StateError('No budget to update');
    final updated = await _repo.updateBudget(
      current.id,
      amountAllocated: amountAllocated,
    );
    _upsert(updated);
    return updated;
  }

  Future<void> allocate({
    required String categoryId,
    required double amount,
  }) async {
    final current = state.valueOrNull?.budget;
    if (current == null) throw StateError('No budget to allocate to');
    final updated = await _repo.upsertAllocation(
      current.id,
      categoryId: categoryId,
      amountAllocated: amount,
    );
    _upsert(updated);
  }

  Future<void> removeAllocation(String categoryId) async {
    final current = state.valueOrNull?.budget;
    if (current == null) return;
    final updated = await _repo.deleteAllocation(current.id, categoryId);
    _upsert(updated);
  }

  Future<void> delete() async {
    final current = state.valueOrNull?.budget;
    if (current == null) return;
    await _repo.deleteBudget(current.id);
    _all.removeWhere((b) => b.id == current.id);
    state = AsyncData(_resolve());
  }
}

final budgetProvider =
    AsyncNotifierProvider<BudgetNotifier, BudgetState>(BudgetNotifier.new);
