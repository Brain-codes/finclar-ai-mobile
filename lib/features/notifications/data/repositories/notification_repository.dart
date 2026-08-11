import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/services/logger_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _api;

  NotificationRepository(this._api);

  Future<PaginatedResponse<NotificationModel>> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool unreadOnly = false,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (unreadOnly) 'unread_only': true,
    };
    Log.api('GET', ApiEndpoints.notifications, body: query);
    return _api.getPaginated<NotificationModel>(
      ApiEndpoints.notifications,
      queryParams: query,
      fromItem: NotificationModel.fromJson,
    );
  }

  Future<int> getUnreadCount() async {
    Log.api('GET', ApiEndpoints.notificationsUnreadCount);
    final response = await _api.get<int>(
      ApiEndpoints.notificationsUnreadCount,
      fromData: (data) => (data as Map<String, dynamic>)['count'] as int? ?? 0,
    );
    return response.data ?? 0;
  }

  Future<NotificationModel?> markRead(String id) async {
    Log.api('PUT', ApiEndpoints.notificationRead(id));
    final response = await _api.put<NotificationModel>(
      ApiEndpoints.notificationRead(id),
      fromData: (data) =>
          NotificationModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<void> markAllRead() async {
    Log.api('PUT', ApiEndpoints.notificationsReadAll);
    await _api.put<void>(ApiEndpoints.notificationsReadAll);
  }
}
