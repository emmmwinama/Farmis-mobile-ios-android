import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/sync/sync_queue_provider.dart';
import 'package:farmio_mobile/shared/widgets/sync_status_indicator.dart';

import '../support/fake_sync_queue_service.dart';

Widget _wrap(FakeSyncQueueService service) => ProviderScope(
      overrides: [syncQueueServiceProvider.overrideWithValue(service)],
      child: const MaterialApp(
        home: Scaffold(body: SyncStatusIndicator()),
      ),
    );

void main() {
  testWidgets('shows all-synced when the queue is empty', (tester) async {
    await tester.pumpWidget(_wrap(FakeSyncQueueService()));
    await tester.pumpAndSettle();

    expect(find.text('All records synced'), findsOneWidget);
  });

  testWidgets('shows a queued count when items are pending', (tester) async {
    final service = FakeSyncQueueService();
    await service.enqueue(
      type: 'finance',
      method: 'POST',
      path: '/mobile/finance',
      payload: const {'amount': '10'},
    );
    await service.enqueue(
      type: 'activity',
      method: 'POST',
      path: '/mobile/activities',
      payload: const {'note': 'sprayed'},
    );

    await tester.pumpWidget(_wrap(service));
    await tester.pumpAndSettle();

    expect(find.text('2 queued'), findsOneWidget);
  });
}
