import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'report_builder_repository.dart';
import '../../models/report_builder.dart';

final reportBuilderRepositoryProvider = Provider<ReportBuilderRepository>(
  (_) => ReportBuilderRepository(),
);

final reportBuilderProvider =
    FutureProvider.autoDispose<ReportBuilderData>((ref) {
  return ref.read(reportBuilderRepositoryProvider).getReportBuilder();
});
