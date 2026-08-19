import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:farmio_mobile/shared/widgets/farmio_shimmer.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('FarmioShimmer builds without throwing in light mode',
      (tester) async {
    await tester.pumpWidget(wrap(const FarmioShimmer(width: 100, height: 20)));
    expect(find.byType(Shimmer), findsOneWidget);
  });

  testWidgets('FarmioShimmer builds without throwing in dark mode',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: const Scaffold(body: FarmioShimmer(width: 100, height: 20)),
    ));
    expect(find.byType(Shimmer), findsOneWidget);
  });

  testWidgets('FarmioShimmerCard renders an icon block and two text lines',
      (tester) async {
    await tester.pumpWidget(wrap(const FarmioShimmerCard()));
    expect(find.byType(Shimmer), findsNWidgets(3));
  });
}
