import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/services/logger_service.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/expense_summary_model.dart';

class ExpenseRepository {
  final ApiClient _api;

  ExpenseRepository(this._api);

  Future<PaginatedResponse<ExpenseModel>> getExpenses({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
    String? source,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String orderBy = 'expense_date',
    String orderDir = 'desc',
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'order_by': orderBy,
      'order_dir': orderDir,
    };
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (categoryId != null) query['category_id'] = categoryId;
    if (source != null) query['source'] = source;
    if (status != null) query['status'] = status;
    if (startDate != null) {
      query['start_date'] = startDate.toUtc().toIso8601String();
    }
    if (endDate != null) query['end_date'] = endDate.toUtc().toIso8601String();
    Log.api('GET', ApiEndpoints.expenses, body: query);
    return _api.getPaginated<ExpenseModel>(
      ApiEndpoints.expenses,
      queryParams: query,
      fromItem: ExpenseModel.fromJson,
    );
  }

  Future<ExpenseModel> getExpense(String id) async {
    Log.api('GET', ApiEndpoints.expense(id));
    final response = await _api.get<ExpenseModel>(
      ApiEndpoints.expense(id),
      fromData: (data) => ExpenseModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<ExpenseModel> createExpense({
    required double amount,
    String? description,
    List<String> categoryIds = const [],
    required DateTime expenseDate,
    String? currency,
  }) async {
    final body = <String, dynamic>{
      'amount': amount,
      'category_ids': categoryIds,
      'expense_date': expenseDate.toUtc().toIso8601String(),
    };
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    if (currency != null) body['currency'] = currency;
    Log.api('POST', ApiEndpoints.expenses, body: body);
    final response = await _api.post<ExpenseModel>(
      ApiEndpoints.expenses,
      body: body,
      fromData: (data) => ExpenseModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<ExpenseModel> updateExpense(
    String id, {
    double? amount,
    String? description,
    List<String>? categoryIds,
    DateTime? expenseDate,
    String? currency,
    String? status,
    List<ExpenseItemUpdate>? items,
  }) async {
    final body = <String, dynamic>{};
    if (amount != null) body['amount'] = amount;
    if (description != null) body['description'] = description;
    if (categoryIds != null) body['category_ids'] = categoryIds;
    if (expenseDate != null) {
      body['expense_date'] = expenseDate.toUtc().toIso8601String();
    }
    if (currency != null) body['currency'] = currency;
    if (status != null) body['status'] = status;
    if (items != null && items.isNotEmpty) {
      body['items'] = items.map((e) => e.toJson()).toList();
    }
    Log.api('PATCH', ApiEndpoints.expense(id), body: body);
    final response = await _api.patch<ExpenseModel>(
      ApiEndpoints.expense(id),
      body: body,
      fromData: (data) => ExpenseModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> deleteExpense(String id) async {
    Log.api('DELETE', ApiEndpoints.expense(id));
    await _api.delete<void>(ApiEndpoints.expense(id));
  }

  Future<ExpenseModel> uploadReceipt(File image) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(image.path),
    });
    Log.api('POST', ApiEndpoints.expenseReceipt);
    final response = await _api.uploadFile<ExpenseModel>(
      ApiEndpoints.expenseReceipt,
      formData: formData,
      fromData: (data) => ExpenseModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<ExpenseSummaryModel> getSummary({int? year, int? month}) async {
    final query = <String, dynamic>{};
    if (year != null) query['year'] = year;
    if (month != null) query['month'] = month;
    Log.api('GET', ApiEndpoints.expenseSummary, body: query);
    final response = await _api.get<ExpenseSummaryModel>(
      ApiEndpoints.expenseSummary,
      queryParams: query.isEmpty ? null : query,
      fromData: (data) =>
          ExpenseSummaryModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<String> getHomeInsight() async {
    Log.api('GET', ApiEndpoints.homeInsight);
    final response = await _api.get<String>(
      ApiEndpoints.homeInsight,
      fromData: (data) => data is Map<String, dynamic>
          ? (data['insight'] as String? ?? '')
          : (data as String? ?? ''),
    );
    return response.data ?? '';
  }

  Future<List<CategoryModel>> getCategories() async {
    Log.api('GET', ApiEndpoints.categories);
    return _api.getAllPaginated<CategoryModel>(
      ApiEndpoints.categories,
      fromItem: CategoryModel.fromJson,
    );
  }

  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? icon,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (description != null) body['description'] = description;
    if (icon != null) body['icon'] = icon;
    Log.api('POST', ApiEndpoints.categories, body: body);
    final response = await _api.post<CategoryModel>(
      ApiEndpoints.categories,
      body: body,
      fromData: (data) => CategoryModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }
}
