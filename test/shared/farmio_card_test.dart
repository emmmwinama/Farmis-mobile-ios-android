import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/theme/app_theme.dart';
import 'package:farmio_mobile/shared/widgets/farmio_card.dart';

void main() {
  Widget wrap(Widget child, {ThemeData? theme}) => MaterialApp(
        theme: theme ?? ThemeData(extensions: const [FarmioColorsExt.light]),
        home: Scaffold(body: child),
      );

  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(wrap(const FarmioCard(child: Text('hello'))));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('uses the light surface color from context.colors', (tester) async {
    await tester.pumpWidget(wrap(const FarmioCard(child: SizedBox())));
    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, FarmioColorsExt.light.surface);
  });

  testWidgets('uses the dark surface color from context.colors', (tester) async {
    await tester.pumpWidget(wrap(
      const FarmioCard(child: SizedBox()),
      theme: ThemeData(extensions: const [FarmioColorsExt.dark]),
    ));
    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, FarmioColorsExt.dark.surface);
  });

  testWidgets('an explicit color overrides the theme surface', (tester) async {
    await tester.pumpWidget(wrap(
      const FarmioCard(color: Colors.red, child: SizedBox()),
    ));
    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.red);
  });

  testWidgets('tapping onTap fires the callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      FarmioCard(onTap: () => tapped = true, child: const Text('tap me')),
    ));
    await tester.tap(find.text('tap me'));
    expect(tapped, isTrue);
  });
}
