import '../../core/api/api_client.dart';
import '../../models/compliance.dart';

class ComplianceRepository {
  Future<ComplianceData> getCompliance() async {
    final response = await ApiClient.get('/mobile/compliance');
    return ComplianceData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TraceabilityLot>> getTraceability() async {
    final response = await ApiClient.get('/mobile/traceability');
    final data = response.data as Map<String, dynamic>;
    return (data['lots'] as List)
        .map((e) => TraceabilityLot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CreditReadinessData> getCreditReadiness() async {
    final response = await ApiClient.get('/mobile/credit-readiness');
    return CreditReadinessData.fromJson(
        response.data as Map<String, dynamic>);
  }
}
