import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/shared/filters/entity_filter_bar.dart';

void main() {
  testWidgets('shows the title and an all-clear summary when collapsed',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EntityFilterBar(
          dimensions: [
            FilterDimension(
              label: 'Soil type',
              icon: Icons.grain,
              value: 'All',
              options: const ['Loam', 'Clay'],
              onSelected: (_) {},
            ),
          ],
        ),
      ),
    ));

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('All filters'), findsOneWidget);
  });

  testWidgets('expanding reveals a pill per dimension and selecting updates it',
      (tester) async {
    String selected = 'All';

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          home: Scaffold(
            body: EntityFilterBar(
              dimensions: [
                FilterDimension(
                  label: 'Soil type',
                  icon: Icons.grain,
                  value: selected,
                  options: const ['Loam', 'Clay'],
                  onSelected: (v) => setState(() => selected = v),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Loam').last);
    await tester.pumpAndSettle();

    expect(selected, 'Loam');
  });
}
