import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/api/api_error.dart';
import 'package:farmio_mobile/core/sync/offline_fallback.dart';
import 'package:farmio_mobile/core/sync/offline_queued_exception.dart';
import 'package:farmio_mobile/core/sync/sync_queue_provider.dart';

import '../support/fake_sync_queue_service.dart';

void main() {
  late FakeSyncQueueService service;
  late SyncQueueNotifier notifier;

  setUp(() {
    service = FakeSyncQueueService();
    notifier = SyncQueueNotifier(service);
  });

  test('returns the request result on success without touching the queue',
      () async {
    final result = await withOfflineFallback<int>(
      request: () async => 42,
      syncQueue: notifier,
      type: 'test',
      path: '/mobile/test',
      payload: const {'a': 1},
    );

    expect(result, 42);
    expect(service.items, isEmpty);
  });

  test('queues the payload and throws OfflineQueuedException on a network error',
      () async {
    final networkError = DioException(
      requestOptions: RequestOptions(path: '/mobile/test'),
      error: const ApiError(type: ApiErrorType.network, message: 'Offline'),
    );

    await expectLater(
      () => withOfflineFallback<int>(
        request: () async => throw networkError,
        syncQueue: notifier,
        type: 'test',
        path: '/mobile/test',
        payload: const {'a': 1},
      ),
      throwsA(isA<OfflineQueuedException>()),
    );

    expect(service.items, hasLength(1));
    expect(service.items.single.type, 'test');
    // The shared notifier's in-memory state must reflect the queued item too
    // (this is the bug the finance/activities/yields repos used to have).
    expect(notifier.state.value, hasLength(1));
  });

  test('rethrows non-network Dio errors without queuing anything', () async {
    final validationError = DioException(
      requestOptions: RequestOptions(path: '/mobile/test'),
      error: const ApiError(type: ApiErrorType.validation, message: 'Bad input'),
    );

    await expectLater(
      () => withOfflineFallback<int>(
        request: () async => throw validationError,
        syncQueue: notifier,
        type: 'test',
        path: '/mobile/test',
        payload: const {'a': 1},
      ),
      throwsA(same(validationError)),
    );

    expect(service.items, isEmpty);
  });
}
