import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/api/api_client.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/core/sync/auto_sync_service.dart';
import '../support/fake_mobile_api.dart';

/// A minimal fake for `GET /api/mobile/sync` — doesn't fit
/// [FakeRestResource]'s create/update/delete collection shape, so it's a
/// one-off here rather than added to the shared fake_mobile_api.dart.
class _FakeSyncResource implements FakeApiResource {
  @override
  final basePath = '/api/mobile/sync';

  @override
  Response<dynamic> handle(RequestOptions options) {
    if (options.method == 'GET') {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'data': {'cursor': '2026-01-01 00:00:00', 'changes': <String, dynamic>{}}
        },
      );
    }
    throw StateError('_FakeSyncResource: unhandled request ${options.method} ${options.path}');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  test('syncNow pushes nothing pending and pulls an empty changeset cleanly', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      apiClientProvider.overrideWithValue(fakeApiDio([_FakeSyncResource()])),
    ]);
    addTearDown(() {
      container.dispose();
      db.close();
    });

    final notifier = container.read(autoSyncProvider.notifier);
    expect(notifier.state.status, SyncStatus.disabled);

    await notifier.syncNow();

    expect(notifier.state.status, SyncStatus.synced);
    expect(notifier.state.errorMessage, isNull);
  });

  test('syncNow surfaces a failure as SyncStatus.error', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      // No resources registered — any request (including the GET /sync
      // pullChanges always makes) rejects, simulating offline/unreachable.
      apiClientProvider.overrideWithValue(fakeApiDio([])),
    ]);
    addTearDown(() {
      container.dispose();
      db.close();
    });

    final notifier = container.read(autoSyncProvider.notifier);
    await notifier.syncNow();

    expect(notifier.state.status, SyncStatus.error);
    expect(notifier.state.errorMessage, isNotNull);
  });
}
