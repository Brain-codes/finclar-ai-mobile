import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/logger_service.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final ApiClient _api;

  BudgetRepository(this._api);

  Future<List<BudgetModel>> getBudgets() async {
    Log.api('GET', ApiEndpoints.budgets);
    return _api.getAllPaginated<BudgetModel>(
      ApiEndpoints.budgets,
      fromItem: BudgetModel.fromJson,
    );
  }

  Future<BudgetModel> getBudget(String id) async {
    Log.api('GET', ApiEndpoints.budget(id));
    final response = await _api.get<BudgetModel>(
      ApiEndpoints.budget(id),
      fromData: (data) => BudgetModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<BudgetModel> createBudget({required double amountAllocated}) async {
    final body = <String, dynamic>{'amount_allocated': amountAllocated};
    Log.api('POST', ApiEndpoints.budgets, body: body);
    final response = await _api.post<BudgetModel>(
      ApiEndpoints.budgets,
      body: body,
      fromData: (data) => BudgetModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<BudgetModel> updateBudget(
    String id, {
    required double amountAllocated,
  }) async {
    final body = <String, dynamic>{'amount_allocated': amountAllocated};
    Log.api('PATCH', ApiEndpoints.budget(id), body: body);
    final response = await _api.patch<BudgetModel>(
      ApiEndpoints.budget(id),
      body: body,
      fromData: (data) => BudgetModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> deleteBudget(String id) async {
    Log.api('DELETE', ApiEndpoints.budget(id));
    await _api.delete<void>(ApiEndpoints.budget(id));
  }

  Future<BudgetModel> upsertAllocation(
    String budgetId, {
    required String categoryId,
    required double amountAllocated,
  }) async {
    final body = <String, dynamic>{
      'category_id': categoryId,
      'amount_allocated': amountAllocated,
    };
    Log.api('PUT', ApiEndpoints.budgetAllocations(budgetId), body: body);
    final response = await _api.put<BudgetModel>(
      ApiEndpoints.budgetAllocations(budgetId),
      body: body,
      fromData: (data) => BudgetModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<BudgetModel> deleteAllocation(
    String budgetId,
    String categoryId,
  ) async {
    Log.api('DELETE', ApiEndpoints.budgetAllocation(budgetId, categoryId));
    final response = await _api.delete<BudgetModel>(
      ApiEndpoints.budgetAllocation(budgetId, categoryId),
      fromData: (data) => BudgetModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }
}
