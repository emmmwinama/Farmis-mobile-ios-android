import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/profile/farm_profile_repository.dart';

void main() {
  late AppDatabase db;
  late FarmProfileRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FarmProfileRepository(db);
  });

  tearDown(() async => db.close());

  test('getProfile returns null when no profile has been saved yet', () async {
    expect(await repo.getProfile(), isNull);
  });

  test('saveProfile creates a row when none exists', () async {
    await repo.saveProfile(name: 'Chikwawa Farm', location: 'Chikwawa');

    final profile = await repo.getProfile();
    expect(profile!.name, 'Chikwawa Farm');
    expect(profile.location, 'Chikwawa');
  });

  test('saveProfile updates the existing singleton row instead of duplicating',
      () async {
    await repo.saveProfile(name: 'First name', location: 'First location');
    await repo.saveProfile(
      name: 'Updated name',
      location: 'Updated location',
      locationLat: -13.9626,
      locationLng: 33.7741,
    );

    final profile = await repo.getProfile();
    expect(profile!.name, 'Updated name');
    expect(profile.locationLat, -13.9626);
  });
}
