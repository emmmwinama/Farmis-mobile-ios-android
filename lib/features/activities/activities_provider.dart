import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'activities_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/activity.dart';
import '../../models/activity_detail.dart';

final activitiesRepositoryProvider = Provider<ActivitiesRepository>(
      (ref) => ActivitiesRepository(ref.read(databaseProvider)),
);

final activitiesDataProvider =
FutureProvider.autoDispose<ActivitiesData>((ref) {
  return ref.read(activitiesRepositoryProvider).getActivities();
});

final activityDetailProvider =
FutureProvider.autoDispose.family<ActivityDetail, String>((ref, id) {
  return ref.read(activitiesRepositoryProvider).getActivity(id);
});