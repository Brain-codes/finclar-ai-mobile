import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../models/income_model.dart';
import '../models/income_source_model.dart';

class IncomeRepository {
  final ApiClient _api;

  IncomeRepository(this._api);

  Future<List<IncomeSourceModel>> getSources() async {
    Log.api('GET', ApiEndpoints.incomeSources);
    return _api.getAllPaginated<IncomeSourceModel>(
      ApiEndpoints.incomeSources,
      fromItem: IncomeSourceModel.fromJson,
    );
  }

  Future<IncomeSourceModel> createCustomSource(String name) async {
    Log.api('POST', ApiEndpoints.incomeSources, body: {'name': name});
    final response = await _api.post<IncomeSourceModel>(
      ApiEndpoints.incomeSources,
      body: {'name': name},
      fromData: (data) =>
          IncomeSourceModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<IncomeModel?> getIncome() async {
    Log.api('GET', ApiEndpoints.income);
    try {
      final response = await _api.get<IncomeModel>(
        ApiEndpoints.income,
        fromData: (data) => IncomeModel.fromJson(data as Map<String, dynamic>),
      );
      Log.d('GET /income → success=${response.success} message="${response.message}" data=${response.data?.toJson()}');
      return response.data;
    } on NotFoundException catch (e) {
      Log.d('GET /income → 404: ${e.message}');
      return null;
    }
  }

  Future<IncomeModel> createIncome({
    required double amount,
    required String sourceId,
    required String reoccurrence,
    required String startDate,
    String? note,
  }) async {
    Log.api('POST', ApiEndpoints.income, body: {
      'amount': amount,
      'source_id': sourceId,
      'reoccurrence': reoccurrence,
      'start_date': startDate,
    });
    final response = await _api.post<IncomeModel>(
      ApiEndpoints.income,
      body: {
        'amount': amount,
        'source_id': sourceId,
        'reoccurrence': reoccurrence,
        'start_date': startDate,
        if (note != null && note.isNotEmpty) 'note': note,
      },
      fromData: (data) => IncomeModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<IncomeModel> updateIncome({
    double? amount,
    String? sourceId,
    String? reoccurrence,
    String? startDate,
    String? note,
  }) async {
    Log.api('PATCH', ApiEndpoints.income);
    final body = <String, dynamic>{
      'amount': amount,
      'source_id': sourceId,
      'reoccurrence': reoccurrence,
      'start_date': startDate,
      'note': note,
    }..removeWhere((_, v) => v == null);
    final response = await _api.patch<IncomeModel>(
      ApiEndpoints.income,
      body: body,
      fromData: (data) => IncomeModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }
}
