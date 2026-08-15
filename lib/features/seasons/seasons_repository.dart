import '../../core/api/api_client.dart';
import '../../models/season.dart';

class SeasonsRepository {
  Future<SeasonsData> getSeasons({String? season}) async {
    final response = await ApiClient.get(
      '/mobile/seasons',
      params: season != null ? {'season': season} : null,
    );
    return SeasonsData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SeasonCompareData> compareSeasons(String a, String b) async {
    final response = await ApiClient.get(
      '/mobile/seasons/compare',
      params: {'a': a, 'b': b},
    );
    return SeasonCompareData.fromJson(response.data as Map<String, dynamic>);
  }
}
