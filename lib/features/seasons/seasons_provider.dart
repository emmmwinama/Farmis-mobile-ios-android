import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'seasons_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/season.dart';

final seasonsRepositoryProvider = Provider<SeasonsRepository>(
  (ref) => SeasonsRepository(ref.read(databaseProvider)),
);

final seasonsProvider = FutureProvider.autoDispose<SeasonsData>((ref) {
  return ref.read(seasonsRepositoryProvider).getSeasons();
});

class SeasonComparePair {
  final String a;
  final String b;
  const SeasonComparePair(this.a, this.b);

  @override
  bool operator ==(Object other) =>
      other is SeasonComparePair && other.a == a && other.b == b;

  @override
  int get hashCode => Object.hash(a, b);
}

final seasonCompareProvider = FutureProvider.autoDispose
    .family<SeasonCompareData, SeasonComparePair>((ref, pair) {
  return ref.read(seasonsRepositoryProvider).compareSeasons(pair.a, pair.b);
});
