import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/db_utils.dart';
import 'package:farmio_mobile/core/sync/sync_service.dart';
import '../support/fake_mobile_api.dart';

/// A fake `/api/mobile/sync` that actually models push+pull, unlike
/// auto_sync_service_test.dart's trivial always-empty one — records what
/// gets pushed and lets a test queue up what the next pull should return.
class _FakeSyncResource implements FakeApiResource {
  @override
  final basePath = '/api/mobile/sync';

  final pushedBatches = <Map<String, dynamic>>[];
  Map<String, dynamic> nextPullChanges = const {};
  String nextCursor = '2026-01-01 00:00:00';
  int _idSeq = 0;

  @override
  Response<dynamic> handle(RequestOptions options) {
    if (options.method == 'GET') {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'data': {'cursor': nextCursor, 'changes': nextPullChanges}
        },
      );
    }
    if (options.method == 'POST') {
      final body = Map<String, dynamic>.from(options.data as Map);
      pushedBatches.add(body);
      final activities = (body['activities'] as List? ?? const [])
          .map((raw) => {'client_id': (raw as Map)['client_id'], 'ok': true, 'id': 'srv-${_idSeq++}'})
          .toList();
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'results': {'activities': activities}
        },
      );
    }
    throw StateError('_FakeSyncResource: unhandled request ${options.method} ${options.path}');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // SyncService reads/writes the sync cursor via SecureStorage, which needs
  // its platform channel mocked in a plain `test()` — same pattern as
  // secure_storage_test.dart. A `read` call returning null models "no
  // cursor yet" (first sync), which every test here wants by default.
  const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  late AppDatabase db;
  late _FakeSyncResource fakeSync;
  late SyncService service;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async => null);
    db = AppDatabase(NativeDatabase.memory());
    fakeSync = _FakeSyncResource();
    service = SyncService(db, fakeApiDio([fakeSync]));
  });

  tearDown(() async {
    await db.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  Future<String> seedField() async {
    final id = newId();
    await db.into(db.fields).insert(FieldsCompanion.insert(
          id: id,
          name: 'North Field',
          totalArea: 2,
          cultivatableArea: 1.8,
          soilType: 'Loam',
          createdAt: DateTime.now(),
        ));
    return id;
  }

  test('pushQueued sends every pendingSync activity and marks it synced', () async {
    final fieldId = await seedField();
    final activityId = newId();
    await db.into(db.activities).insert(ActivitiesCompanion.insert(
          id: activityId,
          activityType: 'Weeding',
          date: DateTime(2026, 9, 10),
          fieldId: fieldId,
          createdAt: DateTime.now(),
        ));

    await service.pushQueued();

    expect(fakeSync.pushedBatches, hasLength(1));
    expect(fakeSync.pushedBatches.first['activities'], hasLength(1));
    expect(fakeSync.pushedBatches.first['activities'][0]['client_id'], activityId);

    final row = await (db.select(db.activities)..where((t) => t.id.equals(activityId))).getSingle();
    expect(row.pendingSync, isFalse);
    expect(row.serverId, isNotNull);
  });

  test('pushQueued is a no-op when nothing is pending', () async {
    await service.pushQueued();
    expect(fakeSync.pushedBatches, isEmpty);
  });

  test('pullChanges upserts a brand-new row from the server into a fresh local row', () async {
    fakeSync.nextPullChanges = {
      'activities': {
        'upserts': [
          {
            'id': 'srv-remote-1',
            'activity_type': 'Spraying',
            'date': '2026-09-12',
            'field_id': 'some-field',
            'notes': 'From the web app',
          }
        ],
        'deletes': [],
      },
    };

    await service.pullChanges();

    final rows = await db.select(db.activities).get();
    expect(rows, hasLength(1));
    expect(rows.first.serverId, 'srv-remote-1');
    expect(rows.first.activityType, 'Spraying');
    expect(rows.first.pendingSync, isFalse);
  });

  test('pullChanges updates the existing local row instead of duplicating it', () async {
    final fieldId = await seedField();
    final activityId = newId();
    await db.into(db.activities).insert(ActivitiesCompanion.insert(
          id: activityId,
          activityType: 'Weeding',
          date: DateTime(2026, 9, 10),
          fieldId: fieldId,
          createdAt: DateTime.now(),
        ));
    await service.pushQueued();
    final synced = await (db.select(db.activities)..where((t) => t.id.equals(activityId))).getSingle();

    fakeSync.nextPullChanges = {
      'activities': {
        'upserts': [
          {
            'id': synced.serverId,
            'activity_type': 'Weeding (edited on web)',
            'date': '2026-09-10',
            'field_id': fieldId,
          }
        ],
        'deletes': [],
      },
    };
    await service.pullChanges();

    final rows = await db.select(db.activities).get();
    expect(rows, hasLength(1));
    expect(rows.first.id, activityId); // local id unchanged, not duplicated
    expect(rows.first.activityType, 'Weeding (edited on web)');
  });

  test('pullChanges removes a row the server reports deleted', () async {
    fakeSync.nextPullChanges = {
      'activities': {
        'upserts': [
          {'id': 'srv-to-delete', 'activity_type': 'Weeding', 'date': '2026-09-10', 'field_id': 'f1'}
        ],
        'deletes': [],
      },
    };
    await service.pullChanges();
    expect(await db.select(db.activities).get(), hasLength(1));

    fakeSync.nextPullChanges = {
      'activities': {'upserts': [], 'deletes': ['srv-to-delete']},
    };
    await service.pullChanges();

    expect(await db.select(db.activities).get(), isEmpty);
  });
}
