import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/seasonal_template.dart';
import 'templates_repository.dart';

final templatesRepositoryProvider = Provider<TemplatesRepository>(
  (_) => TemplatesRepository(),
);

final templatesProvider = FutureProvider.autoDispose<List<SeasonalTemplate>>(
  (ref) => ref.read(templatesRepositoryProvider).getTemplates(),
);
