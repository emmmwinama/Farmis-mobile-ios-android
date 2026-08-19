import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/shared/widgets/section_tab_host.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('renders one pill per tab, in order', (tester) async {
    await tester.pumpWidget(wrap(const SectionTabHost(
      title: 'Farm',
      tabs: [
        SectionTabEntry(label: 'Fields', content: Text('fields content')),
        SectionTabEntry(label: 'Crops', content: Text('crops content')),
        SectionTabEntry(label: 'Livestock', content: Text('livestock content')),
      ],
    )));

    expect(find.text('Fields'), findsOneWidget);
    expect(find.text('Crops'), findsOneWidget);
    expect(find.text('Livestock'), findsOneWidget);
  });

  testWidgets('shows the initialIndex tab content by default', (tester) async {
    await tester.pumpWidget(wrap(const SectionTabHost(
      title: 'Farm',
      tabs: [
        SectionTabEntry(label: 'Fields', content: Text('fields content')),
        SectionTabEntry(label: 'Crops', content: Text('crops content')),
      ],
    )));

    expect(find.text('fields content'), findsOneWidget);
    expect(find.text('crops content'), findsNothing);
  });

  testWidgets('tapping a pill switches the visible content', (tester) async {
    await tester.pumpWidget(wrap(const SectionTabHost(
      title: 'Farm',
      tabs: [
        SectionTabEntry(label: 'Fields', content: Text('fields content')),
        SectionTabEntry(label: 'Crops', content: Text('crops content')),
      ],
    )));

    await tester.tap(find.text('Crops'));
    await tester.pumpAndSettle();

    expect(find.text('crops content'), findsOneWidget);
    expect(find.text('fields content'), findsNothing);
  });

  testWidgets('respects a non-zero initialIndex', (tester) async {
    await tester.pumpWidget(wrap(const SectionTabHost(
      title: 'Farm',
      initialIndex: 1,
      tabs: [
        SectionTabEntry(label: 'Fields', content: Text('fields content')),
        SectionTabEntry(label: 'Crops', content: Text('crops content')),
      ],
    )));

    expect(find.text('crops content'), findsOneWidget);
    expect(find.text('fields content'), findsNothing);
  });
}
