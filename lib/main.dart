import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/auth/pin_provider.dart';
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

  runApp(
    const ProviderScope(
      child: AgriVaultApp(),
    ),
  );
}

class AgriVaultApp extends ConsumerWidget {
  const AgriVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(pinHydrationProvider);
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
