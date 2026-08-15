import '../../core/api/api_client.dart';
import '../../models/farm_document.dart';

class DocumentsRepository {
  Future<List<FarmDocument>> getDocuments({String? type}) async {
    final response = await ApiClient.get(
      '/mobile/documents',
      params: type != null ? {'type': type} : null,
    );
    final data = response.data as Map<String, dynamic>;
    return (data['documents'] as List)
        .map((e) => FarmDocument.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Documents aren't offline-queued: a base64-encoded photo can run into
  /// several MB, which doesn't belong in the secure-storage-backed sync
  /// queue (a single blob shared by every queued record). Uploads require
  /// connectivity.
  Future<void> uploadDocument(Map<String, dynamic> data) async {
    await ApiClient.post('/mobile/documents', data);
  }
}
