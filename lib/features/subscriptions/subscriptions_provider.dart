import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/subscription_tier.dart';
import 'subscriptions_repository.dart';

final subscriptionsRepositoryProvider = Provider<SubscriptionsRepository>(
  (_) => SubscriptionsRepository(),
);

final subscriptionTiersProvider =
    FutureProvider.autoDispose<List<SubscriptionTier>>((ref) async {
  return ref.read(subscriptionsRepositoryProvider).fetchPublicTiers();
});
