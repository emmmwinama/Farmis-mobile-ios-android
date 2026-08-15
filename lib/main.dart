import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/api/api_client.dart';
import 'core/auth/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge + status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:            Colors.transparent,
    statusBarIconBrightness:   Brightness.dark,
    systemNavigationBarColor:  Colors.white,
  ));

  await dotenv.load(fileName: '.env');

  // Created explicitly (rather than via ProviderScope) so the static
  // ApiClient can reach into Riverpod state when a request 401s.
  final container = ProviderContainer();
  ApiClient.onUnauthorized =
      () => container.read(authProvider.notifier).forceLogout();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AgriVaultApp(),
    ),
  );
}

class AgriVaultApp extends ConsumerWidget {
  const AgriVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authHydrationProvider);
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title:                     'AgriVault',
      debugShowCheckedModeBanner: false,
      theme:       AppTheme.light(),
      darkTheme:   AppTheme.dark(),
      themeMode:   themeMode,
      routerConfig: router,
    );
  }
}
