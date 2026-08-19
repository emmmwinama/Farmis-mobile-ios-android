import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';

/// Whether the farm profile has been filled in yet. Gates the app before
/// PIN setup: a fresh install has no name to greet, so it makes no sense
/// to lock the app with a PIN before we know whose farm it is.
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._db) : super(false);

  final AppDatabase _db;

  Future<void> hydrate() async {
    try {
      final profile = await _db.select(_db.farmProfile).getSingleOrNull();
      state = profile != null && profile.name.trim().isNotEmpty;
    } catch (e, st) {
      // A FutureProvider's error is invisible to callers that only
      // `ref.watch` it for its side effect (as main.dart does) — without
      // this, a failed read here would strand [state] at its initial
      // `false` forever, permanently stuck on /onboarding with no signal
      // as to why.
      debugPrint('OnboardingNotifier.hydrate() failed: $e\n$st');
    }
  }

  void markComplete() => state = true;
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier(ref.read(databaseProvider));
});

/// Resolves the on-disk state once before the router makes its first
/// redirect decision — mirrors [pinHydrationProvider]'s role for the PIN.
final onboardingHydrationProvider = FutureProvider<bool>((ref) async {
  final notifier = ref.read(onboardingProvider.notifier);
  await notifier.hydrate();
  return ref.read(onboardingProvider);
});
