import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/db_utils.dart';
import 'package:farmio_mobile/core/onboarding/onboarding_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  test('hydrate() is false when no farm profile has been saved yet', () async {
    final notifier = OnboardingNotifier(db);
    await notifier.hydrate();
    expect(notifier.state, isFalse);
  });

  test('hydrate() is true once a farm profile with a name exists', () async {
    await db.into(db.farmProfile).insert(FarmProfileCompanion.insert(
          id: newId(),
          name: 'Chikwawa Farm',
          location: 'Chikwawa',
          createdAt: DateTime.now(),
        ));

    final notifier = OnboardingNotifier(db);
    await notifier.hydrate();
    expect(notifier.state, isTrue);
  });

  test('markComplete() flips the state without touching the database',
      () async {
    final notifier = OnboardingNotifier(db);
    await notifier.hydrate();
    expect(notifier.state, isFalse);

    notifier.markComplete();
    expect(notifier.state, isTrue);
  });
}
