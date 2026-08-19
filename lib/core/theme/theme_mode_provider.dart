import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/secure_storage.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  Future<void> hydrate() async {
    final saved = await SecureStorage.getThemeMode();
    if (saved == 'dark') state = ThemeMode.dark;
  }

  Future<void> toggle() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await SecureStorage.saveThemeMode(state == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => ThemeModeNotifier());

/// Resolves the persisted theme choice once before the first frame —
/// mirrors [pinHydrationProvider]/[onboardingHydrationProvider]'s role.
final themeModeHydrationProvider = FutureProvider<void>((ref) async {
  await ref.read(themeModeProvider.notifier).hydrate();
});
