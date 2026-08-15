import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'compliance_repository.dart';
import '../../models/compliance.dart';

final complianceRepositoryProvider = Provider<ComplianceRepository>(
  (_) => ComplianceRepository(),
);

final complianceProvider = FutureProvider.autoDispose<ComplianceData>((ref) {
  return ref.read(complianceRepositoryProvider).getCompliance();
});

final traceabilityProvider =
    FutureProvider.autoDispose<List<TraceabilityLot>>((ref) {
  return ref.read(complianceRepositoryProvider).getTraceability();
});

final creditReadinessProvider =
    FutureProvider.autoDispose<CreditReadinessData>((ref) {
  return ref.read(complianceRepositoryProvider).getCreditReadiness();
});
