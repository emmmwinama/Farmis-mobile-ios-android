import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fields_repository.dart';
import '../../core/api/api_client.dart';
import '../../core/db/database_provider.dart';
import '../../models/field.dart';
import '../../models/field_detail.dart';

final fieldsRepositoryProvider = Provider<FieldsRepository>(
      (ref) => FieldsRepository(ref.read(databaseProvider), ref.read(apiClientProvider)),
);

final fieldsProvider = FutureProvider.autoDispose<List<FieldModel>>((ref) {
  return ref.read(fieldsRepositoryProvider).getFields();
});

final fieldDetailProvider =
FutureProvider.autoDispose.family<FieldDetail, String>((ref, id) {
  return ref.read(fieldsRepositoryProvider).getField(id);
});