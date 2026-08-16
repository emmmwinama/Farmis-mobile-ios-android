import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/field_map/field_map_repository.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';

void main() {
  late AppDatabase db;
  late FieldMapRepository repo;
  late FieldsRepository fields;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FieldMapRepository(db);
    fields = FieldsRepository(db);
  });

  tearDown(() async => db.close());

  // A ~1 hectare square roughly 100m x 100m near the equator, in GeoJSON
  // [lng, lat] order, closed ring.
  Map<String, dynamic> _squareGeoJson() => {
        'type': 'Polygon',
        'coordinates': [
          [
            [33.7741, -13.9626],
            [33.7752, -13.9626],
            [33.7752, -13.9617],
            [33.7741, -13.9617],
            [33.7741, -13.9626],
          ],
        ],
      };

  test('saveBoundary computes area and centroid, and updates field area',
      () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '5',
      'cultivatableArea': '5',
      'soilType': 'Loam',
    });

    final boundary = await repo.saveBoundary(field.id, _squareGeoJson());

    expect(boundary.areaHa, greaterThan(0));
    expect(boundary.centroidLat, closeTo(-13.96215, 0.01));
    expect(boundary.centroidLng, closeTo(33.77465, 0.01));

    final updatedFields = await fields.getFields();
    expect(updatedFields.first.totalArea, closeTo(boundary.areaHa!, 0.001));
  });

  test('saveBoundary rejects a polygon with fewer than 3 points', () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '5',
      'cultivatableArea': '5',
      'soilType': 'Loam',
    });

    expect(
      () => repo.saveBoundary(field.id, {
        'type': 'Polygon',
        'coordinates': [
          [
            [33.77, -13.96],
            [33.78, -13.96],
          ]
        ],
      }),
      throwsArgumentError,
    );
  });

  test('createZone requires an existing boundary', () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '5',
      'cultivatableArea': '5',
      'soilType': 'Loam',
    });

    expect(
      () => repo.createZone(field.id, {'name': 'Zone A', 'geoJson': {}}),
      throwsStateError,
    );
  });

  test('createZone then getZones round-trips geoJson and name', () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '5',
      'cultivatableArea': '5',
      'soilType': 'Loam',
    });
    await repo.saveBoundary(field.id, _squareGeoJson());

    final zone = await repo.createZone(field.id, {
      'name': 'Irrigation block',
      'type': 'irrigation',
      'geoJson': _squareGeoJson(),
    });

    expect(zone.name, 'Irrigation block');
    expect(zone.geoJson['type'], 'Polygon');

    final zones = await repo.getZones(field.id);
    expect(zones, hasLength(1));
    expect(zones.first.id, zone.id);
  });

  test('getFieldMap computes readiness stats', () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '5',
      'cultivatableArea': '5',
      'soilType': 'Loam',
    });
    await repo.saveBoundary(field.id, _squareGeoJson());
    await repo.createMarker({
      'type': 'borehole',
      'label': 'Main borehole',
      'lat': '-13.9620',
      'lng': '33.7745',
      'fieldId': field.id,
    });

    final data = await repo.getFieldMap();

    expect(data.readiness.totalFields, 1);
    expect(data.readiness.fieldsWithBoundary, 1);
    expect(data.readiness.totalMarkers, 1);
    expect(data.fields.first.boundary, isNotNull);
    expect(data.markers, hasLength(1));
  });

  test('createMarker then updateMarker then deleteMarker', () async {
    final marker = await repo.createMarker({
      'type': 'shed',
      'label': 'Storage shed',
      'lat': '-13.96',
      'lng': '33.77',
    });

    final updated = await repo.updateMarker(marker.id, {'label': 'Old shed'});
    expect(updated.label, 'Old shed');

    await repo.deleteMarker(marker.id);
    expect(await repo.getMarkers(), isEmpty);
  });
}
