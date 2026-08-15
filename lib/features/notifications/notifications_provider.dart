import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifications_repository.dart';
import '../../models/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (_) => NotificationsRepository(),
);

final notificationsProvider =
    FutureProvider.autoDispose<NotificationsData>((ref) {
  return ref.read(notificationsRepositoryProvider).getNotifications();
});
