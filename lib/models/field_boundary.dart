class FieldBoundary {
  final String id;
  final String fieldId;
  final Map<String, dynamic> geoJson;
  final double? areaHa;
  final double? centroidLat;
  final double? centroidLng;
  final List<FieldZone> zones;

  const FieldBoundary({
    required this.id,
    required this.fieldId,
    required this.geoJson,
    this.areaHa,
    this.centroidLat,
    this.centroidLng,
    this.zones = const [],
  });

  /// Flattened `[lat, lng]` ring for the boundary's outer polygon, derived
  /// from the stored GeoJSON (Feature or bare Geometry, first ring only).
  List<List<double>> get points => _ringFromGeoJson(geoJson);

  factory FieldBoundary.fromJson(Map<String, dynamic> json) => FieldBoundary(
        id: json['id'] as String,
        fieldId: json['fieldId'] as String,
        geoJson: Map<String, dynamic>.from(json['geoJson'] as Map? ?? {}),
        areaHa: (json['areaHa'] as num?)?.toDouble(),
        centroidLat: (json['centroidLat'] as num?)?.toDouble(),
        centroidLng: (json['centroidLng'] as num?)?.toDouble(),
        zones: (json['zones'] as List? ?? const [])
            .map((e) => FieldZone.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class FieldZone {
  final String id;
  final String fieldId;
  final String name;
  final String type;
  final String? cropFieldId;
  final Map<String, dynamic> geoJson;
  final double? areaHa;
  final String? colour;
  final String? notes;
  final String? cropTypeName;

  const FieldZone({
    required this.id,
    required this.fieldId,
    required this.name,
    required this.type,
    this.cropFieldId,
    required this.geoJson,
    this.areaHa,
    this.colour,
    this.notes,
    this.cropTypeName,
  });

  List<List<double>> get points => _ringFromGeoJson(geoJson);

  factory FieldZone.fromJson(Map<String, dynamic> json) {
    final cropField = json['cropField'] as Map<String, dynamic>?;
    final cropType = cropField?['cropType'] as Map<String, dynamic>?;
    return FieldZone(
      id: json['id'] as String,
      fieldId: json['fieldId'] as String,
      name: json['name'] as String? ?? 'Zone',
      type: json['type'] as String? ?? 'crop',
      cropFieldId: json['cropFieldId'] as String?,
      geoJson: Map<String, dynamic>.from(json['geoJson'] as Map? ?? {}),
      areaHa: (json['areaHa'] as num?)?.toDouble(),
      colour: json['colour'] as String?,
      notes: json['notes'] as String?,
      cropTypeName: cropType?['name'] as String?,
    );
  }
}

class FarmMarker {
  final String id;
  final String? fieldId;
  final String type;
  final String label;
  final double lat;
  final double lng;
  final String? notes;
  final String? icon;

  const FarmMarker({
    required this.id,
    this.fieldId,
    required this.type,
    required this.label,
    required this.lat,
    required this.lng,
    this.notes,
    this.icon,
  });

  factory FarmMarker.fromJson(Map<String, dynamic> json) => FarmMarker(
        id: json['id'] as String,
        fieldId: json['fieldId'] as String?,
        type: json['type'] as String,
        label: json['label'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        notes: json['notes'] as String?,
        icon: json['icon'] as String?,
      );
}

class FieldMapReadiness {
  final int totalFields;
  final int fieldsWithCoordinates;
  final int fieldsWithBoundary;
  final int totalMarkers;
  final int totalZones;
  final double totalHa;
  final double totalMappedHa;
  final double mappedPct;

  const FieldMapReadiness({
    required this.totalFields,
    required this.fieldsWithCoordinates,
    required this.fieldsWithBoundary,
    required this.totalMarkers,
    required this.totalZones,
    required this.totalHa,
    required this.totalMappedHa,
    required this.mappedPct,
  });

  factory FieldMapReadiness.fromJson(Map<String, dynamic> json) =>
      FieldMapReadiness(
        totalFields: (json['totalFields'] as num? ?? 0).toInt(),
        fieldsWithCoordinates:
            (json['fieldsWithCoordinates'] as num? ?? 0).toInt(),
        fieldsWithBoundary: (json['fieldsWithBoundary'] as num? ?? 0).toInt(),
        totalMarkers: (json['totalMarkers'] as num? ?? 0).toInt(),
        totalZones: (json['totalZones'] as num? ?? 0).toInt(),
        totalHa: (json['totalHa'] as num? ?? 0).toDouble(),
        totalMappedHa: (json['totalMappedHa'] as num? ?? 0).toDouble(),
        mappedPct: (json['mappedPct'] as num? ?? 0).toDouble(),
      );
}

class FieldMapActiveCrop {
  final String id;
  final String cropName;
  final String variety;
  final String season;
  final double areaPlanted;

  const FieldMapActiveCrop({
    required this.id,
    required this.cropName,
    required this.variety,
    required this.season,
    required this.areaPlanted,
  });

  factory FieldMapActiveCrop.fromJson(Map<String, dynamic> json) =>
      FieldMapActiveCrop(
        id: json['id'] as String,
        cropName: json['cropName'] as String? ?? '',
        variety: json['variety'] as String? ?? '',
        season: json['season'] as String? ?? '',
        areaPlanted: (json['areaPlanted'] as num? ?? 0).toDouble(),
      );
}

class FieldMapField {
  final String id;
  final String name;
  final double totalArea;
  final double cultivatableArea;
  final String soilType;
  final double? locationLat;
  final double? locationLng;
  final bool gpsReady;
  final FieldBoundary? boundary;
  final int zoneCount;
  final List<FieldMapActiveCrop> activeCrops;

  const FieldMapField({
    required this.id,
    required this.name,
    required this.totalArea,
    required this.cultivatableArea,
    required this.soilType,
    this.locationLat,
    this.locationLng,
    required this.gpsReady,
    this.boundary,
    required this.zoneCount,
    required this.activeCrops,
  });

  factory FieldMapField.fromJson(Map<String, dynamic> json) => FieldMapField(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Field',
        totalArea: (json['totalArea'] as num? ?? 0).toDouble(),
        cultivatableArea: (json['cultivatableArea'] as num? ?? 0).toDouble(),
        soilType: json['soilType'] as String? ?? 'Not set',
        locationLat: (json['locationLat'] as num?)?.toDouble(),
        locationLng: (json['locationLng'] as num?)?.toDouble(),
        gpsReady: json['gpsReady'] as bool? ?? false,
        boundary: json['boundary'] != null
            ? FieldBoundary.fromJson(json['boundary'] as Map<String, dynamic>)
            : null,
        zoneCount: (json['zoneCount'] as num? ?? 0).toInt(),
        activeCrops: (json['activeCrops'] as List? ?? const [])
            .map((e) =>
                FieldMapActiveCrop.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class FieldMapData {
  final String farmName;
  final FieldMapReadiness readiness;
  final List<FieldMapField> fields;
  final List<FarmMarker> markers;

  const FieldMapData({
    required this.farmName,
    required this.readiness,
    required this.fields,
    required this.markers,
  });

  factory FieldMapData.fromJson(Map<String, dynamic> json) {
    final farm = json['farm'] as Map<String, dynamic>?;
    return FieldMapData(
      farmName: farm?['name'] as String? ?? 'Farm',
      readiness: FieldMapReadiness.fromJson(
          json['readiness'] as Map<String, dynamic>? ?? const {}),
      fields: (json['fields'] as List? ?? const [])
          .map((e) => FieldMapField.fromJson(e as Map<String, dynamic>))
          .toList(),
      markers: (json['markers'] as List? ?? const [])
          .map((e) => FarmMarker.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Extracts the first ring of coordinates from a GeoJSON Feature or bare
/// Polygon/MultiPolygon geometry as `[lat, lng]` pairs (GeoJSON itself is
/// `[lng, lat]`).
List<List<double>> _ringFromGeoJson(Map<String, dynamic> geoJson) {
  final geometry = geoJson['type'] == 'Feature'
      ? geoJson['geometry'] as Map<String, dynamic>?
      : geoJson;
  var coordinates = geometry?['coordinates'];
  if (coordinates is! List || coordinates.isEmpty) return const [];

  // Polygon.coordinates = [ring, ...]; MultiPolygon.coordinates =
  // [[ring, ...], ...] (one extra level of nesting). Unwrap MultiPolygon to
  // its first polygon's rings so both shapes land on the same "list of
  // rings" structure below.
  if (geometry?['type'] == 'MultiPolygon') {
    final firstPolygon = coordinates.first;
    if (firstPolygon is! List || firstPolygon.isEmpty) return const [];
    coordinates = firstPolygon;
  }

  final ring = coordinates.first;
  if (ring is! List) return const [];

  return ring
      .whereType<List>()
      .where((point) =>
          point.length >= 2 && point[0] is num && point[1] is num)
      .map((point) => [
            (point[1] as num).toDouble(),
            (point[0] as num).toDouble(),
          ])
      .toList();
}
