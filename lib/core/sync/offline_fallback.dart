import 'package:dio/dio.dart';
import '../api/api_error.dart';
import 'offline_queued_exception.dart';
import 'sync_queue_provider.dart';

/// Runs [request]; if it fails with a network error, queues it via
/// [syncQueue] (updating the shared in-memory queue state) and throws
/// [OfflineQueuedException] instead of the original error.
Future<T> withOfflineFallback<T>({
  required Future<T> Function() request,
  required SyncQueueNotifier syncQueue,
  required String type,
  required String path,
  required Map<String, dynamic> payload,
  String method = 'POST',
}) async {
  try {
    return await request();
  } on DioException catch (error) {
    final apiError = error.error;
    if (apiError is! ApiError || apiError.type != ApiErrorType.network) {
      rethrow;
    }
    await syncQueue.enqueue(
      type: type,
      method: method,
      path: path,
      payload: payload,
    );
    throw const OfflineQueuedException();
  }
}
