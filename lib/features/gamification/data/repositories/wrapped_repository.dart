import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/logger_service.dart';
import '../models/wrapped_model.dart';

class WrappedRepository {
  final ApiClient _api;

  WrappedRepository(this._api);

  /// [year]/[month] both default to the current period on the backend.
  /// Wrapped covers a single month, not a whole year (backend change,
  /// 2026-08-03).
  Future<WrappedModel> getWrapped({int? year, int? month}) async {
    final query = <String, dynamic>{'year': ?year, 'month': ?month};
    Log.api('GET', ApiEndpoints.wrapped, body: query);
    final response = await _api.get<WrappedModel>(
      ApiEndpoints.wrapped,
      queryParams: query.isEmpty ? null : query,
      fromData: (data) => WrappedModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }
}
