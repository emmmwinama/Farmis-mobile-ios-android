import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';

class FarmProfileRepository {
  FarmProfileRepository(this._db);

  final AppDatabase _db;

  Future<FarmProfileData?> getProfile() =>
      _db.select(_db.farmProfile).getSingleOrNull();

  Future<void> saveProfile({
    String? ownerName,
    required String name,
    required String location,
    double? locationLat,
    double? locationLng,
  }) async {
    final existing = await getProfile();
    if (existing != null) {
      await (_db.update(_db.farmProfile)
            ..where((t) => t.id.equals(existing.id)))
          .write(FarmProfileCompanion(
        ownerName: Value(ownerName),
        name: Value(name),
        location: Value(location),
        locationLat: Value(locationLat),
        locationLng: Value(locationLng),
      ));
    } else {
      await _db.into(_db.farmProfile).insert(FarmProfileCompanion.insert(
            id: newId(),
            ownerName: Value(ownerName),
            name: name,
            location: location,
            locationLat: Value(locationLat),
            locationLng: Value(locationLng),
            createdAt: DateTime.now(),
          ));
    }
  }
}
