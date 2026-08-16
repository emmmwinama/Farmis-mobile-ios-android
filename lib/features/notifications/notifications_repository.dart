import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../features/crops/crops_repository.dart';
import '../../features/inventory/inventory_repository.dart';
import '../../models/app_notification.dart';
import '../../models/crop_timeline.dart';
import '../../shared/agronomy/crop_timeline_catalog.dart';

class NotificationsRepository {
  NotificationsRepository(this._db)
      : _crops = CropsRepository(_db),
        _inventory = InventoryRepository(_db);

  final AppDatabase _db;
  final CropsRepository _crops;
  final InventoryRepository _inventory;

  Future<NotificationsData> getNotifications() async {
    await _generateNotifications();

    final rows = await (_db.select(_db.notifications)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(50))
        .get();
    final unread = rows.where((r) => !r.isRead).length;

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

    final crops = await _crops.getCrops(archived: 'false');
    for (final crop in crops) {
      final detail = await _crops.getCrop(crop.id);

      final plan = CropTimelineCatalog.buildPlan(crop: detail);
      final dueSteps = plan.entries
          .where((e) =>
              e.status == CropTimelineStatus.due ||
              e.status == CropTimelineStatus.overdue)
          .take(2);
      for (final entry in dueSteps) {
        final title = '${detail.cropTypeName}: ${entry.step.title}';
        if (existsByTitle('crop_activity_due', title)) continue;
        final isOverdue = entry.status == CropTimelineStatus.overdue;
        toInsert.add(NotificationsCompanion.insert(
          id: newId(),
          type: 'crop_activity_due',
          title: title,
          message:
              '${entry.step.title} is ${isOverdue ? 'overdue' : 'generally due'} for ${detail.cropTypeName} (${detail.variety}). ${entry.step.recommendation}',
          link: const Value('/activities'),
          createdAt: DateTime.now(),
        ));
      }

      if (detail.isDueSoon && !harvestDueExists) {
        final days = detail.daysToHarvest;
        toInsert.add(NotificationsCompanion.insert(
          id: newId(),
          type: 'harvest_due',
          title: '${detail.cropTypeName} harvest due',
          message:
              '${detail.cropTypeName} (${detail.variety}) is due for harvest ${days == 0 ? 'today' : 'in $days day${days == 1 ? '' : 's'}'}',
          link: const Value('/crops'),
          createdAt: DateTime.now(),
        ));
        harvestDueExists = true;
      }

      if (detail.activities.isNotEmpty) {
        final lastActivity = detail.activities
            .reduce((a, b) => a.date.isAfter(b.date) ? a : b);
        final daysSince = DateTime.now().difference(lastActivity.date).inDays;
        if (daysSince >= 21 &&
            !existsByTitleContains('no_activity', detail.cropTypeName)) {
          toInsert.add(NotificationsCompanion.insert(
            id: newId(),
            type: 'no_activity',
            title: 'No activity: ${detail.cropTypeName}',
            message:
                'No activities logged for ${detail.cropTypeName} (${detail.variety}) in $daysSince days',
            link: const Value('/activities'),
            createdAt: DateTime.now(),
          ));
        }
      }
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
