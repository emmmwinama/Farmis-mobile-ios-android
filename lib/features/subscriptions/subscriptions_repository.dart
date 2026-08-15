import '../../core/api/api_client.dart';
import '../../models/subscription_tier.dart';

class SubscriptionsRepository {
  Future<List<SubscriptionTier>> fetchPublicTiers() async {
    final response = await ApiClient.get('/public/tiers');
    return (response.data as List)
        .map((e) => SubscriptionTier.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
