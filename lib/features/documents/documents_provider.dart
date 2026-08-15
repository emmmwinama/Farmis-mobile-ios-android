import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'documents_repository.dart';
import '../../models/farm_document.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>(
  (_) => DocumentsRepository(),
);

final documentsProvider =
    FutureProvider.autoDispose<List<FarmDocument>>((ref) {
  return ref.read(documentsRepositoryProvider).getDocuments();
});
