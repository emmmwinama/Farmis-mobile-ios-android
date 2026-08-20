import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/theme/app_theme.dart';

// Deliberately doesn't call AppTheme.light()/dark() — both pull in
// GoogleFonts.interTextTheme(), which fires a real network font-fetch as an
// un-awaited side effect. In this sandboxed, network-restricted test
// environment that rejected Future leaks past the test that triggered it and
// fails an unrelated later test. Cover the same guarantees (extension
// resolution, light/dark token correctness) against directly-constructed
// ThemeData instead.
void main() {
  test('FarmioColorsExt.light matches the static light tokens', () {
    expect(FarmioColorsExt.light.background, FarmioColors.background);
    expect(FarmioColorsExt.light.surface, FarmioColors.surface);
    expect(FarmioColorsExt.light.textPrimary, FarmioColors.textPrimary);
  });

  test('FarmioColorsExt.dark matches the static dark tokens', () {
    expect(FarmioColorsExt.dark.background, FarmioColors.darkBg);
    expect(FarmioColorsExt.dark.surface, FarmioColors.darkCard);
    expect(FarmioColorsExt.dark.textPrimary, FarmioColors.darkTextPrimary);
  });

  test('light and dark tokens are actually distinct', () {
    expect(FarmioColorsExt.light.background,
        isNot(equals(FarmioColorsExt.dark.background)));
    expect(FarmioColorsExt.light.textPrimary,
        isNot(equals(FarmioColorsExt.dark.textPrimary)));
  });

  test('lerp interpolates every token', () {
    final mid = FarmioColorsExt.light.lerp(FarmioColorsExt.dark, 0.5);
    expect(mid.background, isNot(equals(FarmioColorsExt.light.background)));
    expect(mid.background, isNot(equals(FarmioColorsExt.dark.background)));
  });

  testWidgets('context.colors resolves the registered dark extension',
      (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(useMaterial3: true, extensions: const [FarmioColorsExt.dark]),
      home: Builder(builder: (context) {
        capturedContext = context;
        return const SizedBox();
      }),
    ));

    expect(capturedContext.colors.background, FarmioColors.darkBg);
  });

  testWidgets(
      'context.colors falls back to light when no extension is registered',
      (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Builder(builder: (context) {
        capturedContext = context;
        return const SizedBox();
      }),
    ));

    expect(capturedContext.colors.background, FarmioColors.background);
  });

  testWidgets('context.isDark reflects the theme brightness', (tester) async {
    late BuildContext lightContext, darkContext;
    await tester.pumpWidget(MaterialApp(
      home: Theme(
        data: ThemeData(colorScheme: const ColorScheme.light()),
        child: Builder(builder: (context) {
          lightContext = context;
          return const SizedBox();
        }),
      ),
    ));
    expect(lightContext.isDark, isFalse);

    await tester.pumpWidget(MaterialApp(
      home: Theme(
        data: ThemeData(colorScheme: const ColorScheme.dark()),
        child: Builder(builder: (context) {
          darkContext = context;
          return const SizedBox();
        }),
      ),
    ));
    expect(darkContext.isDark, isTrue);
  });

  group('HeroFill', () {
    testWidgets('light mode uses the gradient, not a flat color',
        (tester) async {
      late HeroFill fill;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(colorScheme: const ColorScheme.light()),
        home: Builder(builder: (context) {
          fill = HeroFill(context,
              colors: const [FarmioColors.primaryDark, FarmioColors.primary],
              flat: FarmioColors.primaryDark);
          return const SizedBox();
        }),
      ));

      expect(fill.color, isNull);
      expect(fill.gradient, isNotNull);
      expect((fill.gradient as LinearGradient).colors,
          const [FarmioColors.primaryDark, FarmioColors.primary]);
    });

    testWidgets('dark mode uses the flat color, not the gradient',
        (tester) async {
      late HeroFill fill;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(colorScheme: const ColorScheme.dark()),
        home: Builder(builder: (context) {
          fill = HeroFill(context,
              colors: const [FarmioColors.primaryDark, FarmioColors.primary],
              flat: FarmioColors.primaryDark);
          return const SizedBox();
        }),
      ));

      expect(fill.gradient, isNull);
      expect(fill.color, FarmioColors.primaryDark);
    });
  });
}
