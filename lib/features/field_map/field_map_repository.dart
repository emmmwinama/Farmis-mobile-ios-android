import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/field_boundary.dart';

/// Extracts the first ring's `[lng, lat]` pairs from a GeoJSON Feature or
/// bare Polygon geometry, mirroring the backend's `polygonCoords()`.
List<List<double>> _polygonCoords(Map<String, dynamic> geoJson) {
  final geometry = geoJson['geometry'] as Map<String, dynamic>?;
  final coordinates =
      (geometry?['coordinates'] ?? geoJson['coordinates']) as List?;
  final ring = coordinates?.isNotEmpty == true ? coordinates!.first : null;
  if (ring is! List) return const [];
  return ring
      .whereType<List>()
      .where((p) => p.length >= 2 && p[0] is num && p[1] is num)
      .map((p) => [(p[0] as num).toDouble(), (p[1] as num).toDouble()])
      .toList();
}

/// Spherical-excess polygon area in hectares, mirroring the backend's
/// `calcAreaHa()` exactly (same formula, same Earth radius constant).
double _calcAreaHa(List<List<double>> coordinates) {
  if (coordinates.length < 3) return 0;
  const r = 6371000.0;
  var area = 0.0;
  for (var i = 0; i < coordinates.length; i++) {
    final j = (i + 1) % coordinates.length;
    final lat1 = coordinates[i][1] * math.pi / 180;
    final lat2 = coordinates[j][1] * math.pi / 180;
    final lng1 = coordinates[i][0] * math.pi / 180;
    final lng2 = coordinates[j][0] * math.pi / 180;
    area += (lng2 - lng1) * (2 + math.sin(lat1) + math.sin(lat2));
  }
  return (area * r * r / 2).abs() / 10000;
}

(double, double)? _calcCentroid(List<List<double>> coordinates) {
  if (coordinates.isEmpty) return null;
  final lat = coordinates.fold<double>(0, (s, p) => s + p[1]) / coordinates.length;
  final lng = coordinates.fold<double>(0, (s, p) => s + p[0]) / coordinates.length;
  return (lat, lng);
}

class FieldMapRepository {
  FieldMapRepository(this._db);

  final AppDatabase _db;

