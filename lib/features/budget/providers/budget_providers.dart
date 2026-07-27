import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../data/models/budget_model.dart';
import '../data/repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(apiClientProvider));
});

class BudgetNotifier extends AsyncNotifier<BudgetModel?> {
  BudgetRepository get _repo => ref.read(budgetRepositoryProvider);

  List<BudgetModel> _all = [];

  @override
  Future<BudgetModel?> build() => _loadCurrent();

  Future<BudgetModel?> _loadCurrent() async {
    _all = await _repo.getBudgets();
    if (_all.isEmpty) return null;
    final now = DateTime.now();
    return _all.firstWhere(
      (b) => b.startDate?.month == now.month && b.startDate?.year == now.year,
      orElse: () => _all.first,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_loadCurrent);
  }

  void selectMonth(int month, int year) {
    final match = _all.where(
      (b) => b.startDate?.month == month && b.startDate?.year == year,
    );
    state = AsyncData(match.isNotEmpty ? match.first : null);
  }

  Future<BudgetModel> create({required double amountAllocated}) async {
    final created = await _repo.createBudget(amountAllocated: amountAllocated);
    Analytics.budgetCreated(amount: amountAllocated);
    state = AsyncData(created);
    return created;
  }

  Future<BudgetModel> updateAmount(double amountAllocated) async {
    final current = state.valueOrNull;
    if (current == null) throw StateError('No budget to update');
    final updated = await _repo.updateBudget(
      current.id,
      amountAllocated: amountAllocated,
    );
    state = AsyncData(updated);
    return updated;
  }

  Future<void> allocate({
    required String categoryId,
    required double amount,
  }) async {
    final current = state.valueOrNull;
    if (current == null) throw StateError('No budget to allocate to');
    final updated = await _repo.upsertAllocation(
      current.id,
      categoryId: categoryId,
      amountAllocated: amount,
    );
    state = AsyncData(updated);
  }

  Future<void> removeAllocation(String categoryId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = await _repo.deleteAllocation(current.id, categoryId);
    state = AsyncData(updated);
  }

  Future<void> delete() async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _repo.deleteBudget(current.id);
    state = const AsyncData(null);
  }
}

final budgetProvider =
    AsyncNotifierProvider<BudgetNotifier, BudgetModel?>(BudgetNotifier.new);
