import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/logger_service.dart';
import '../models/plan_model.dart';
import '../models/subscription_model.dart';

class SubscriptionRepository {
  final ApiClient _api;

  SubscriptionRepository(this._api);

  Future<PlansResponseModel> getPlans() async {
    Log.api('GET', ApiEndpoints.subscriptionPlans);
    final response = await _api.get<PlansResponseModel>(
      ApiEndpoints.subscriptionPlans,
      fromData: (data) =>
          PlansResponseModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<SubscriptionModel> getMySubscription() async {
    Log.api('GET', ApiEndpoints.mySubscription);
    final response = await _api.get<SubscriptionModel>(
      ApiEndpoints.mySubscription,
      fromData: (data) =>
          SubscriptionModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<SubscriptionModel> verifyCheckout({
    required String reference,
    required PlanCode planCode,
  }) async {
    final body = <String, dynamic>{
      'reference': reference,
      'plan_code': planCode.value,
    };
    Log.api('POST', ApiEndpoints.subscriptionVerify, body: body);
    final response = await _api.post<SubscriptionModel>(
      ApiEndpoints.subscriptionVerify,
      body: body,
      fromData: (data) =>
          SubscriptionModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<SubscriptionModel> cancel() async {
    Log.api('POST', ApiEndpoints.subscriptionCancel);
    final response = await _api.post<SubscriptionModel>(
      ApiEndpoints.subscriptionCancel,
      fromData: (data) =>
          SubscriptionModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<SubscriptionModel> resume() async {
    Log.api('POST', ApiEndpoints.subscriptionResume);
    final response = await _api.post<SubscriptionModel>(
      ApiEndpoints.subscriptionResume,
      fromData: (data) =>
          SubscriptionModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }
}