  Future<FieldMapData> getFieldMap() async {
    final profile = await _db.select(_db.farmProfile).getSingleOrNull();
    final fields = await (_db.select(_db.fields)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    final markers = await (_db.select(_db.farmMarkers)
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .get();

    double totalHa = 0, totalMappedHa = 0;
    var fieldsWithCoordinates = 0, fieldsWithBoundary = 0, totalZones = 0;
    final fieldJson = <Map<String, dynamic>>[];

    for (final field in fields) {
      totalHa += field.totalArea;
      if (field.locationLat != null && field.locationLng != null) {
        fieldsWithCoordinates++;
      }

      final boundary = await _boundaryWithZones(field.id);
      if (boundary != null) {
        fieldsWithBoundary++;
        totalMappedHa += boundary.areaHa ?? 0;
        totalZones += boundary.zones.length;
      }

      final activeCrops = await (_db.select(_db.cropFields)
            ..where(
                (t) => t.fieldId.equals(field.id) & t.status.equals('Active')))
          .get();
      final activeCropJson = <Map<String, dynamic>>[];
      for (final crop in activeCrops) {
        final cropType = await (_db.select(_db.cropTypes)
              ..where((t) => t.id.equals(crop.cropTypeId)))
            .getSingleOrNull();
        activeCropJson.add({
          'id': crop.id,
          'cropName': cropType?.name ?? 'Crop',
          'variety': crop.variety,
          'season': crop.season,
          'areaPlanted': crop.areaPlanted,
        });
      }

      fieldJson.add({
        'id': field.id,
        'name': field.name,
        'totalArea': field.totalArea,
        'cultivatableArea': field.cultivatableArea,
        'soilType': field.soilType,
        'locationLat': field.locationLat,
        'locationLng': field.locationLng,
        'gpsReady': field.locationLat != null && field.locationLng != null,
        'boundary': boundary == null
            ? null
            : {
                'id': boundary.id,
                'fieldId': boundary.fieldId,
                'geoJson': boundary.geoJson,
                'areaHa': boundary.areaHa,
                'centroidLat': boundary.centroidLat,
                'centroidLng': boundary.centroidLng,
                'zones': boundary.zones.map(_zoneModelJson).toList(),
              },
        'zoneCount': boundary?.zones.length ?? 0,
        'activeCrops': activeCropJson,
      });
    }

    return FieldMapData.fromJson({
      'farm': {'name': profile?.name ?? 'My Farm'},
      'readiness': {
        'totalFields': fields.length,
        'fieldsWithCoordinates': fieldsWithCoordinates,
        'fieldsWithBoundary': fieldsWithBoundary,
        'totalMarkers': markers.length,
        'totalZones': totalZones,
        'totalHa': totalHa,
        'totalMappedHa': totalMappedHa,
        'mappedPct': totalHa > 0 ? (totalMappedHa / totalHa * 100) : 0,
      },
      'fields': fieldJson,
      'markers': markers.map((m) => m.toJson()).toList(),
    });
  }

  Future<FieldBoundary?> _boundaryWithZones(String fieldId) async {
    final row = await (_db.select(_db.fieldBoundaries)
          ..where((t) => t.fieldId.equals(fieldId)))
        .getSingleOrNull();
    if (row == null) return null;
    final zones = await (_db.select(_db.fieldZones)
          ..where((t) => t.fieldId.equals(fieldId)))
        .get();
    final zoneJson = <Map<String, dynamic>>[];
    for (final zone in zones) {
      String? cropTypeName;
      final cropFieldId = zone.cropFieldId;
      if (cropFieldId != null) {
        final crop = await (_db.select(_db.cropFields)
              ..where((t) => t.id.equals(cropFieldId)))
            .getSingleOrNull();
        if (crop != null) {
          final cropType = await (_db.select(_db.cropTypes)
                ..where((t) => t.id.equals(crop.cropTypeId)))
              .getSingleOrNull();
          cropTypeName = cropType?.name;
        }
      }
      zoneJson.add(_zoneJson(zone, cropTypeName));
    }

    return FieldBoundary.fromJson({
      'id': row.id,
      'fieldId': row.fieldId,
      'geoJson': jsonDecode(row.geoJson),
      'areaHa': row.areaHa,
      'centroidLat': row.centroidLat,
      'centroidLng': row.centroidLng,
      'zones': zoneJson,
    });
  }

  Map<String, dynamic> _zoneModelJson(FieldZone zone) => {
        'id': zone.id,
        'fieldId': zone.fieldId,
        'name': zone.name,
        'type': zone.type,
        'cropFieldId': zone.cropFieldId,
        'geoJson': zone.geoJson,
        'areaHa': zone.areaHa,
        'colour': zone.colour,
        'notes': zone.notes,
        if (zone.cropTypeName != null)
          'cropField': {
            'cropType': {'name': zone.cropTypeName}
          },
      };

  Map<String, dynamic> _zoneJson(FieldZoneRow zone, String? cropTypeName) => {
        'id': zone.id,
        'fieldId': zone.fieldId,
        'name': zone.name,
        'type': zone.type,
        'cropFieldId': zone.cropFieldId,
        'geoJson': jsonDecode(zone.geoJson),
        'areaHa': zone.areaHa,
        'colour': zone.colour,
        'notes': zone.notes,
        if (cropTypeName != null)
          'cropField': {
            'cropType': {'name': cropTypeName}
          },
      };

  Future<FieldBoundary?> getBoundary(String fieldId) => _boundaryWithZones(fieldId);

  Future<FieldBoundary> saveBoundary(
    String fieldId,
    Map<String, dynamic> geoJson, {
    bool updateFieldArea = true,
  }) async {
    final coords = _polygonCoords(geoJson);
    if (coords.length < 3) {
      throw ArgumentError('A polygon boundary requires at least 3 points');
    }
    final areaHa = _calcAreaHa(coords);
    final centroid = _calcCentroid(coords);

    final existing = await (_db.select(_db.fieldBoundaries)
          ..where((t) => t.fieldId.equals(fieldId)))
        .getSingleOrNull();

    final id = existing?.id ?? newId();
    final geoJsonEncoded = jsonEncode(geoJson);
    if (existing != null) {
      await (_db.update(_db.fieldBoundaries)..where((t) => t.id.equals(id)))
          .write(FieldBoundariesCompanion(
        geoJson: Value(geoJsonEncoded),
        areaHa: Value(areaHa),
        centroidLat: Value(centroid?.$1),
        centroidLng: Value(centroid?.$2),
      ));
    } else {
      await _db.into(_db.fieldBoundaries).insert(
            FieldBoundariesCompanion.insert(
              id: id,
              fieldId: fieldId,
              geoJson: geoJsonEncoded,
              areaHa: Value(areaHa),
              centroidLat: Value(centroid?.$1),
              centroidLng: Value(centroid?.$2),
            ),
          );
    }

    if (updateFieldArea && areaHa > 0) {
      final rounded = double.parse(areaHa.toStringAsFixed(4));
      await (_db.update(_db.fields)..where((t) => t.id.equals(fieldId))).write(
        FieldsCompanion(
          totalArea: Value(rounded),
          cultivatableArea: Value(rounded),
        ),
      );
    }

    final row = await (_db.select(_db.fieldBoundaries)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return FieldBoundary.fromJson({
      'id': row.id,
      'fieldId': row.fieldId,
      'geoJson': jsonDecode(row.geoJson),
      'areaHa': row.areaHa,
      'centroidLat': row.centroidLat,
      'centroidLng': row.centroidLng,
    });
  }

  Future<void> deleteBoundary(String fieldId) async {
    await (_db.delete(_db.fieldZones)..where((t) => t.fieldId.equals(fieldId)))
        .go();
    await (_db.delete(_db.fieldBoundaries)
          ..where((t) => t.fieldId.equals(fieldId)))
        .go();
  }

  Future<List<FieldZone>> getZones(String fieldId) async {
    final boundary = await _boundaryWithZones(fieldId);
    return boundary?.zones ?? const [];
  }

  Future<FieldZone> createZone(String fieldId, Map<String, dynamic> data) async {
    final boundary = await (_db.select(_db.fieldBoundaries)
          ..where((t) => t.fieldId.equals(fieldId)))
        .getSingleOrNull();
    if (boundary == null) {
      throw StateError('Create a field boundary before adding zones');
    }

    final geoJson = data['geoJson'] as Map<String, dynamic>? ?? const {};
    final coords = _polygonCoords(geoJson);
    final areaHa = data['areaHa'] != null
        ? asDouble(data['areaHa'])
        : _calcAreaHa(coords);

    final id = newId();
    await _db.into(_db.fieldZones).insert(FieldZonesCompanion.insert(
          id: id,
          boundaryId: boundary.id,
          fieldId: fieldId,
          name: asStringOrNull(data['name']) ?? 'Zone',
          type: asStringOrNull(data['type']) ?? 'crop',
          cropFieldId: Value(asStringOrNull(data['cropFieldId'])),
          geoJson: jsonEncode(geoJson),
          areaHa: Value(areaHa),
          colour: Value(asStringOrNull(data['colour'])),
          notes: Value(asStringOrNull(data['notes'])),
        ));

    final row =
        await (_db.select(_db.fieldZones)..where((t) => t.id.equals(id)))
            .getSingle();
    return _hydrateZone(row);
  }

  Future<FieldZone> updateZone(
    String fieldId,
    String zoneId,
    Map<String, dynamic> data,
  ) async {
    await (_db.update(_db.fieldZones)..where((t) => t.id.equals(zoneId))).write(
      FieldZonesCompanion(
        name: data['name'] != null
            ? Value(data['name'] as String)
            : const Value.absent(),
        type: data['type'] != null
            ? Value(data['type'] as String)
            : const Value.absent(),
        cropFieldId: data.containsKey('cropFieldId')
            ? Value(asStringOrNull(data['cropFieldId']))
            : const Value.absent(),
        geoJson: data['geoJson'] != null
            ? Value(jsonEncode(data['geoJson'] as Map<String, dynamic>))
            : const Value.absent(),
        areaHa: data.containsKey('areaHa')
            ? Value(asDoubleOrNull(data['areaHa']))
            : const Value.absent(),
        colour: data.containsKey('colour')
            ? Value(asStringOrNull(data['colour']))
            : const Value.absent(),
        notes: data.containsKey('notes')
            ? Value(asStringOrNull(data['notes']))
            : const Value.absent(),
      ),
    );

    final row =
        await (_db.select(_db.fieldZones)..where((t) => t.id.equals(zoneId)))
            .getSingle();
    return _hydrateZone(row);
  }

  Future<void> deleteZone(String fieldId, String zoneId) async {
    await (_db.delete(_db.fieldZones)..where((t) => t.id.equals(zoneId))).go();
  }

  Future<FieldZone> _hydrateZone(FieldZoneRow row) async {
    String? cropTypeName;
    final cropFieldId = row.cropFieldId;
    if (cropFieldId != null) {
      final crop = await (_db.select(_db.cropFields)
            ..where((t) => t.id.equals(cropFieldId)))
          .getSingleOrNull();
      if (crop != null) {
        final cropType = await (_db.select(_db.cropTypes)
              ..where((t) => t.id.equals(crop.cropTypeId)))
            .getSingleOrNull();
        cropTypeName = cropType?.name;
      }
    }
    return FieldZone.fromJson(_zoneJson(row, cropTypeName));
  }

  Future<List<FarmMarker>> getMarkers({String? fieldId}) async {
    final query = _db.select(_db.farmMarkers)
      ..orderBy([(t) => OrderingTerm.desc(t.id)]);
    if (fieldId != null) query.where((t) => t.fieldId.equals(fieldId));
    final rows = await query.get();
    return rows.map((r) => FarmMarker.fromJson(r.toJson())).toList();
  }

  Future<FarmMarker> createMarker(Map<String, dynamic> data) async {
    final id = newId();
    await _db.into(_db.farmMarkers).insert(FarmMarkersCompanion.insert(
          id: id,
          fieldId: Value(asStringOrNull(data['fieldId'])),
          type: data['type'] as String,
          label: data['label'] as String,
          lat: asDouble(data['lat']),
          lng: asDouble(data['lng']),
          notes: Value(asStringOrNull(data['notes'])),
          icon: Value(asStringOrNull(data['icon'])),
        ));
    final row =
        await (_db.select(_db.farmMarkers)..where((t) => t.id.equals(id)))
            .getSingle();
    return FarmMarker.fromJson(row.toJson());
  }

  Future<FarmMarker> updateMarker(String id, Map<String, dynamic> data) async {
    await (_db.update(_db.farmMarkers)..where((t) => t.id.equals(id))).write(
      FarmMarkersCompanion(
        fieldId: data.containsKey('fieldId')
            ? Value(asStringOrNull(data['fieldId']))
            : const Value.absent(),
        type: data['type'] != null
            ? Value(data['type'] as String)
            : const Value.absent(),
        label: data['label'] != null
            ? Value(data['label'] as String)
            : const Value.absent(),
        lat: data['lat'] != null
            ? Value(asDouble(data['lat']))
            : const Value.absent(),
        lng: data['lng'] != null
            ? Value(asDouble(data['lng']))
            : const Value.absent(),
        notes: data.containsKey('notes')
            ? Value(asStringOrNull(data['notes']))
            : const Value.absent(),
        icon: data.containsKey('icon')
            ? Value(asStringOrNull(data['icon']))
            : const Value.absent(),
      ),
    );
    final row =
        await (_db.select(_db.farmMarkers)..where((t) => t.id.equals(id)))
            .getSingle();
    return FarmMarker.fromJson(row.toJson());
  }

  Future<void> deleteMarker(String id) async {
    await (_db.delete(_db.farmMarkers)..where((t) => t.id.equals(id))).go();
  }
}
