import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'compliance_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/compliance.dart';

final complianceRepositoryProvider = Provider<ComplianceRepository>(
  (ref) => ComplianceRepository(ref.read(databaseProvider)),
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
