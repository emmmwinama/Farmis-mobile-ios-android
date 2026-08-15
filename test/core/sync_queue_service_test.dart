import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/api/api_client.dart';
import 'package:farmio_mobile/core/sync/sync_queue_service.dart';
import 'package:farmio_mobile/models/sync_queue_item.dart';

/// Records every request it receives and returns a canned 200 response,
/// so ApiClient calls can be verified without touching the network.
class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _InMemorySyncQueueService extends SyncQueueService {
  List<SyncQueueItem> items;
  _InMemorySyncQueueService(this.items);

  @override
  Future<List<SyncQueueItem>> load() async => List.unmodifiable(items);

  @override
  Future<void> save(List<SyncQueueItem> next) async {
    items = next;
  }
}

SyncQueueItem _item({
  required String id,
  required String method,
  required String path,
  required Map<String, dynamic> payload,
}) =>
    SyncQueueItem(
      id: id,
      clientId: id,
      type: 'test',
      method: method,
      path: path,
      payload: payload,
      status: SyncQueueStatus.queued,
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _RecordingAdapter adapter;

  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://test.local/api');
    // ApiClient's request interceptor reads the auth token via
    // flutter_secure_storage, which has no platform channel in unit tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => call.method == 'read' ? null : null,
    );
  });

  setUp(() {
    adapter = _RecordingAdapter();
    ApiClient.instance.httpClientAdapter = adapter;
  });

  tearDown(ApiClient.reset);

  test('replays each queued item against its own stored method/path/payload',
      () async {
    final service = _InMemorySyncQueueService([
      _item(
        id: '1',
        method: 'POST',
        path: '/mobile/crops',
        payload: const {'variety': 'SC403'},
      ),
      _item(
        id: '2',
        method: 'DELETE',
        path: '/mobile/crops/2',
        payload: const {},
      ),
    ]);

    final result = await service.syncNow();

    expect(adapter.requests, hasLength(2));
    expect(adapter.requests[0].path, '/mobile/crops');
    expect(adapter.requests[0].method, 'POST');
    expect(adapter.requests[1].path, '/mobile/crops/2');
    expect(adapter.requests[1].method, 'DELETE');
    expect(result, isEmpty);
    expect(service.items, isEmpty);
  });

  test('never calls the old batch /mobile/sync endpoint', () async {
    final service = _InMemorySyncQueueService([
      _item(
        id: '1',
        method: 'POST',
        path: '/mobile/finance',
        payload: const {'amount': '10'},
      ),
    ]);

    await service.syncNow();

    expect(
        adapter.requests.map((r) => r.path), isNot(contains('/mobile/sync')));
  });

  test('marks an item failed (without touching others) when its replay throws',
      () async {
    final service = _InMemorySyncQueueService([
      _item(id: 'skip', method: 'BOGUS', path: '/mobile/x', payload: const {}),
      _item(
          id: 'ok', method: 'POST', path: '/mobile/finance', payload: const {}),
    ]);

    final result = await service.syncNow();

    expect(result.firstWhere((i) => i.id == 'skip').status,
        SyncQueueStatus.failed);
    expect(result.where((i) => i.id == 'ok'), isEmpty);
  });

  test('already-synced items are pruned without being replayed', () async {
    final synced = _item(
      id: '1',
      method: 'POST',
      path: '/mobile/finance',
      payload: const {},
    ).copyWith(status: SyncQueueStatus.synced);
    final service = _InMemorySyncQueueService([synced]);

    final result = await service.syncNow();

    expect(adapter.requests, isEmpty);
    expect(result, isEmpty);
  });

  test('serializes concurrent enqueues so neither queued write is lost',
      () async {
    final service = _InMemorySyncQueueService([]);

    await Future.wait([
      service.enqueue(
        type: 'finance',
        method: 'POST',
        path: '/mobile/finance',
        payload: const {'clientId': 'finance-1'},
      ),
      service.enqueue(
        type: 'activity',
        method: 'POST',
        path: '/mobile/activities',
        payload: const {'clientId': 'activity-1'},
      ),
    ]);

    expect(service.items, hasLength(2));
    expect(
      service.items.map((item) => item.clientId),
      containsAll(['finance-1', 'activity-1']),
    );
  });
}
