import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'team_repository.dart';
import '../../models/team_member.dart';

final teamRepositoryProvider = Provider<TeamRepository>(
  (_) => TeamRepository(),
);

final teamProvider = FutureProvider.autoDispose<TeamData>((ref) {
  return ref.read(teamRepositoryProvider).getTeam();
});
