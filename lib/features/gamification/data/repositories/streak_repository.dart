import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/logger_service.dart';
import '../models/expense_streak_model.dart';

class StreakRepository {
  final ApiClient _api;

  StreakRepository(this._api);

  Future<ExpenseStreakModel> getStreak() async {
    Log.api('GET', ApiEndpoints.expenseStreak);
    final response = await _api.get<ExpenseStreakModel>(
      ApiEndpoints.expenseStreak,
      fromData: (data) =>
          ExpenseStreakModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// QA only. Jumps the streak to [days] and fires the same badge/push logic a
  /// real expense log would.
  Future<ExpenseStreakModel> simulateStreak(int days) async {
    Log.api('POST', ApiEndpoints.expenseStreakSimulate(days));
    final response = await _api.post<ExpenseStreakModel>(
      ApiEndpoints.expenseStreakSimulate(days),
      fromData: (data) =>
          ExpenseStreakModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }
}
