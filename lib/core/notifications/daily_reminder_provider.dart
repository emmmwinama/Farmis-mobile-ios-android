import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'daily_reminder_service.dart';

final dailyReminderServiceProvider =
    Provider<DailyReminderService>((ref) => DailyReminderService());

/// Requests notification permissions and readies the plugin once, before
/// any alert is due to sync — mirrors [onboardingHydrationProvider]'s role
/// for onboarding state. Watched once from the app root in main.dart.
final dailyReminderHydrationProvider = FutureProvider<void>((ref) async {
  await ref.read(dailyReminderServiceProvider).initialize();
});
