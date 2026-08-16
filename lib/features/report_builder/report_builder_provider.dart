import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'report_builder_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/report_builder.dart';

final reportBuilderRepositoryProvider = Provider<ReportBuilderRepository>(
  (ref) => ReportBuilderRepository(ref.read(databaseProvider)),
);

final reportBuilderProvider =
    FutureProvider.autoDispose<ReportBuilderData>((ref) {
  return ref.read(reportBuilderRepositoryProvider).getReportBuilder();
});
