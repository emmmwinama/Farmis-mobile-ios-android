import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../../models/sync_queue_item.dart';

class SyncQueueService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'agrivault.sync.queue';
  static Future<void> _pendingOperation = Future.value();

  Future<List<SyncQueueItem>> load() async {
    final raw = await _storage.read(key: _key);
    return SyncQueueItem.decodeList(raw);
  }

  Future<void> save(List<SyncQueueItem> items) {
    return _storage.write(key: _key, value: SyncQueueItem.encodeList(items));
  }

  Future<List<SyncQueueItem>> enqueue({
    required String type,
    required String method,
    required String path,
    required Map<String, dynamic> payload,
  }) =>
      _serialized(() async {
        final queue = await load();
        final now = DateTime.now();
        final suppliedClientId = payload['clientId'];
        final clientId =
            suppliedClientId is String && suppliedClientId.trim().isNotEmpty
                ? suppliedClientId
                : '${type}_${now.microsecondsSinceEpoch}';

        if (queue.any((item) => item.clientId == clientId)) return queue;

        final item = SyncQueueItem(
          id: '${now.microsecondsSinceEpoch}',
          clientId: clientId,
          type: type,
          method: method,
          path: path,
          payload: {...payload, 'clientId': clientId},
          status: SyncQueueStatus.queued,
          createdAt: now,
        );
        final next = [item, ...queue];
        await save(next);
        return next;
      });

  Future<List<SyncQueueItem>> syncNow() => _serialized(() async {
        final queue = await load();
        if (queue.isEmpty) return queue;

        final remaining = <SyncQueueItem>[];
        for (final item in queue) {
          if (item.status == SyncQueueStatus.synced) continue;

          try {
            await _replay(item);
          } catch (error) {
            remaining.add(item.copyWith(
              status: SyncQueueStatus.failed,
              error: error.toString(),
            ));
          }
        }
        await save(remaining);
        return remaining;
      });

  /// Replays a queued item against its own stored endpoint, rather than the
  /// batch `/mobile/sync` endpoint (which expects a different wire format
  /// and only understands a fixed whitelist of item types).
  Future<void> _replay(SyncQueueItem item) async {
    switch (item.method.toUpperCase()) {
      case 'POST':
        await ApiClient.post(item.path, item.payload);
        break;
      case 'PATCH':
        await ApiClient.patch(item.path, item.payload);
        break;
      case 'DELETE':
        await ApiClient.delete(item.path);
        break;
      default:
        throw StateError('Unsupported sync method: ${item.method}');
    }
  }

  Future<List<SyncQueueItem>> delete(String id) => _serialized(() async {
        final next = (await load()).where((item) => item.id != id).toList();
        await save(next);
        return next;
      });

  Future<T> _serialized<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _pendingOperation = _pendingOperation.then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}
