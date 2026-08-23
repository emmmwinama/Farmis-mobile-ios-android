import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../auth/secure_storage.dart';
import '../db/database_provider.dart';

/// Wipes every persistent store the app has — the local farm database and
/// all of secure storage (PIN, auth token, cached profile, theme) — so a
/// tester can repeat onboarding/sign-up/upgrade flows from a clean slate
/// instead of working around whatever's left from the last pass. Debug-only
/// by design; see profile_screen.dart's kDebugMode gate around the button
/// that calls this.
///
/// Deliberately does NOT try to reset every Riverpod provider's in-memory
/// state afterward — StateNotifiers like pinProvider/accountProvider/
/// onboardingProvider each have their own hydration assumptions, and faking
/// a live reset risks subtly wrong behavior that a real fresh install
/// wouldn't have. Closing and reopening the app is both simpler and a more
/// honest test of the actual first-run path.
Future<void> resetAppForTesting(WidgetRef ref) async {
  await ref.read(databaseProvider).close();
  ref.invalidate(databaseProvider);

  final dir = await getApplicationDocumentsDirectory();
  final base = p.join(dir.path, 'agrivault.sqlite');
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final file = File('$base$suffix');
    if (await file.exists()) await file.delete();
  }

  await SecureStorage.deleteAll();
}
