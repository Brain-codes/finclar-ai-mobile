import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/services/image_compression_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../home/data/models/home_insight_model.dart';
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

  /// [receipt] is optional — when provided, the backend AI-verifies the
  /// entered amount against it and marks the expense verified. The endpoint
  /// is multipart regardless of whether a receipt is attached: the DTO rides
  /// as a JSON-encoded `dto` form field so the image can go in the same
  /// request (backend change, 2026-08-03 — was a plain JSON body before).
  Future<ExpenseModel> createExpense({
    required double amount,
    String? description,
    List<String> categoryIds = const [],
    required DateTime expenseDate,
    String? currency,
    File? receipt,
  }) async {
    final dto = <String, dynamic>{
      'amount': amount,
      'category_ids': categoryIds,
      'expense_date': expenseDate.toUtc().toIso8601String(),
    };
    if (description != null && description.isNotEmpty) {
      dto['description'] = description;
    }
    if (currency != null) dto['currency'] = currency;
    final formData = FormData.fromMap({
      'dto': jsonEncode(dto),
      if (receipt != null) 'receipt': await ImageCompressionService.multipart(receipt),
    });
    Log.api('POST', ApiEndpoints.expenses, body: dto);
    final response = await _api.uploadFile<ExpenseModel>(
      ApiEndpoints.expenses,
      formData: formData,
      fromData: (data) => ExpenseModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// [receipt] attaches proof to an existing expense — the backend AI-verifies
  /// it against the new [amount] (or the current one when amount isn't
  /// changing) and flips the expense to verified. Multipart for the same
  /// reason as [createExpense] (backend change, 2026-08-03).
  Future<ExpenseModel> updateExpense(
    String id, {
    double? amount,
    String? description,
    List<String>? categoryIds,
    DateTime? expenseDate,
    String? currency,
    String? status,
    List<ExpenseItemUpdate>? items,
    File? receipt,
  }) async {
    final dto = <String, dynamic>{};
    if (amount != null) dto['amount'] = amount;
    if (description != null) dto['description'] = description;
    if (categoryIds != null) dto['category_ids'] = categoryIds;
    if (expenseDate != null) {
      dto['expense_date'] = expenseDate.toUtc().toIso8601String();
    }
    if (currency != null) dto['currency'] = currency;
    if (status != null) dto['status'] = status;
    if (items != null && items.isNotEmpty) {
      dto['items'] = items.map((e) => e.toJson()).toList();
    }
    final formData = FormData.fromMap({
      'dto': jsonEncode(dto),
      if (receipt != null) 'receipt': await ImageCompressionService.multipart(receipt),
    });
    Log.api('PATCH', ApiEndpoints.expense(id), body: dto);
    final response = await _api.uploadFile<ExpenseModel>(
      ApiEndpoints.expense(id),
      formData: formData,
      method: 'PATCH',
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
      'image': await ImageCompressionService.multipart(image),
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

  Future<HomeInsightModel> getHomeInsight() async {
    Log.api('GET', ApiEndpoints.homeInsight);
    final response = await _api.get<HomeInsightModel>(
      ApiEndpoints.homeInsight,
      // Older builds of this endpoint returned a bare string; tolerate both so
      // a backend rollback can't blank the home card.
      fromData: (data) => data is Map<String, dynamic>
          ? HomeInsightModel.fromJson(data)
          : HomeInsightModel(
              insight: data?.toString() ?? '',
              totalIncome: 0,
              totalExpenses: 0,
              availableBalance: 0,
              verifiedPct: 0,
              selfReportedPct: 0,
            ),
    );
    return response.data ??
        const HomeInsightModel(
          insight: '',
          totalIncome: 0,
          totalExpenses: 0,
          availableBalance: 0,
          verifiedPct: 0,
          selfReportedPct: 0,
        );
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
