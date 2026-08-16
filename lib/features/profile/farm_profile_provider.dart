import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'farm_profile_repository.dart';
import '../../core/db/app_database.dart';
import '../../core/db/database_provider.dart';

final farmProfileRepositoryProvider = Provider<FarmProfileRepository>(
  (ref) => FarmProfileRepository(ref.read(databaseProvider)),
);

final farmProfileProvider = FutureProvider.autoDispose<FarmProfileData?>((ref) {
  return ref.read(farmProfileRepositoryProvider).getProfile();
});
