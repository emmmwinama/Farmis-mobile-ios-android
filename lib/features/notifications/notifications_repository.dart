import '../../core/api/api_client.dart';
import '../../models/app_notification.dart';

class NotificationsRepository {
  Future<NotificationsData> getNotifications() async {
    final response = await ApiClient.get('/mobile/notifications');
    return NotificationsData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> markAllRead() async {
    await ApiClient.post('/mobile/notifications', {'markAllRead': true});
  }
}
