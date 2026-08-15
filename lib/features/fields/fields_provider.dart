import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fields_repository.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/field.dart';
import '../../models/field_detail.dart';

final fieldsRepositoryProvider = Provider<FieldsRepository>(
      (ref) => FieldsRepository(ref.read(syncQueueProvider.notifier)),
);

final fieldsProvider = FutureProvider.autoDispose<List<FieldModel>>((ref) {
  return ref.read(fieldsRepositoryProvider).getFields();
});

final fieldDetailProvider =
FutureProvider.autoDispose.family<FieldDetail, String>((ref, id) {
  return ref.read(fieldsRepositoryProvider).getField(id);
});