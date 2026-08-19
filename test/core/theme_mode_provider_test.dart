import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/theme/theme_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUp(() {
    store.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final args = call.arguments as Map?;
      final key = args?['key'] as String?;
      switch (call.method) {
        case 'write':
          store[key!] = args!['value'] as String;
          return null;
        case 'read':
          return store[key];
        case 'delete':
          store.remove(key);
          return null;
        case 'readAll':
          return store;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('defaults to light before hydration', () {
    final notifier = ThemeModeNotifier();
    expect(notifier.state, ThemeMode.light);
  });

  test('hydrate() stays light when nothing was ever saved', () async {
    final notifier = ThemeModeNotifier();
    await notifier.hydrate();
    expect(notifier.state, ThemeMode.light);
  });

  test('toggle() flips state and persists it', () async {
    final notifier = ThemeModeNotifier();
    await notifier.toggle();
    expect(notifier.state, ThemeMode.dark);

    final rehydrated = ThemeModeNotifier();
    await rehydrated.hydrate();
    expect(rehydrated.state, ThemeMode.dark);
  });

  test('toggle() twice returns to light and persists that', () async {
    final notifier = ThemeModeNotifier();
    await notifier.toggle();
    await notifier.toggle();
    expect(notifier.state, ThemeMode.light);

    final rehydrated = ThemeModeNotifier();
    await rehydrated.hydrate();
    expect(rehydrated.state, ThemeMode.light);
  });
}
