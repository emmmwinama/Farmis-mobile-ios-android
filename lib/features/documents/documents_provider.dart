import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'documents_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/farm_document.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>(
  (ref) => DocumentsRepository(ref.read(databaseProvider)),
);

final documentsProvider =
    FutureProvider.autoDispose<List<FarmDocument>>((ref) {
  return ref.read(documentsRepositoryProvider).getDocuments();
});
