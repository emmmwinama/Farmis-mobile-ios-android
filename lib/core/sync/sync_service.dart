import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../auth/secure_storage.dart';
import '../db/app_database.dart';
import '../db/db_utils.dart';

/// Implements docs/MOBILE-API.md §8's two-way sync against Ulimi's mobile
/// API — `POST /sync` flushes locally-queued offline writes (the resources
/// listed in §8.1: activities today, more to follow the same pattern),
/// `GET /sync` pulls whatever changed elsewhere (the web app, another
/// device) since the last call.
///
/// Deliberately scoped to just the resources that stay local-first (see
/// each repository's own doc comment for why) — fields/crops/employees/etc.
/// already keep themselves current by re-pulling their own full collection
/// on every read (see e.g. fields_repository.dart), so routing them through
/// this cursor-based pull too would just be a second mechanism racing the
/// first over the same rows.
class SyncService {
  SyncService(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  Future<void> pushQueued() async {
    final pendingActivities =
        await (_db.select(_db.activities)..where((t) => t.pendingSync.equals(true))).get();

    if (pendingActivities.isEmpty) return;

    final body = <String, dynamic>{
      'activities': pendingActivities.map((a) => {
            'client_id': a.id,
            'field_id': a.fieldId,
            'activity_type': a.activityType,
            'date': a.date.toIso8601String().split('T').first,
            if (a.notes != null) 'notes': a.notes,
            if (a.cropFieldId != null) 'crop_field_id': a.cropFieldId,
          }).toList(),
    };

    final res = await _dio.post('/api/mobile/sync', data: body);
    final results = (res.data as Map)['results'] as Map<String, dynamic>? ?? {};
    final activityResults = results['activities'] as List? ?? const [];

    for (final raw in activityResults) {
      final result = raw as Map<String, dynamic>;
      final clientId = result['client_id'] as String?;
      if (clientId == null) continue;

      if (result['ok'] == true) {
        await (_db.update(_db.activities)..where((t) => t.id.equals(clientId))).write(
          ActivitiesCompanion(
            serverId: Value(result['id'] as String),
            pendingSync: const Value(false),
          ),
        );
      }
      // ok:false rows are left pendingSync — they'll retry on the next push
      // once whatever the per-item `errors` flagged is fixed (see docs
      // §8.1); this pass doesn't yet surface that error to the UI.
    }
  }

  Future<void> pullChanges() async {
    final cursor = await SecureStorage.getSyncCursor();

    final res = await _dio.get(
      '/api/mobile/sync',
      queryParameters: {if (cursor != null) 'since': cursor},
    );
    final data = (res.data as Map)['data'] as Map<String, dynamic>;
    final changes = data['changes'] as Map<String, dynamic>? ?? {};

    final activityChanges = changes['activities'] as Map<String, dynamic>?;
    if (activityChanges != null) {
      for (final raw in (activityChanges['upserts'] as List? ?? const [])) {
        await _upsertActivityFromServer(raw as Map<String, dynamic>);
      }
      for (final deletedServerId in (activityChanges['deletes'] as List? ?? const [])) {
        await (_db.delete(_db.activities)..where((t) => t.serverId.equals(deletedServerId as String))).go();
      }
    }

    final newCursor = data['cursor'] as String?;
    if (newCursor != null) await SecureStorage.saveSyncCursor(newCursor);
  }

  Future<void> _upsertActivityFromServer(Map<String, dynamic> row) async {
    final serverId = row['id'] as String;
    final existing =
        await (_db.select(_db.activities)..where((t) => t.serverId.equals(serverId))).getSingleOrNull();

    await _db.into(_db.activities).insertOnConflictUpdate(ActivitiesCompanion.insert(
          id: existing?.id ?? newId(),
          activityType: row['activity_type'] as String,
          date: DateTime.parse(row['date'] as String),
          fieldId: row['field_id'] as String,
          createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
          notes: Value(asStringOrNull(row['notes'])),
          cropFieldId: Value(asStringOrNull(row['crop_field_id'])),
          serverId: Value(serverId),
          pendingSync: const Value(false),
        ));
  }
}
