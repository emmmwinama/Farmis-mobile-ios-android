import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/farm_context.dart';
import 'farm_context_repository.dart';

final farmContextRepositoryProvider = Provider<FarmContextRepository>(
  (_) => FarmContextRepository(),
);

final farmContextProvider = FutureProvider.autoDispose<FarmContext>(
  (ref) => ref.read(farmContextRepositoryProvider).getFarmContext(),
);
