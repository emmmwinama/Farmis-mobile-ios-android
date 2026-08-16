import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifications_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.read(databaseProvider)),
);

final notificationsProvider =
    FutureProvider.autoDispose<NotificationsData>((ref) {
  return ref.read(notificationsRepositoryProvider).getNotifications();
});
