import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/notifications/daily_reminder_service.dart';

void main() {
  test('sync/cancelOne are no-ops before initialize() is called', () async {
    final service = DailyReminderService();
    final rows = [
      NotificationRow(
        id: 'n1',
        type: 'crop_activity_due',
        title: 'Weeding due',
        message: 'Weeding is due',
        isRead: false,
        dismissed: false,
        createdAt: DateTime.now(),
      ),
    ];

    // Neither call should throw or touch a platform channel — the app's
    // NotificationsRepository holds a DailyReminderService unconditionally,
    // including in tests, which never call initialize().
    await service.sync(rows);
    await service.cancelOne('n1');
  });
}
