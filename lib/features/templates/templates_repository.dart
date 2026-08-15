import '../../core/api/api_client.dart';
import '../../models/seasonal_template.dart';

class TemplatesRepository {
  Future<List<SeasonalTemplate>> getTemplates() async {
    final response = await ApiClient.get('/mobile/templates');
    final data = response.data as Map<String, dynamic>;
    return (data['templates'] as List)
        .map((e) => SeasonalTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
