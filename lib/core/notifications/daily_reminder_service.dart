import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../db/app_database.dart';

/// Mirrors every currently-active (undismissed) alert as a device
/// notification that repeats daily at [_reminderHour] until the farmer
/// either records the underlying activity (which clears the alert row,
/// see `NotificationsRepository`'s stale-purge) or dismisses it.
///
/// [initialize] must be called once, at app startup, before [sync] or
/// [cancelOne] do anything — this lets `NotificationsRepository` hold a
/// service instance unconditionally (including in tests, which never call
/// [initialize]) without ever touching a platform channel that doesn't
/// exist in the test environment.
class DailyReminderService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _reminderHour = 7;
  static const _channelId = 'daily_reminders';
  static const _channelName = 'Daily reminders';
  static const _channelDescription =
      'Daily reminders for farm activities that are due, overdue, or '
      'haven\'t been recorded yet, until you record or dismiss them.';

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    try {
      await _plugin.initialize(
        const InitializationSettings(
            android: androidSettings, iOS: iosSettings),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      _initialized = true;
    } catch (e, st) {
      // A platform/permission failure here shouldn't block the app from
      // starting — the farmer just won't get device reminders this run.
      debugPrint('DailyReminderService.initialize() failed: $e\n$st');
    }
  }

  int _idFor(String notificationId) => notificationId.hashCode & 0x7fffffff;

  /// The next occurrence of [_reminderHour] in device-local wall-clock
  /// time, expressed as a [tz.TZDateTime]. Built from plain local [DateTime]
  /// arithmetic and then wrapped with [tz.TZDateTime.from] — which preserves
  /// the underlying absolute instant rather than reinterpreting the clock
  /// reading — so this fires at the right moment without needing a real
  /// timezone-name lookup (`flutter_timezone` et al). The one caveat: a
  /// daily repeat matches UTC clock components going forward, so the
  /// device-local fire time can drift by up to an hour across a DST
  /// transition until the next `sync()` call recomputes it.
  tz.TZDateTime _nextReminderTime() {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, _reminderHour);
    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }
    return tz.TZDateTime.from(target, tz.UTC);
  }

  /// Reconciles device reminders with the given set of currently-active
  /// alert rows: cancels reminders for anything no longer active, and
  /// (re)schedules a daily reminder for each row still active. Safe to call
  /// repeatedly — every run fully replaces the previous schedule.
  Future<void> sync(List<NotificationRow> active) async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
      final scheduledDate = _nextReminderTime();
      for (final row in active) {
        await _plugin.zonedSchedule(
          _idFor(row.id),
          row.title,
          row.message,
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: row.link,
        );
      }
    } catch (e, st) {
      debugPrint('DailyReminderService.sync() failed: $e\n$st');
    }
  }

  /// Cancels a single reminder immediately — used when the farmer
  /// dismisses an alert, so it doesn't fire again the next morning even if
  /// the notifications list isn't re-fetched (and re-synced) before then.
  Future<void> cancelOne(String notificationId) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_idFor(notificationId));
    } catch (e, st) {
      debugPrint('DailyReminderService.cancelOne() failed: $e\n$st');
    }
  }
}
