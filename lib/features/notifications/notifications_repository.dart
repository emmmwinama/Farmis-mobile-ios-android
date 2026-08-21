import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../core/notifications/daily_reminder_service.dart';
import '../../features/crops/crops_repository.dart';
import '../../features/inventory/inventory_repository.dart';
import '../../models/app_notification.dart';
import '../../models/crop_timeline.dart';
import '../../shared/agronomy/crop_timeline_catalog.dart';

class NotificationsRepository {
  NotificationsRepository(this._db, {DailyReminderService? reminders})
      : _crops = CropsRepository(_db),
        _inventory = InventoryRepository(_db),
        _reminders = reminders ?? DailyReminderService();

  final AppDatabase _db;
  final CropsRepository _crops;
  final InventoryRepository _inventory;
  // Uninitialized (and therefore a no-op) unless something calls
  // DailyReminderService.initialize() — main.dart does this once at app
  // startup; repository tests never do, so they never touch a platform
  // channel that doesn't exist in the test environment.
  final DailyReminderService _reminders;

  Future<NotificationsData> getNotifications() async {
    await _generateNotifications();

    final rows = await (_db.select(_db.notifications)
          ..where((t) => t.dismissed.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(50))
        .get();
    final unread = rows.where((r) => !r.isRead).length;

    await _reminders.sync(rows);

    return NotificationsData.fromJson({
      'notifications': rows.map((r) => r.toJson()).toList(),
      'unread': unread,
    });
  }

  Future<void> markAllRead() async {
    await (_db.update(_db.notifications)
          ..where((t) => t.isRead.equals(false)))
        .write(const NotificationsCompanion(isRead: Value(true)));
  }

  Future<void> markRead(String id) async {
    await (_db.update(_db.notifications)..where((t) => t.id.equals(id)))
        .write(const NotificationsCompanion(isRead: Value(true)));
  }

  /// A deliberate user dismissal ("cancel this reminder") — sets [dismissed]
  /// rather than deleting the row, so [_generateNotifications]'s dedupe
  /// check (which looks at all existing rows regardless of dismissed/read
  /// state) still sees it and won't just recreate the same alert the next
  /// time notifications refresh, as long as the underlying condition is
  /// still true. Once that condition genuinely resolves, the row is hard-
  /// deleted by the stale-notification purge below like any other.
  Future<void> dismissNotification(String id) async {
    await (_db.update(_db.notifications)..where((t) => t.id.equals(id)))
        .write(const NotificationsCompanion(dismissed: Value(true)));
    // Cancel the device reminder immediately rather than waiting for the
    // next getNotifications() call's sync() to catch up — otherwise a
    // dismissal made just before closing the app could still fire once
    // more tomorrow morning.
    await _reminders.cancelOne(id);
  }

  /// Ports the backend's `generateNotifications()` — it used to run as a
  /// server-side check on every notifications fetch; here it runs the same
  /// way, on-demand, against the local database instead of a cron-ish job.
  Future<void> _generateNotifications() async {
    final existing = await _db.select(_db.notifications).get();
    bool existsByTitle(String type, String title) => existing
        .any((n) => n.type == type && n.title == title);
    bool existsByTitleContains(String type, String needle) => existing.any(
        (n) => n.type == type && n.title.toLowerCase().contains(needle.toLowerCase()));
    // Mirrors the backend's own dedupe key for `harvest_due`, which checks
    // only type+link (not the crop-specific title) — so only ever one
    // harvest-due notification exists at a time across all crops, a quirk
    // preserved here rather than "fixed" during the port.
    var harvestDueExists =
        existing.any((n) => n.type == 'harvest_due' && n.link == '/crops');

    final toInsert = <NotificationsCompanion>[];
    // Tracks which crop_activity_due/no_activity titles are still legitimate
    // right now, so stale ones — e.g. a crop that's since been harvested —
    // can be purged below instead of lingering forever (they're only ever
    // inserted, never otherwise cleaned up).
    final stillDueTitles = <String>{};
    final stillNoActivityTitles = <String>{};
    var anyHarvestStillDue = false;

    // Only genuinely still-growing crops should generate activity/harvest
    // alerts — getCrops(archived: 'false') only excludes literal 'Archived',
    // which misses crops already marked 'Harvested' (still shown in crop
    // lists, but done needing attention).
    final crops = (await _crops.getCrops(archived: 'false'))
        .where((c) => c.status == 'Active');
    for (final crop in crops) {
      final detail = await _crops.getCrop(crop.id);
      // Field name (not just crop type) makes the title unique per planting
      // — without it, two Maize plots on different fields would collide
      // under the same "Maize: Weeding" title and only ever generate one
      // alert between them, silently dropping the other field's reminder.
      final cropLabel = '${detail.cropTypeName} at ${detail.fieldName}';
      final cropLink = '/crops/${detail.id}';

      final plan = CropTimelineCatalog.buildPlan(crop: detail);
      final dueSteps = plan.entries
          .where((e) =>
              e.status == CropTimelineStatus.due ||
              e.status == CropTimelineStatus.overdue)
          .take(2);
      for (final entry in dueSteps) {
        final title = '$cropLabel: ${entry.step.title}';
        stillDueTitles.add(title);
        if (existsByTitle('crop_activity_due', title)) continue;
        final isOverdue = entry.status == CropTimelineStatus.overdue;
        toInsert.add(NotificationsCompanion.insert(
          id: newId(),
          type: 'crop_activity_due',
          title: title,
          message:
              '${entry.step.title} is ${isOverdue ? 'overdue' : 'generally due'} for ${detail.cropTypeName} (${detail.variety}) at ${detail.fieldName} — it hasn\'t been recorded for this crop yet. ${entry.step.recommendation}',
          link: Value(cropLink),
          createdAt: DateTime.now(),
        ));
      }

      if (detail.isDueSoon) {
        anyHarvestStillDue = true;
        if (!harvestDueExists) {
          final days = detail.daysToHarvest;
          toInsert.add(NotificationsCompanion.insert(
            id: newId(),
            type: 'harvest_due',
            title: '${detail.cropTypeName} harvest due',
            message:
                '${detail.cropTypeName} (${detail.variety}) at ${detail.fieldName} is due for harvest ${days == 0 ? 'today' : 'in $days day${days == 1 ? '' : 's'}'}',
            link: Value(cropLink),
            createdAt: DateTime.now(),
          ));
          harvestDueExists = true;
        }
      }

      if (detail.activities.isNotEmpty) {
        final lastActivity = detail.activities
            .reduce((a, b) => a.date.isAfter(b.date) ? a : b);
        final daysSince = DateTime.now().difference(lastActivity.date).inDays;
        if (daysSince >= 21) {
          final title = 'No activity: $cropLabel';
          stillNoActivityTitles.add(title);
          if (!existsByTitle('no_activity', title)) {
            // Name the specific timeline stage this silence has left
            // unrecorded, when the crop's own timeline has one due/overdue
            // — falls back to the generic silence message only when the
            // crop is between stages (nothing currently due).
            final missingStep = dueSteps.isNotEmpty ? dueSteps.first.step.title : null;
            toInsert.add(NotificationsCompanion.insert(
              id: newId(),
              type: 'no_activity',
              title: title,
              message: missingStep != null
                  ? '$missingStep hasn\'t been recorded for ${detail.cropTypeName} (${detail.variety}) at ${detail.fieldName} — no activity logged in $daysSince days.'
                  : 'No activities logged for ${detail.cropTypeName} (${detail.variety}) at ${detail.fieldName} in $daysSince days.',
              link: Value(cropLink),
              createdAt: DateTime.now(),
            ));
          }
        }
      }
    }

    // Purge stale auto-generated notifications: a crop that's since been
    // harvested/archived, had its overdue step finally logged, or resumed
    // activity no longer belongs on this list, and these three types are
    // never otherwise cleaned up once inserted.
    final staleIds = existing
        .where((n) =>
            (n.type == 'crop_activity_due' && !stillDueTitles.contains(n.title)) ||
            (n.type == 'no_activity' && !stillNoActivityTitles.contains(n.title)) ||
            (n.type == 'harvest_due' && n.link == '/crops' && !anyHarvestStillDue))
        .map((n) => n.id)
        .toList();
    if (staleIds.isNotEmpty) {
      await (_db.delete(_db.notifications)..where((t) => t.id.isIn(staleIds))).go();
    }

    final items = await _inventory.getItems();
    for (final item in items) {
      final totalSold =
          item.sales.fold<double>(0, (s, sale) => s + sale.quantitySold);
      final originalQty = item.quantity + totalSold;
      final remainingFraction =
          originalQty > 0 ? item.quantity / originalQty : 0.0;
      if (originalQty > 0 && remainingFraction < 0.2 && item.quantity > 0) {
        if (existsByTitleContains('low_inventory', item.name)) continue;
        toInsert.add(NotificationsCompanion.insert(
          id: newId(),
          type: 'low_inventory',
          title: 'Low inventory: ${item.name}',
          message:
              'Only ${item.quantity} ${item.unit} of ${item.name} remaining (${(remainingFraction * 100).round()}% left)',
          link: const Value('/inventory'),
          createdAt: DateTime.now(),
        ));
      }
    }

    for (final companion in toInsert) {
      await _db.into(_db.notifications).insert(companion);
    }
  }
}
