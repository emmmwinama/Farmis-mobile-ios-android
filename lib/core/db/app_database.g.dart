// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FarmProfileTable extends FarmProfile
    with TableInfo<$FarmProfileTable, FarmProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationLatMeta =
      const VerificationMeta('locationLat');
  @override
  late final GeneratedColumn<double> locationLat = GeneratedColumn<double>(
      'location_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _locationLngMeta =
      const VerificationMeta('locationLng');
  @override
  late final GeneratedColumn<double> locationLng = GeneratedColumn<double>(
      'location_lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, location, locationLat, locationLng, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_profile';
  @override
  VerificationContext validateIntegrity(Insertable<FarmProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('location_lat')) {
      context.handle(
          _locationLatMeta,
          locationLat.isAcceptableOrUnknown(
              data['location_lat']!, _locationLatMeta));
    }
    if (data.containsKey('location_lng')) {
      context.handle(
          _locationLngMeta,
          locationLng.isAcceptableOrUnknown(
              data['location_lng']!, _locationLngMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      locationLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}location_lat']),
      locationLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}location_lng']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FarmProfileTable createAlias(String alias) {
    return $FarmProfileTable(attachedDatabase, alias);
  }
}

class FarmProfileData extends DataClass implements Insertable<FarmProfileData> {
  final String id;
  final String name;
  final String location;
  final double? locationLat;
  final double? locationLng;
  final DateTime createdAt;
  const FarmProfileData(
      {required this.id,
      required this.name,
      required this.location,
      this.locationLat,
      this.locationLng,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || locationLat != null) {
      map['location_lat'] = Variable<double>(locationLat);
    }
    if (!nullToAbsent || locationLng != null) {
      map['location_lng'] = Variable<double>(locationLng);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FarmProfileCompanion toCompanion(bool nullToAbsent) {
    return FarmProfileCompanion(
      id: Value(id),
      name: Value(name),
      location: Value(location),
      locationLat: locationLat == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLat),
      locationLng: locationLng == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLng),
      createdAt: Value(createdAt),
    );
  }

  factory FarmProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmProfileData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String>(json['location']),
      locationLat: serializer.fromJson<double?>(json['locationLat']),
      locationLng: serializer.fromJson<double?>(json['locationLng']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String>(location),
      'locationLat': serializer.toJson<double?>(locationLat),
      'locationLng': serializer.toJson<double?>(locationLng),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FarmProfileData copyWith(
          {String? id,
          String? name,
          String? location,
          Value<double?> locationLat = const Value.absent(),
          Value<double?> locationLng = const Value.absent(),
          DateTime? createdAt}) =>
      FarmProfileData(
        id: id ?? this.id,
        name: name ?? this.name,
        location: location ?? this.location,
        locationLat: locationLat.present ? locationLat.value : this.locationLat,
        locationLng: locationLng.present ? locationLng.value : this.locationLng,
        createdAt: createdAt ?? this.createdAt,
      );
  FarmProfileData copyWithCompanion(FarmProfileCompanion data) {
    return FarmProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      locationLat:
          data.locationLat.present ? data.locationLat.value : this.locationLat,
      locationLng:
          data.locationLng.present ? data.locationLng.value : this.locationLng,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, location, locationLat, locationLng, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.locationLat == this.locationLat &&
          other.locationLng == this.locationLng &&
          other.createdAt == this.createdAt);
}

class FarmProfileCompanion extends UpdateCompanion<FarmProfileData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> location;
  final Value<double?> locationLat;
  final Value<double?> locationLng;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FarmProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmProfileCompanion.insert({
    required String id,
    required String name,
    required String location,
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        location = Value(location),
        createdAt = Value(createdAt);
  static Insertable<FarmProfileData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<double>? locationLat,
    Expression<double>? locationLng,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmProfileCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? location,
      Value<double?>? locationLat,
      Value<double?>? locationLng,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return FarmProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (locationLat.present) {
      map['location_lat'] = Variable<double>(locationLat.value);
    }
    if (locationLng.present) {
      map['location_lng'] = Variable<double>(locationLng.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FieldsTable extends Fields with TableInfo<$FieldsTable, Field> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalAreaMeta =
      const VerificationMeta('totalArea');
  @override
  late final GeneratedColumn<double> totalArea = GeneratedColumn<double>(
      'total_area', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _cultivatableAreaMeta =
      const VerificationMeta('cultivatableArea');
  @override
  late final GeneratedColumn<double> cultivatableArea = GeneratedColumn<double>(
      'cultivatable_area', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _soilTypeMeta =
      const VerificationMeta('soilType');
  @override
  late final GeneratedColumn<String> soilType = GeneratedColumn<String>(
      'soil_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationLatMeta =
      const VerificationMeta('locationLat');
  @override
  late final GeneratedColumn<double> locationLat = GeneratedColumn<double>(
      'location_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _locationLngMeta =
      const VerificationMeta('locationLng');
  @override
  late final GeneratedColumn<double> locationLng = GeneratedColumn<double>(
      'location_lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        totalArea,
        cultivatableArea,
        soilType,
        locationLat,
        locationLng,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fields';
  @override
  VerificationContext validateIntegrity(Insertable<Field> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('total_area')) {
      context.handle(_totalAreaMeta,
          totalArea.isAcceptableOrUnknown(data['total_area']!, _totalAreaMeta));
    } else if (isInserting) {
      context.missing(_totalAreaMeta);
    }
    if (data.containsKey('cultivatable_area')) {
      context.handle(
          _cultivatableAreaMeta,
          cultivatableArea.isAcceptableOrUnknown(
              data['cultivatable_area']!, _cultivatableAreaMeta));
    } else if (isInserting) {
      context.missing(_cultivatableAreaMeta);
    }
    if (data.containsKey('soil_type')) {
      context.handle(_soilTypeMeta,
          soilType.isAcceptableOrUnknown(data['soil_type']!, _soilTypeMeta));
    } else if (isInserting) {
      context.missing(_soilTypeMeta);
    }
    if (data.containsKey('location_lat')) {
      context.handle(
          _locationLatMeta,
          locationLat.isAcceptableOrUnknown(
              data['location_lat']!, _locationLatMeta));
    }
    if (data.containsKey('location_lng')) {
      context.handle(
          _locationLngMeta,
          locationLng.isAcceptableOrUnknown(
              data['location_lng']!, _locationLngMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Field map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Field(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      totalArea: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_area'])!,
      cultivatableArea: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}cultivatable_area'])!,
      soilType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}soil_type'])!,
      locationLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}location_lat']),
      locationLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}location_lng']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FieldsTable createAlias(String alias) {
    return $FieldsTable(attachedDatabase, alias);
  }
}

class Field extends DataClass implements Insertable<Field> {
  final String id;
  final String name;
  final double totalArea;
  final double cultivatableArea;
  final String soilType;
  final double? locationLat;
  final double? locationLng;
  final String? notes;
  final DateTime createdAt;
  const Field(
      {required this.id,
      required this.name,
      required this.totalArea,
      required this.cultivatableArea,
      required this.soilType,
      this.locationLat,
      this.locationLng,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['total_area'] = Variable<double>(totalArea);
    map['cultivatable_area'] = Variable<double>(cultivatableArea);
    map['soil_type'] = Variable<String>(soilType);
    if (!nullToAbsent || locationLat != null) {
      map['location_lat'] = Variable<double>(locationLat);
    }
    if (!nullToAbsent || locationLng != null) {
      map['location_lng'] = Variable<double>(locationLng);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FieldsCompanion toCompanion(bool nullToAbsent) {
    return FieldsCompanion(
      id: Value(id),
      name: Value(name),
      totalArea: Value(totalArea),
      cultivatableArea: Value(cultivatableArea),
      soilType: Value(soilType),
      locationLat: locationLat == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLat),
      locationLng: locationLng == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLng),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Field.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Field(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      totalArea: serializer.fromJson<double>(json['totalArea']),
      cultivatableArea: serializer.fromJson<double>(json['cultivatableArea']),
      soilType: serializer.fromJson<String>(json['soilType']),
      locationLat: serializer.fromJson<double?>(json['locationLat']),
      locationLng: serializer.fromJson<double?>(json['locationLng']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'totalArea': serializer.toJson<double>(totalArea),
      'cultivatableArea': serializer.toJson<double>(cultivatableArea),
      'soilType': serializer.toJson<String>(soilType),
      'locationLat': serializer.toJson<double?>(locationLat),
      'locationLng': serializer.toJson<double?>(locationLng),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Field copyWith(
          {String? id,
          String? name,
          double? totalArea,
          double? cultivatableArea,
          String? soilType,
          Value<double?> locationLat = const Value.absent(),
          Value<double?> locationLng = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      Field(
        id: id ?? this.id,
        name: name ?? this.name,
        totalArea: totalArea ?? this.totalArea,
        cultivatableArea: cultivatableArea ?? this.cultivatableArea,
        soilType: soilType ?? this.soilType,
        locationLat: locationLat.present ? locationLat.value : this.locationLat,
        locationLng: locationLng.present ? locationLng.value : this.locationLng,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  Field copyWithCompanion(FieldsCompanion data) {
    return Field(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      totalArea: data.totalArea.present ? data.totalArea.value : this.totalArea,
      cultivatableArea: data.cultivatableArea.present
          ? data.cultivatableArea.value
          : this.cultivatableArea,
      soilType: data.soilType.present ? data.soilType.value : this.soilType,
      locationLat:
          data.locationLat.present ? data.locationLat.value : this.locationLat,
      locationLng:
          data.locationLng.present ? data.locationLng.value : this.locationLng,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Field(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('totalArea: $totalArea, ')
          ..write('cultivatableArea: $cultivatableArea, ')
          ..write('soilType: $soilType, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, totalArea, cultivatableArea,
      soilType, locationLat, locationLng, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Field &&
          other.id == this.id &&
          other.name == this.name &&
          other.totalArea == this.totalArea &&
          other.cultivatableArea == this.cultivatableArea &&
          other.soilType == this.soilType &&
          other.locationLat == this.locationLat &&
          other.locationLng == this.locationLng &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class FieldsCompanion extends UpdateCompanion<Field> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> totalArea;
  final Value<double> cultivatableArea;
  final Value<String> soilType;
  final Value<double?> locationLat;
  final Value<double?> locationLng;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FieldsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.totalArea = const Value.absent(),
    this.cultivatableArea = const Value.absent(),
    this.soilType = const Value.absent(),
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldsCompanion.insert({
    required String id,
    required String name,
    required double totalArea,
    required double cultivatableArea,
    required String soilType,
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        totalArea = Value(totalArea),
        cultivatableArea = Value(cultivatableArea),
        soilType = Value(soilType),
        createdAt = Value(createdAt);
  static Insertable<Field> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? totalArea,
    Expression<double>? cultivatableArea,
    Expression<String>? soilType,
    Expression<double>? locationLat,
    Expression<double>? locationLng,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (totalArea != null) 'total_area': totalArea,
      if (cultivatableArea != null) 'cultivatable_area': cultivatableArea,
      if (soilType != null) 'soil_type': soilType,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? totalArea,
      Value<double>? cultivatableArea,
      Value<String>? soilType,
      Value<double?>? locationLat,
      Value<double?>? locationLng,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return FieldsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      totalArea: totalArea ?? this.totalArea,
      cultivatableArea: cultivatableArea ?? this.cultivatableArea,
      soilType: soilType ?? this.soilType,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (totalArea.present) {
      map['total_area'] = Variable<double>(totalArea.value);
    }
    if (cultivatableArea.present) {
      map['cultivatable_area'] = Variable<double>(cultivatableArea.value);
    }
    if (soilType.present) {
      map['soil_type'] = Variable<String>(soilType.value);
    }
    if (locationLat.present) {
      map['location_lat'] = Variable<double>(locationLat.value);
    }
    if (locationLng.present) {
      map['location_lng'] = Variable<double>(locationLng.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('totalArea: $totalArea, ')
          ..write('cultivatableArea: $cultivatableArea, ')
          ..write('soilType: $soilType, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FieldBoundariesTable extends FieldBoundaries
    with TableInfo<$FieldBoundariesTable, FieldBoundaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldBoundariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldIdMeta =
      const VerificationMeta('fieldId');
  @override
  late final GeneratedColumn<String> fieldId = GeneratedColumn<String>(
      'field_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _geoJsonMeta =
      const VerificationMeta('geoJson');
  @override
  late final GeneratedColumn<String> geoJson = GeneratedColumn<String>(
      'geo_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _areaHaMeta = const VerificationMeta('areaHa');
  @override
  late final GeneratedColumn<double> areaHa = GeneratedColumn<double>(
      'area_ha', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _centroidLatMeta =
      const VerificationMeta('centroidLat');
  @override
  late final GeneratedColumn<double> centroidLat = GeneratedColumn<double>(
      'centroid_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _centroidLngMeta =
      const VerificationMeta('centroidLng');
  @override
  late final GeneratedColumn<double> centroidLng = GeneratedColumn<double>(
      'centroid_lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, fieldId, geoJson, areaHa, centroidLat, centroidLng];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_boundaries';
  @override
  VerificationContext validateIntegrity(Insertable<FieldBoundaryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('field_id')) {
      context.handle(_fieldIdMeta,
          fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta));
    } else if (isInserting) {
      context.missing(_fieldIdMeta);
    }
    if (data.containsKey('geo_json')) {
      context.handle(_geoJsonMeta,
          geoJson.isAcceptableOrUnknown(data['geo_json']!, _geoJsonMeta));
    } else if (isInserting) {
      context.missing(_geoJsonMeta);
    }
    if (data.containsKey('area_ha')) {
      context.handle(_areaHaMeta,
          areaHa.isAcceptableOrUnknown(data['area_ha']!, _areaHaMeta));
    }
    if (data.containsKey('centroid_lat')) {
      context.handle(
          _centroidLatMeta,
          centroidLat.isAcceptableOrUnknown(
              data['centroid_lat']!, _centroidLatMeta));
    }
    if (data.containsKey('centroid_lng')) {
      context.handle(
          _centroidLngMeta,
          centroidLng.isAcceptableOrUnknown(
              data['centroid_lng']!, _centroidLngMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FieldBoundaryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldBoundaryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_id'])!,
      geoJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}geo_json'])!,
      areaHa: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}area_ha']),
      centroidLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}centroid_lat']),
      centroidLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}centroid_lng']),
    );
  }

  @override
  $FieldBoundariesTable createAlias(String alias) {
    return $FieldBoundariesTable(attachedDatabase, alias);
  }
}

class FieldBoundaryRow extends DataClass
    implements Insertable<FieldBoundaryRow> {
  final String id;
  final String fieldId;
  final String geoJson;
  final double? areaHa;
  final double? centroidLat;
  final double? centroidLng;
  const FieldBoundaryRow(
      {required this.id,
      required this.fieldId,
      required this.geoJson,
      this.areaHa,
      this.centroidLat,
      this.centroidLng});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['field_id'] = Variable<String>(fieldId);
    map['geo_json'] = Variable<String>(geoJson);
    if (!nullToAbsent || areaHa != null) {
      map['area_ha'] = Variable<double>(areaHa);
    }
    if (!nullToAbsent || centroidLat != null) {
      map['centroid_lat'] = Variable<double>(centroidLat);
    }
    if (!nullToAbsent || centroidLng != null) {
      map['centroid_lng'] = Variable<double>(centroidLng);
    }
    return map;
  }

  FieldBoundariesCompanion toCompanion(bool nullToAbsent) {
    return FieldBoundariesCompanion(
      id: Value(id),
      fieldId: Value(fieldId),
      geoJson: Value(geoJson),
      areaHa:
          areaHa == null && nullToAbsent ? const Value.absent() : Value(areaHa),
      centroidLat: centroidLat == null && nullToAbsent
          ? const Value.absent()
          : Value(centroidLat),
      centroidLng: centroidLng == null && nullToAbsent
          ? const Value.absent()
          : Value(centroidLng),
    );
  }

  factory FieldBoundaryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldBoundaryRow(
      id: serializer.fromJson<String>(json['id']),
      fieldId: serializer.fromJson<String>(json['fieldId']),
      geoJson: serializer.fromJson<String>(json['geoJson']),
      areaHa: serializer.fromJson<double?>(json['areaHa']),
      centroidLat: serializer.fromJson<double?>(json['centroidLat']),
      centroidLng: serializer.fromJson<double?>(json['centroidLng']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fieldId': serializer.toJson<String>(fieldId),
      'geoJson': serializer.toJson<String>(geoJson),
      'areaHa': serializer.toJson<double?>(areaHa),
      'centroidLat': serializer.toJson<double?>(centroidLat),
      'centroidLng': serializer.toJson<double?>(centroidLng),
    };
  }

  FieldBoundaryRow copyWith(
          {String? id,
          String? fieldId,
          String? geoJson,
          Value<double?> areaHa = const Value.absent(),
          Value<double?> centroidLat = const Value.absent(),
          Value<double?> centroidLng = const Value.absent()}) =>
      FieldBoundaryRow(
        id: id ?? this.id,
        fieldId: fieldId ?? this.fieldId,
        geoJson: geoJson ?? this.geoJson,
        areaHa: areaHa.present ? areaHa.value : this.areaHa,
        centroidLat: centroidLat.present ? centroidLat.value : this.centroidLat,
        centroidLng: centroidLng.present ? centroidLng.value : this.centroidLng,
      );
  FieldBoundaryRow copyWithCompanion(FieldBoundariesCompanion data) {
    return FieldBoundaryRow(
      id: data.id.present ? data.id.value : this.id,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      geoJson: data.geoJson.present ? data.geoJson.value : this.geoJson,
      areaHa: data.areaHa.present ? data.areaHa.value : this.areaHa,
      centroidLat:
          data.centroidLat.present ? data.centroidLat.value : this.centroidLat,
      centroidLng:
          data.centroidLng.present ? data.centroidLng.value : this.centroidLng,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldBoundaryRow(')
          ..write('id: $id, ')
          ..write('fieldId: $fieldId, ')
          ..write('geoJson: $geoJson, ')
          ..write('areaHa: $areaHa, ')
          ..write('centroidLat: $centroidLat, ')
          ..write('centroidLng: $centroidLng')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fieldId, geoJson, areaHa, centroidLat, centroidLng);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldBoundaryRow &&
          other.id == this.id &&
          other.fieldId == this.fieldId &&
          other.geoJson == this.geoJson &&
          other.areaHa == this.areaHa &&
          other.centroidLat == this.centroidLat &&
          other.centroidLng == this.centroidLng);
}

class FieldBoundariesCompanion extends UpdateCompanion<FieldBoundaryRow> {
  final Value<String> id;
  final Value<String> fieldId;
  final Value<String> geoJson;
  final Value<double?> areaHa;
  final Value<double?> centroidLat;
  final Value<double?> centroidLng;
  final Value<int> rowid;
  const FieldBoundariesCompanion({
    this.id = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.geoJson = const Value.absent(),
    this.areaHa = const Value.absent(),
    this.centroidLat = const Value.absent(),
    this.centroidLng = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldBoundariesCompanion.insert({
    required String id,
    required String fieldId,
    required String geoJson,
    this.areaHa = const Value.absent(),
    this.centroidLat = const Value.absent(),
    this.centroidLng = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fieldId = Value(fieldId),
        geoJson = Value(geoJson);
  static Insertable<FieldBoundaryRow> custom({
    Expression<String>? id,
    Expression<String>? fieldId,
    Expression<String>? geoJson,
    Expression<double>? areaHa,
    Expression<double>? centroidLat,
    Expression<double>? centroidLng,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fieldId != null) 'field_id': fieldId,
      if (geoJson != null) 'geo_json': geoJson,
      if (areaHa != null) 'area_ha': areaHa,
      if (centroidLat != null) 'centroid_lat': centroidLat,
      if (centroidLng != null) 'centroid_lng': centroidLng,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldBoundariesCompanion copyWith(
      {Value<String>? id,
      Value<String>? fieldId,
      Value<String>? geoJson,
      Value<double?>? areaHa,
      Value<double?>? centroidLat,
      Value<double?>? centroidLng,
      Value<int>? rowid}) {
    return FieldBoundariesCompanion(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      geoJson: geoJson ?? this.geoJson,
      areaHa: areaHa ?? this.areaHa,
      centroidLat: centroidLat ?? this.centroidLat,
      centroidLng: centroidLng ?? this.centroidLng,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<String>(fieldId.value);
    }
    if (geoJson.present) {
      map['geo_json'] = Variable<String>(geoJson.value);
    }
    if (areaHa.present) {
      map['area_ha'] = Variable<double>(areaHa.value);
    }
    if (centroidLat.present) {
      map['centroid_lat'] = Variable<double>(centroidLat.value);
    }
    if (centroidLng.present) {
      map['centroid_lng'] = Variable<double>(centroidLng.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldBoundariesCompanion(')
          ..write('id: $id, ')
          ..write('fieldId: $fieldId, ')
          ..write('geoJson: $geoJson, ')
          ..write('areaHa: $areaHa, ')
          ..write('centroidLat: $centroidLat, ')
          ..write('centroidLng: $centroidLng, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FieldZonesTable extends FieldZones
    with TableInfo<$FieldZonesTable, FieldZoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _boundaryIdMeta =
      const VerificationMeta('boundaryId');
  @override
  late final GeneratedColumn<String> boundaryId = GeneratedColumn<String>(
      'boundary_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldIdMeta =
      const VerificationMeta('fieldId');
  @override
  late final GeneratedColumn<String> fieldId = GeneratedColumn<String>(
      'field_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cropFieldIdMeta =
      const VerificationMeta('cropFieldId');
  @override
  late final GeneratedColumn<String> cropFieldId = GeneratedColumn<String>(
      'crop_field_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _geoJsonMeta =
      const VerificationMeta('geoJson');
  @override
  late final GeneratedColumn<String> geoJson = GeneratedColumn<String>(
      'geo_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _areaHaMeta = const VerificationMeta('areaHa');
  @override
  late final GeneratedColumn<double> areaHa = GeneratedColumn<double>(
      'area_ha', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
      'colour', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        boundaryId,
        fieldId,
        name,
        type,
        cropFieldId,
        geoJson,
        areaHa,
        colour,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_zones';
  @override
  VerificationContext validateIntegrity(Insertable<FieldZoneRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('boundary_id')) {
      context.handle(
          _boundaryIdMeta,
          boundaryId.isAcceptableOrUnknown(
              data['boundary_id']!, _boundaryIdMeta));
    } else if (isInserting) {
      context.missing(_boundaryIdMeta);
    }
    if (data.containsKey('field_id')) {
      context.handle(_fieldIdMeta,
          fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta));
    } else if (isInserting) {
      context.missing(_fieldIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('crop_field_id')) {
      context.handle(
          _cropFieldIdMeta,
          cropFieldId.isAcceptableOrUnknown(
              data['crop_field_id']!, _cropFieldIdMeta));
    }
    if (data.containsKey('geo_json')) {
      context.handle(_geoJsonMeta,
          geoJson.isAcceptableOrUnknown(data['geo_json']!, _geoJsonMeta));
    } else if (isInserting) {
      context.missing(_geoJsonMeta);
    }
    if (data.containsKey('area_ha')) {
      context.handle(_areaHaMeta,
          areaHa.isAcceptableOrUnknown(data['area_ha']!, _areaHaMeta));
    }
    if (data.containsKey('colour')) {
      context.handle(_colourMeta,
          colour.isAcceptableOrUnknown(data['colour']!, _colourMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FieldZoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldZoneRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      boundaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}boundary_id'])!,
      fieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      cropFieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_field_id']),
      geoJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}geo_json'])!,
      areaHa: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}area_ha']),
      colour: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}colour']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $FieldZonesTable createAlias(String alias) {
    return $FieldZonesTable(attachedDatabase, alias);
  }
}

class FieldZoneRow extends DataClass implements Insertable<FieldZoneRow> {
  final String id;
  final String boundaryId;
  final String fieldId;
  final String name;
  final String type;
  final String? cropFieldId;
  final String geoJson;
  final double? areaHa;
  final String? colour;
  final String? notes;
  const FieldZoneRow(
      {required this.id,
      required this.boundaryId,
      required this.fieldId,
      required this.name,
      required this.type,
      this.cropFieldId,
      required this.geoJson,
      this.areaHa,
      this.colour,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['boundary_id'] = Variable<String>(boundaryId);
    map['field_id'] = Variable<String>(fieldId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || cropFieldId != null) {
      map['crop_field_id'] = Variable<String>(cropFieldId);
    }
    map['geo_json'] = Variable<String>(geoJson);
    if (!nullToAbsent || areaHa != null) {
      map['area_ha'] = Variable<double>(areaHa);
    }
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String>(colour);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  FieldZonesCompanion toCompanion(bool nullToAbsent) {
    return FieldZonesCompanion(
      id: Value(id),
      boundaryId: Value(boundaryId),
      fieldId: Value(fieldId),
      name: Value(name),
      type: Value(type),
      cropFieldId: cropFieldId == null && nullToAbsent
          ? const Value.absent()
          : Value(cropFieldId),
      geoJson: Value(geoJson),
      areaHa:
          areaHa == null && nullToAbsent ? const Value.absent() : Value(areaHa),
      colour:
          colour == null && nullToAbsent ? const Value.absent() : Value(colour),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory FieldZoneRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldZoneRow(
      id: serializer.fromJson<String>(json['id']),
      boundaryId: serializer.fromJson<String>(json['boundaryId']),
      fieldId: serializer.fromJson<String>(json['fieldId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      cropFieldId: serializer.fromJson<String?>(json['cropFieldId']),
      geoJson: serializer.fromJson<String>(json['geoJson']),
      areaHa: serializer.fromJson<double?>(json['areaHa']),
      colour: serializer.fromJson<String?>(json['colour']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'boundaryId': serializer.toJson<String>(boundaryId),
      'fieldId': serializer.toJson<String>(fieldId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'cropFieldId': serializer.toJson<String?>(cropFieldId),
      'geoJson': serializer.toJson<String>(geoJson),
      'areaHa': serializer.toJson<double?>(areaHa),
      'colour': serializer.toJson<String?>(colour),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  FieldZoneRow copyWith(
          {String? id,
          String? boundaryId,
          String? fieldId,
          String? name,
          String? type,
          Value<String?> cropFieldId = const Value.absent(),
          String? geoJson,
          Value<double?> areaHa = const Value.absent(),
          Value<String?> colour = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      FieldZoneRow(
        id: id ?? this.id,
        boundaryId: boundaryId ?? this.boundaryId,
        fieldId: fieldId ?? this.fieldId,
        name: name ?? this.name,
        type: type ?? this.type,
        cropFieldId: cropFieldId.present ? cropFieldId.value : this.cropFieldId,
        geoJson: geoJson ?? this.geoJson,
        areaHa: areaHa.present ? areaHa.value : this.areaHa,
        colour: colour.present ? colour.value : this.colour,
        notes: notes.present ? notes.value : this.notes,
      );
  FieldZoneRow copyWithCompanion(FieldZonesCompanion data) {
    return FieldZoneRow(
      id: data.id.present ? data.id.value : this.id,
      boundaryId:
          data.boundaryId.present ? data.boundaryId.value : this.boundaryId,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      cropFieldId:
          data.cropFieldId.present ? data.cropFieldId.value : this.cropFieldId,
      geoJson: data.geoJson.present ? data.geoJson.value : this.geoJson,
      areaHa: data.areaHa.present ? data.areaHa.value : this.areaHa,
      colour: data.colour.present ? data.colour.value : this.colour,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldZoneRow(')
          ..write('id: $id, ')
          ..write('boundaryId: $boundaryId, ')
          ..write('fieldId: $fieldId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('cropFieldId: $cropFieldId, ')
          ..write('geoJson: $geoJson, ')
          ..write('areaHa: $areaHa, ')
          ..write('colour: $colour, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, boundaryId, fieldId, name, type,
      cropFieldId, geoJson, areaHa, colour, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldZoneRow &&
          other.id == this.id &&
          other.boundaryId == this.boundaryId &&
          other.fieldId == this.fieldId &&
          other.name == this.name &&
          other.type == this.type &&
          other.cropFieldId == this.cropFieldId &&
          other.geoJson == this.geoJson &&
          other.areaHa == this.areaHa &&
          other.colour == this.colour &&
          other.notes == this.notes);
}

class FieldZonesCompanion extends UpdateCompanion<FieldZoneRow> {
  final Value<String> id;
  final Value<String> boundaryId;
  final Value<String> fieldId;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> cropFieldId;
  final Value<String> geoJson;
  final Value<double?> areaHa;
  final Value<String?> colour;
  final Value<String?> notes;
  final Value<int> rowid;
  const FieldZonesCompanion({
    this.id = const Value.absent(),
    this.boundaryId = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.cropFieldId = const Value.absent(),
    this.geoJson = const Value.absent(),
    this.areaHa = const Value.absent(),
    this.colour = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldZonesCompanion.insert({
    required String id,
    required String boundaryId,
    required String fieldId,
    required String name,
    required String type,
    this.cropFieldId = const Value.absent(),
    required String geoJson,
    this.areaHa = const Value.absent(),
    this.colour = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        boundaryId = Value(boundaryId),
        fieldId = Value(fieldId),
        name = Value(name),
        type = Value(type),
        geoJson = Value(geoJson);
  static Insertable<FieldZoneRow> custom({
    Expression<String>? id,
    Expression<String>? boundaryId,
    Expression<String>? fieldId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? cropFieldId,
    Expression<String>? geoJson,
    Expression<double>? areaHa,
    Expression<String>? colour,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boundaryId != null) 'boundary_id': boundaryId,
      if (fieldId != null) 'field_id': fieldId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (cropFieldId != null) 'crop_field_id': cropFieldId,
      if (geoJson != null) 'geo_json': geoJson,
      if (areaHa != null) 'area_ha': areaHa,
      if (colour != null) 'colour': colour,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldZonesCompanion copyWith(
      {Value<String>? id,
      Value<String>? boundaryId,
      Value<String>? fieldId,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? cropFieldId,
      Value<String>? geoJson,
      Value<double?>? areaHa,
      Value<String?>? colour,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return FieldZonesCompanion(
      id: id ?? this.id,
      boundaryId: boundaryId ?? this.boundaryId,
      fieldId: fieldId ?? this.fieldId,
      name: name ?? this.name,
      type: type ?? this.type,
      cropFieldId: cropFieldId ?? this.cropFieldId,
      geoJson: geoJson ?? this.geoJson,
      areaHa: areaHa ?? this.areaHa,
      colour: colour ?? this.colour,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (boundaryId.present) {
      map['boundary_id'] = Variable<String>(boundaryId.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<String>(fieldId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (cropFieldId.present) {
      map['crop_field_id'] = Variable<String>(cropFieldId.value);
    }
    if (geoJson.present) {
      map['geo_json'] = Variable<String>(geoJson.value);
    }
    if (areaHa.present) {
      map['area_ha'] = Variable<double>(areaHa.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldZonesCompanion(')
          ..write('id: $id, ')
          ..write('boundaryId: $boundaryId, ')
          ..write('fieldId: $fieldId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('cropFieldId: $cropFieldId, ')
          ..write('geoJson: $geoJson, ')
          ..write('areaHa: $areaHa, ')
          ..write('colour: $colour, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmMarkersTable extends FarmMarkers
    with TableInfo<$FarmMarkersTable, FarmMarkerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmMarkersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldIdMeta =
      const VerificationMeta('fieldId');
  @override
  late final GeneratedColumn<String> fieldId = GeneratedColumn<String>(
      'field_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, fieldId, type, label, lat, lng, notes, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_markers';
  @override
  VerificationContext validateIntegrity(Insertable<FarmMarkerRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('field_id')) {
      context.handle(_fieldIdMeta,
          fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmMarkerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmMarkerRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
    );
  }

  @override
  $FarmMarkersTable createAlias(String alias) {
    return $FarmMarkersTable(attachedDatabase, alias);
  }
}

class FarmMarkerRow extends DataClass implements Insertable<FarmMarkerRow> {
  final String id;
  final String? fieldId;
  final String type;
  final String label;
  final double lat;
  final double lng;
  final String? notes;
  final String? icon;
  const FarmMarkerRow(
      {required this.id,
      this.fieldId,
      required this.type,
      required this.label,
      required this.lat,
      required this.lng,
      this.notes,
      this.icon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || fieldId != null) {
      map['field_id'] = Variable<String>(fieldId);
    }
    map['type'] = Variable<String>(type);
    map['label'] = Variable<String>(label);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  FarmMarkersCompanion toCompanion(bool nullToAbsent) {
    return FarmMarkersCompanion(
      id: Value(id),
      fieldId: fieldId == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldId),
      type: Value(type),
      label: Value(label),
      lat: Value(lat),
      lng: Value(lng),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory FarmMarkerRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmMarkerRow(
      id: serializer.fromJson<String>(json['id']),
      fieldId: serializer.fromJson<String?>(json['fieldId']),
      type: serializer.fromJson<String>(json['type']),
      label: serializer.fromJson<String>(json['label']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      notes: serializer.fromJson<String?>(json['notes']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fieldId': serializer.toJson<String?>(fieldId),
      'type': serializer.toJson<String>(type),
      'label': serializer.toJson<String>(label),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'notes': serializer.toJson<String?>(notes),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  FarmMarkerRow copyWith(
          {String? id,
          Value<String?> fieldId = const Value.absent(),
          String? type,
          String? label,
          double? lat,
          double? lng,
          Value<String?> notes = const Value.absent(),
          Value<String?> icon = const Value.absent()}) =>
      FarmMarkerRow(
        id: id ?? this.id,
        fieldId: fieldId.present ? fieldId.value : this.fieldId,
        type: type ?? this.type,
        label: label ?? this.label,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        notes: notes.present ? notes.value : this.notes,
        icon: icon.present ? icon.value : this.icon,
      );
  FarmMarkerRow copyWithCompanion(FarmMarkersCompanion data) {
    return FarmMarkerRow(
      id: data.id.present ? data.id.value : this.id,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      type: data.type.present ? data.type.value : this.type,
      label: data.label.present ? data.label.value : this.label,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      notes: data.notes.present ? data.notes.value : this.notes,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmMarkerRow(')
          ..write('id: $id, ')
          ..write('fieldId: $fieldId, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('notes: $notes, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fieldId, type, label, lat, lng, notes, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmMarkerRow &&
          other.id == this.id &&
          other.fieldId == this.fieldId &&
          other.type == this.type &&
          other.label == this.label &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.notes == this.notes &&
          other.icon == this.icon);
}

class FarmMarkersCompanion extends UpdateCompanion<FarmMarkerRow> {
  final Value<String> id;
  final Value<String?> fieldId;
  final Value<String> type;
  final Value<String> label;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String?> notes;
  final Value<String?> icon;
  final Value<int> rowid;
  const FarmMarkersCompanion({
    this.id = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.type = const Value.absent(),
    this.label = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.notes = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmMarkersCompanion.insert({
    required String id,
    this.fieldId = const Value.absent(),
    required String type,
    required String label,
    required double lat,
    required double lng,
    this.notes = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        label = Value(label),
        lat = Value(lat),
        lng = Value(lng);
  static Insertable<FarmMarkerRow> custom({
    Expression<String>? id,
    Expression<String>? fieldId,
    Expression<String>? type,
    Expression<String>? label,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? notes,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fieldId != null) 'field_id': fieldId,
      if (type != null) 'type': type,
      if (label != null) 'label': label,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (notes != null) 'notes': notes,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmMarkersCompanion copyWith(
      {Value<String>? id,
      Value<String?>? fieldId,
      Value<String>? type,
      Value<String>? label,
      Value<double>? lat,
      Value<double>? lng,
      Value<String?>? notes,
      Value<String?>? icon,
      Value<int>? rowid}) {
    return FarmMarkersCompanion(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      type: type ?? this.type,
      label: label ?? this.label,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      notes: notes ?? this.notes,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<String>(fieldId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmMarkersCompanion(')
          ..write('id: $id, ')
          ..write('fieldId: $fieldId, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('notes: $notes, ')
          ..write('icon: $icon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CropTypesTable extends CropTypes
    with TableInfo<$CropTypesTable, CropTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, name, isCustom];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crop_types';
  @override
  VerificationContext validateIntegrity(Insertable<CropTypeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CropTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CropTypeRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
    );
  }

  @override
  $CropTypesTable createAlias(String alias) {
    return $CropTypesTable(attachedDatabase, alias);
  }
}

class CropTypeRow extends DataClass implements Insertable<CropTypeRow> {
  final String id;
  final String name;
  final bool isCustom;
  const CropTypeRow(
      {required this.id, required this.name, required this.isCustom});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  CropTypesCompanion toCompanion(bool nullToAbsent) {
    return CropTypesCompanion(
      id: Value(id),
      name: Value(name),
      isCustom: Value(isCustom),
    );
  }

  factory CropTypeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CropTypeRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  CropTypeRow copyWith({String? id, String? name, bool? isCustom}) =>
      CropTypeRow(
        id: id ?? this.id,
        name: name ?? this.name,
        isCustom: isCustom ?? this.isCustom,
      );
  CropTypeRow copyWithCompanion(CropTypesCompanion data) {
    return CropTypeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CropTypeRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isCustom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CropTypeRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.isCustom == this.isCustom);
}

class CropTypesCompanion extends UpdateCompanion<CropTypeRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isCustom;
  final Value<int> rowid;
  const CropTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CropTypesCompanion.insert({
    required String id,
    required String name,
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CropTypeRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isCustom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isCustom != null) 'is_custom': isCustom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CropTypesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<bool>? isCustom,
      Value<int>? rowid}) {
    return CropTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCustom: $isCustom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CropFieldsTable extends CropFields
    with TableInfo<$CropFieldsTable, CropField> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropFieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cropTypeIdMeta =
      const VerificationMeta('cropTypeId');
  @override
  late final GeneratedColumn<String> cropTypeId = GeneratedColumn<String>(
      'crop_type_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldIdMeta =
      const VerificationMeta('fieldId');
  @override
  late final GeneratedColumn<String> fieldId = GeneratedColumn<String>(
      'field_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _varietyMeta =
      const VerificationMeta('variety');
  @override
  late final GeneratedColumn<String> variety = GeneratedColumn<String>(
      'variety', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _areaPlantedMeta =
      const VerificationMeta('areaPlanted');
  @override
  late final GeneratedColumn<double> areaPlanted = GeneratedColumn<double>(
      'area_planted', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
      'season', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plantingDateMeta =
      const VerificationMeta('plantingDate');
  @override
  late final GeneratedColumn<DateTime> plantingDate = GeneratedColumn<DateTime>(
      'planting_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expectedHarvestDateMeta =
      const VerificationMeta('expectedHarvestDate');
  @override
  late final GeneratedColumn<DateTime> expectedHarvestDate =
      GeneratedColumn<DateTime>('expected_harvest_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Active'));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cropTypeId,
        fieldId,
        variety,
        areaPlanted,
        season,
        plantingDate,
        expectedHarvestDate,
        status,
        isArchived,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crop_fields';
  @override
  VerificationContext validateIntegrity(Insertable<CropField> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('crop_type_id')) {
      context.handle(
          _cropTypeIdMeta,
          cropTypeId.isAcceptableOrUnknown(
              data['crop_type_id']!, _cropTypeIdMeta));
    } else if (isInserting) {
      context.missing(_cropTypeIdMeta);
    }
    if (data.containsKey('field_id')) {
      context.handle(_fieldIdMeta,
          fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta));
    } else if (isInserting) {
      context.missing(_fieldIdMeta);
    }
    if (data.containsKey('variety')) {
      context.handle(_varietyMeta,
          variety.isAcceptableOrUnknown(data['variety']!, _varietyMeta));
    } else if (isInserting) {
      context.missing(_varietyMeta);
    }
    if (data.containsKey('area_planted')) {
      context.handle(
          _areaPlantedMeta,
          areaPlanted.isAcceptableOrUnknown(
              data['area_planted']!, _areaPlantedMeta));
    } else if (isInserting) {
      context.missing(_areaPlantedMeta);
    }
    if (data.containsKey('season')) {
      context.handle(_seasonMeta,
          season.isAcceptableOrUnknown(data['season']!, _seasonMeta));
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('planting_date')) {
      context.handle(
          _plantingDateMeta,
          plantingDate.isAcceptableOrUnknown(
              data['planting_date']!, _plantingDateMeta));
    } else if (isInserting) {
      context.missing(_plantingDateMeta);
    }
    if (data.containsKey('expected_harvest_date')) {
      context.handle(
          _expectedHarvestDateMeta,
          expectedHarvestDate.isAcceptableOrUnknown(
              data['expected_harvest_date']!, _expectedHarvestDateMeta));
    } else if (isInserting) {
      context.missing(_expectedHarvestDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CropField map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CropField(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cropTypeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_type_id'])!,
      fieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_id'])!,
      variety: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variety'])!,
      areaPlanted: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}area_planted'])!,
      season: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}season'])!,
      plantingDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}planting_date'])!,
      expectedHarvestDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}expected_harvest_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CropFieldsTable createAlias(String alias) {
    return $CropFieldsTable(attachedDatabase, alias);
  }
}

class CropField extends DataClass implements Insertable<CropField> {
  final String id;
  final String cropTypeId;
  final String fieldId;
  final String variety;
  final double areaPlanted;
  final String season;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final String status;
  final bool isArchived;
  final DateTime createdAt;
  const CropField(
      {required this.id,
      required this.cropTypeId,
      required this.fieldId,
      required this.variety,
      required this.areaPlanted,
      required this.season,
      required this.plantingDate,
      required this.expectedHarvestDate,
      required this.status,
      required this.isArchived,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['crop_type_id'] = Variable<String>(cropTypeId);
    map['field_id'] = Variable<String>(fieldId);
    map['variety'] = Variable<String>(variety);
    map['area_planted'] = Variable<double>(areaPlanted);
    map['season'] = Variable<String>(season);
    map['planting_date'] = Variable<DateTime>(plantingDate);
    map['expected_harvest_date'] = Variable<DateTime>(expectedHarvestDate);
    map['status'] = Variable<String>(status);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CropFieldsCompanion toCompanion(bool nullToAbsent) {
    return CropFieldsCompanion(
      id: Value(id),
      cropTypeId: Value(cropTypeId),
      fieldId: Value(fieldId),
      variety: Value(variety),
      areaPlanted: Value(areaPlanted),
      season: Value(season),
      plantingDate: Value(plantingDate),
      expectedHarvestDate: Value(expectedHarvestDate),
      status: Value(status),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory CropField.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CropField(
      id: serializer.fromJson<String>(json['id']),
      cropTypeId: serializer.fromJson<String>(json['cropTypeId']),
      fieldId: serializer.fromJson<String>(json['fieldId']),
      variety: serializer.fromJson<String>(json['variety']),
      areaPlanted: serializer.fromJson<double>(json['areaPlanted']),
      season: serializer.fromJson<String>(json['season']),
      plantingDate: serializer.fromJson<DateTime>(json['plantingDate']),
      expectedHarvestDate:
          serializer.fromJson<DateTime>(json['expectedHarvestDate']),
      status: serializer.fromJson<String>(json['status']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cropTypeId': serializer.toJson<String>(cropTypeId),
      'fieldId': serializer.toJson<String>(fieldId),
      'variety': serializer.toJson<String>(variety),
      'areaPlanted': serializer.toJson<double>(areaPlanted),
      'season': serializer.toJson<String>(season),
      'plantingDate': serializer.toJson<DateTime>(plantingDate),
      'expectedHarvestDate': serializer.toJson<DateTime>(expectedHarvestDate),
      'status': serializer.toJson<String>(status),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CropField copyWith(
          {String? id,
          String? cropTypeId,
          String? fieldId,
          String? variety,
          double? areaPlanted,
          String? season,
          DateTime? plantingDate,
          DateTime? expectedHarvestDate,
          String? status,
          bool? isArchived,
          DateTime? createdAt}) =>
      CropField(
        id: id ?? this.id,
        cropTypeId: cropTypeId ?? this.cropTypeId,
        fieldId: fieldId ?? this.fieldId,
        variety: variety ?? this.variety,
        areaPlanted: areaPlanted ?? this.areaPlanted,
        season: season ?? this.season,
        plantingDate: plantingDate ?? this.plantingDate,
        expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
        status: status ?? this.status,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
      );
  CropField copyWithCompanion(CropFieldsCompanion data) {
    return CropField(
      id: data.id.present ? data.id.value : this.id,
      cropTypeId:
          data.cropTypeId.present ? data.cropTypeId.value : this.cropTypeId,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      variety: data.variety.present ? data.variety.value : this.variety,
      areaPlanted:
          data.areaPlanted.present ? data.areaPlanted.value : this.areaPlanted,
      season: data.season.present ? data.season.value : this.season,
      plantingDate: data.plantingDate.present
          ? data.plantingDate.value
          : this.plantingDate,
      expectedHarvestDate: data.expectedHarvestDate.present
          ? data.expectedHarvestDate.value
          : this.expectedHarvestDate,
      status: data.status.present ? data.status.value : this.status,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CropField(')
          ..write('id: $id, ')
          ..write('cropTypeId: $cropTypeId, ')
          ..write('fieldId: $fieldId, ')
          ..write('variety: $variety, ')
          ..write('areaPlanted: $areaPlanted, ')
          ..write('season: $season, ')
          ..write('plantingDate: $plantingDate, ')
          ..write('expectedHarvestDate: $expectedHarvestDate, ')
          ..write('status: $status, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cropTypeId, fieldId, variety, areaPlanted,
      season, plantingDate, expectedHarvestDate, status, isArchived, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CropField &&
          other.id == this.id &&
          other.cropTypeId == this.cropTypeId &&
          other.fieldId == this.fieldId &&
          other.variety == this.variety &&
          other.areaPlanted == this.areaPlanted &&
          other.season == this.season &&
          other.plantingDate == this.plantingDate &&
          other.expectedHarvestDate == this.expectedHarvestDate &&
          other.status == this.status &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class CropFieldsCompanion extends UpdateCompanion<CropField> {
  final Value<String> id;
  final Value<String> cropTypeId;
  final Value<String> fieldId;
  final Value<String> variety;
  final Value<double> areaPlanted;
  final Value<String> season;
  final Value<DateTime> plantingDate;
  final Value<DateTime> expectedHarvestDate;
  final Value<String> status;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CropFieldsCompanion({
    this.id = const Value.absent(),
    this.cropTypeId = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.variety = const Value.absent(),
    this.areaPlanted = const Value.absent(),
    this.season = const Value.absent(),
    this.plantingDate = const Value.absent(),
    this.expectedHarvestDate = const Value.absent(),
    this.status = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CropFieldsCompanion.insert({
    required String id,
    required String cropTypeId,
    required String fieldId,
    required String variety,
    required double areaPlanted,
    required String season,
    required DateTime plantingDate,
    required DateTime expectedHarvestDate,
    this.status = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cropTypeId = Value(cropTypeId),
        fieldId = Value(fieldId),
        variety = Value(variety),
        areaPlanted = Value(areaPlanted),
        season = Value(season),
        plantingDate = Value(plantingDate),
        expectedHarvestDate = Value(expectedHarvestDate),
        createdAt = Value(createdAt);
  static Insertable<CropField> custom({
    Expression<String>? id,
    Expression<String>? cropTypeId,
    Expression<String>? fieldId,
    Expression<String>? variety,
    Expression<double>? areaPlanted,
    Expression<String>? season,
    Expression<DateTime>? plantingDate,
    Expression<DateTime>? expectedHarvestDate,
    Expression<String>? status,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cropTypeId != null) 'crop_type_id': cropTypeId,
      if (fieldId != null) 'field_id': fieldId,
      if (variety != null) 'variety': variety,
      if (areaPlanted != null) 'area_planted': areaPlanted,
      if (season != null) 'season': season,
      if (plantingDate != null) 'planting_date': plantingDate,
      if (expectedHarvestDate != null)
        'expected_harvest_date': expectedHarvestDate,
      if (status != null) 'status': status,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CropFieldsCompanion copyWith(
      {Value<String>? id,
      Value<String>? cropTypeId,
      Value<String>? fieldId,
      Value<String>? variety,
      Value<double>? areaPlanted,
      Value<String>? season,
      Value<DateTime>? plantingDate,
      Value<DateTime>? expectedHarvestDate,
      Value<String>? status,
      Value<bool>? isArchived,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CropFieldsCompanion(
      id: id ?? this.id,
      cropTypeId: cropTypeId ?? this.cropTypeId,
      fieldId: fieldId ?? this.fieldId,
      variety: variety ?? this.variety,
      areaPlanted: areaPlanted ?? this.areaPlanted,
      season: season ?? this.season,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      status: status ?? this.status,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cropTypeId.present) {
      map['crop_type_id'] = Variable<String>(cropTypeId.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<String>(fieldId.value);
    }
    if (variety.present) {
      map['variety'] = Variable<String>(variety.value);
    }
    if (areaPlanted.present) {
      map['area_planted'] = Variable<double>(areaPlanted.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (plantingDate.present) {
      map['planting_date'] = Variable<DateTime>(plantingDate.value);
    }
    if (expectedHarvestDate.present) {
      map['expected_harvest_date'] =
          Variable<DateTime>(expectedHarvestDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropFieldsCompanion(')
          ..write('id: $id, ')
          ..write('cropTypeId: $cropTypeId, ')
          ..write('fieldId: $fieldId, ')
          ..write('variety: $variety, ')
          ..write('areaPlanted: $areaPlanted, ')
          ..write('season: $season, ')
          ..write('plantingDate: $plantingDate, ')
          ..write('expectedHarvestDate: $expectedHarvestDate, ')
          ..write('status: $status, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activityTypeMeta =
      const VerificationMeta('activityType');
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
      'activity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fieldIdMeta =
      const VerificationMeta('fieldId');
  @override
  late final GeneratedColumn<String> fieldId = GeneratedColumn<String>(
      'field_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cropFieldIdMeta =
      const VerificationMeta('cropFieldId');
  @override
  late final GeneratedColumn<String> cropFieldId = GeneratedColumn<String>(
      'crop_field_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, activityType, date, notes, fieldId, cropFieldId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(Insertable<Activity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_type')) {
      context.handle(
          _activityTypeMeta,
          activityType.isAcceptableOrUnknown(
              data['activity_type']!, _activityTypeMeta));
    } else if (isInserting) {
      context.missing(_activityTypeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('field_id')) {
      context.handle(_fieldIdMeta,
          fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta));
    } else if (isInserting) {
      context.missing(_fieldIdMeta);
    }
    if (data.containsKey('crop_field_id')) {
      context.handle(
          _cropFieldIdMeta,
          cropFieldId.isAcceptableOrUnknown(
              data['crop_field_id']!, _cropFieldIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      activityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_type'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      fieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_id'])!,
      cropFieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_field_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final String id;
  final String activityType;
  final DateTime date;
  final String? notes;
  final String fieldId;
  final String? cropFieldId;
  final DateTime createdAt;
  const Activity(
      {required this.id,
      required this.activityType,
      required this.date,
      this.notes,
      required this.fieldId,
      this.cropFieldId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_type'] = Variable<String>(activityType);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['field_id'] = Variable<String>(fieldId);
    if (!nullToAbsent || cropFieldId != null) {
      map['crop_field_id'] = Variable<String>(cropFieldId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      activityType: Value(activityType),
      date: Value(date),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      fieldId: Value(fieldId),
      cropFieldId: cropFieldId == null && nullToAbsent
          ? const Value.absent()
          : Value(cropFieldId),
      createdAt: Value(createdAt),
    );
  }

  factory Activity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<String>(json['id']),
      activityType: serializer.fromJson<String>(json['activityType']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      fieldId: serializer.fromJson<String>(json['fieldId']),
      cropFieldId: serializer.fromJson<String?>(json['cropFieldId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityType': serializer.toJson<String>(activityType),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'fieldId': serializer.toJson<String>(fieldId),
      'cropFieldId': serializer.toJson<String?>(cropFieldId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Activity copyWith(
          {String? id,
          String? activityType,
          DateTime? date,
          Value<String?> notes = const Value.absent(),
          String? fieldId,
          Value<String?> cropFieldId = const Value.absent(),
          DateTime? createdAt}) =>
      Activity(
        id: id ?? this.id,
        activityType: activityType ?? this.activityType,
        date: date ?? this.date,
        notes: notes.present ? notes.value : this.notes,
        fieldId: fieldId ?? this.fieldId,
        cropFieldId: cropFieldId.present ? cropFieldId.value : this.cropFieldId,
        createdAt: createdAt ?? this.createdAt,
      );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      cropFieldId:
          data.cropFieldId.present ? data.cropFieldId.value : this.cropFieldId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('activityType: $activityType, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('fieldId: $fieldId, ')
          ..write('cropFieldId: $cropFieldId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, activityType, date, notes, fieldId, cropFieldId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.activityType == this.activityType &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.fieldId == this.fieldId &&
          other.cropFieldId == this.cropFieldId &&
          other.createdAt == this.createdAt);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<String> id;
  final Value<String> activityType;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<String> fieldId;
  final Value<String?> cropFieldId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.activityType = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.cropFieldId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String activityType,
    required DateTime date,
    this.notes = const Value.absent(),
    required String fieldId,
    this.cropFieldId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        activityType = Value(activityType),
        date = Value(date),
        fieldId = Value(fieldId),
        createdAt = Value(createdAt);
  static Insertable<Activity> custom({
    Expression<String>? id,
    Expression<String>? activityType,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? fieldId,
    Expression<String>? cropFieldId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityType != null) 'activity_type': activityType,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (fieldId != null) 'field_id': fieldId,
      if (cropFieldId != null) 'crop_field_id': cropFieldId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? activityType,
      Value<DateTime>? date,
      Value<String?>? notes,
      Value<String>? fieldId,
      Value<String?>? cropFieldId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      fieldId: fieldId ?? this.fieldId,
      cropFieldId: cropFieldId ?? this.cropFieldId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(activityType.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<String>(fieldId.value);
    }
    if (cropFieldId.present) {
      map['crop_field_id'] = Variable<String>(cropFieldId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('activityType: $activityType, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('fieldId: $fieldId, ')
          ..write('cropFieldId: $cropFieldId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityInputsTable extends ActivityInputs
    with TableInfo<$ActivityInputsTable, ActivityInputRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityInputsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activityIdMeta =
      const VerificationMeta('activityId');
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
      'activity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inputNameMeta =
      const VerificationMeta('inputName');
  @override
  late final GeneratedColumn<String> inputName = GeneratedColumn<String>(
      'input_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalCostMeta =
      const VerificationMeta('totalCost');
  @override
  late final GeneratedColumn<double> totalCost = GeneratedColumn<double>(
      'total_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        activityId,
        inputName,
        category,
        quantity,
        unit,
        unitCost,
        totalCost
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_inputs';
  @override
  VerificationContext validateIntegrity(Insertable<ActivityInputRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
          _activityIdMeta,
          activityId.isAcceptableOrUnknown(
              data['activity_id']!, _activityIdMeta));
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('input_name')) {
      context.handle(_inputNameMeta,
          inputName.isAcceptableOrUnknown(data['input_name']!, _inputNameMeta));
    } else if (isInserting) {
      context.missing(_inputNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('total_cost')) {
      context.handle(_totalCostMeta,
          totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta));
    } else if (isInserting) {
      context.missing(_totalCostMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityInputRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityInputRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      activityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_id'])!,
      inputName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}input_name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      totalCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_cost'])!,
    );
  }

  @override
  $ActivityInputsTable createAlias(String alias) {
    return $ActivityInputsTable(attachedDatabase, alias);
  }
}

class ActivityInputRow extends DataClass
    implements Insertable<ActivityInputRow> {
  final String id;
  final String activityId;
  final String inputName;
  final String category;
  final double quantity;
  final String unit;
  final double unitCost;
  final double totalCost;
  const ActivityInputRow(
      {required this.id,
      required this.activityId,
      required this.inputName,
      required this.category,
      required this.quantity,
      required this.unit,
      required this.unitCost,
      required this.totalCost});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['input_name'] = Variable<String>(inputName);
    map['category'] = Variable<String>(category);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['unit_cost'] = Variable<double>(unitCost);
    map['total_cost'] = Variable<double>(totalCost);
    return map;
  }

  ActivityInputsCompanion toCompanion(bool nullToAbsent) {
    return ActivityInputsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      inputName: Value(inputName),
      category: Value(category),
      quantity: Value(quantity),
      unit: Value(unit),
      unitCost: Value(unitCost),
      totalCost: Value(totalCost),
    );
  }

  factory ActivityInputRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityInputRow(
      id: serializer.fromJson<String>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      inputName: serializer.fromJson<String>(json['inputName']),
      category: serializer.fromJson<String>(json['category']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      totalCost: serializer.fromJson<double>(json['totalCost']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityId': serializer.toJson<String>(activityId),
      'inputName': serializer.toJson<String>(inputName),
      'category': serializer.toJson<String>(category),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'unitCost': serializer.toJson<double>(unitCost),
      'totalCost': serializer.toJson<double>(totalCost),
    };
  }

  ActivityInputRow copyWith(
          {String? id,
          String? activityId,
          String? inputName,
          String? category,
          double? quantity,
          String? unit,
          double? unitCost,
          double? totalCost}) =>
      ActivityInputRow(
        id: id ?? this.id,
        activityId: activityId ?? this.activityId,
        inputName: inputName ?? this.inputName,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        unitCost: unitCost ?? this.unitCost,
        totalCost: totalCost ?? this.totalCost,
      );
  ActivityInputRow copyWithCompanion(ActivityInputsCompanion data) {
    return ActivityInputRow(
      id: data.id.present ? data.id.value : this.id,
      activityId:
          data.activityId.present ? data.activityId.value : this.activityId,
      inputName: data.inputName.present ? data.inputName.value : this.inputName,
      category: data.category.present ? data.category.value : this.category,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityInputRow(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('inputName: $inputName, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitCost: $unitCost, ')
          ..write('totalCost: $totalCost')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, activityId, inputName, category, quantity, unit, unitCost, totalCost);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityInputRow &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.inputName == this.inputName &&
          other.category == this.category &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.unitCost == this.unitCost &&
          other.totalCost == this.totalCost);
}

class ActivityInputsCompanion extends UpdateCompanion<ActivityInputRow> {
  final Value<String> id;
  final Value<String> activityId;
  final Value<String> inputName;
  final Value<String> category;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<double> unitCost;
  final Value<double> totalCost;
  final Value<int> rowid;
  const ActivityInputsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.inputName = const Value.absent(),
    this.category = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityInputsCompanion.insert({
    required String id,
    required String activityId,
    required String inputName,
    required String category,
    required double quantity,
    required String unit,
    required double unitCost,
    required double totalCost,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        activityId = Value(activityId),
        inputName = Value(inputName),
        category = Value(category),
        quantity = Value(quantity),
        unit = Value(unit),
        unitCost = Value(unitCost),
        totalCost = Value(totalCost);
  static Insertable<ActivityInputRow> custom({
    Expression<String>? id,
    Expression<String>? activityId,
    Expression<String>? inputName,
    Expression<String>? category,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? unitCost,
    Expression<double>? totalCost,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (inputName != null) 'input_name': inputName,
      if (category != null) 'category': category,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (unitCost != null) 'unit_cost': unitCost,
      if (totalCost != null) 'total_cost': totalCost,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityInputsCompanion copyWith(
      {Value<String>? id,
      Value<String>? activityId,
      Value<String>? inputName,
      Value<String>? category,
      Value<double>? quantity,
      Value<String>? unit,
      Value<double>? unitCost,
      Value<double>? totalCost,
      Value<int>? rowid}) {
    return ActivityInputsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      inputName: inputName ?? this.inputName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitCost: unitCost ?? this.unitCost,
      totalCost: totalCost ?? this.totalCost,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (inputName.present) {
      map['input_name'] = Variable<String>(inputName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<double>(totalCost.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityInputsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('inputName: $inputName, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitCost: $unitCost, ')
          ..write('totalCost: $totalCost, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityLabourRecordsTable extends ActivityLabourRecords
    with TableInfo<$ActivityLabourRecordsTable, ActivityLabourRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLabourRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activityIdMeta =
      const VerificationMeta('activityId');
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
      'activity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _employeeIdMeta =
      const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
      'employee_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hoursWorkedMeta =
      const VerificationMeta('hoursWorked');
  @override
  late final GeneratedColumn<double> hoursWorked = GeneratedColumn<double>(
      'hours_worked', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _daysWorkedMeta =
      const VerificationMeta('daysWorked');
  @override
  late final GeneratedColumn<double> daysWorked = GeneratedColumn<double>(
      'days_worked', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalCostMeta =
      const VerificationMeta('totalCost');
  @override
  late final GeneratedColumn<double> totalCost = GeneratedColumn<double>(
      'total_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, activityId, employeeId, hoursWorked, daysWorked, totalCost];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_labour_records';
  @override
  VerificationContext validateIntegrity(
      Insertable<ActivityLabourRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
          _activityIdMeta,
          activityId.isAcceptableOrUnknown(
              data['activity_id']!, _activityIdMeta));
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
          _employeeIdMeta,
          employeeId.isAcceptableOrUnknown(
              data['employee_id']!, _employeeIdMeta));
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('hours_worked')) {
      context.handle(
          _hoursWorkedMeta,
          hoursWorked.isAcceptableOrUnknown(
              data['hours_worked']!, _hoursWorkedMeta));
    } else if (isInserting) {
      context.missing(_hoursWorkedMeta);
    }
    if (data.containsKey('days_worked')) {
      context.handle(
          _daysWorkedMeta,
          daysWorked.isAcceptableOrUnknown(
              data['days_worked']!, _daysWorkedMeta));
    } else if (isInserting) {
      context.missing(_daysWorkedMeta);
    }
    if (data.containsKey('total_cost')) {
      context.handle(_totalCostMeta,
          totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta));
    } else if (isInserting) {
      context.missing(_totalCostMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityLabourRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLabourRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      activityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_id'])!,
      employeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}employee_id'])!,
      hoursWorked: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hours_worked'])!,
      daysWorked: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}days_worked'])!,
      totalCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_cost'])!,
    );
  }

  @override
  $ActivityLabourRecordsTable createAlias(String alias) {
    return $ActivityLabourRecordsTable(attachedDatabase, alias);
  }
}

class ActivityLabourRecord extends DataClass
    implements Insertable<ActivityLabourRecord> {
  final String id;
  final String activityId;
  final String employeeId;
  final double hoursWorked;
  final double daysWorked;
  final double totalCost;
  const ActivityLabourRecord(
      {required this.id,
      required this.activityId,
      required this.employeeId,
      required this.hoursWorked,
      required this.daysWorked,
      required this.totalCost});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['employee_id'] = Variable<String>(employeeId);
    map['hours_worked'] = Variable<double>(hoursWorked);
    map['days_worked'] = Variable<double>(daysWorked);
    map['total_cost'] = Variable<double>(totalCost);
    return map;
  }

  ActivityLabourRecordsCompanion toCompanion(bool nullToAbsent) {
    return ActivityLabourRecordsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      employeeId: Value(employeeId),
      hoursWorked: Value(hoursWorked),
      daysWorked: Value(daysWorked),
      totalCost: Value(totalCost),
    );
  }

  factory ActivityLabourRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLabourRecord(
      id: serializer.fromJson<String>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      hoursWorked: serializer.fromJson<double>(json['hoursWorked']),
      daysWorked: serializer.fromJson<double>(json['daysWorked']),
      totalCost: serializer.fromJson<double>(json['totalCost']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityId': serializer.toJson<String>(activityId),
      'employeeId': serializer.toJson<String>(employeeId),
      'hoursWorked': serializer.toJson<double>(hoursWorked),
      'daysWorked': serializer.toJson<double>(daysWorked),
      'totalCost': serializer.toJson<double>(totalCost),
    };
  }

  ActivityLabourRecord copyWith(
          {String? id,
          String? activityId,
          String? employeeId,
          double? hoursWorked,
          double? daysWorked,
          double? totalCost}) =>
      ActivityLabourRecord(
        id: id ?? this.id,
        activityId: activityId ?? this.activityId,
        employeeId: employeeId ?? this.employeeId,
        hoursWorked: hoursWorked ?? this.hoursWorked,
        daysWorked: daysWorked ?? this.daysWorked,
        totalCost: totalCost ?? this.totalCost,
      );
  ActivityLabourRecord copyWithCompanion(ActivityLabourRecordsCompanion data) {
    return ActivityLabourRecord(
      id: data.id.present ? data.id.value : this.id,
      activityId:
          data.activityId.present ? data.activityId.value : this.activityId,
      employeeId:
          data.employeeId.present ? data.employeeId.value : this.employeeId,
      hoursWorked:
          data.hoursWorked.present ? data.hoursWorked.value : this.hoursWorked,
      daysWorked:
          data.daysWorked.present ? data.daysWorked.value : this.daysWorked,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLabourRecord(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('employeeId: $employeeId, ')
          ..write('hoursWorked: $hoursWorked, ')
          ..write('daysWorked: $daysWorked, ')
          ..write('totalCost: $totalCost')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, activityId, employeeId, hoursWorked, daysWorked, totalCost);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLabourRecord &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.employeeId == this.employeeId &&
          other.hoursWorked == this.hoursWorked &&
          other.daysWorked == this.daysWorked &&
          other.totalCost == this.totalCost);
}

class ActivityLabourRecordsCompanion
    extends UpdateCompanion<ActivityLabourRecord> {
  final Value<String> id;
  final Value<String> activityId;
  final Value<String> employeeId;
  final Value<double> hoursWorked;
  final Value<double> daysWorked;
  final Value<double> totalCost;
  final Value<int> rowid;
  const ActivityLabourRecordsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.hoursWorked = const Value.absent(),
    this.daysWorked = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityLabourRecordsCompanion.insert({
    required String id,
    required String activityId,
    required String employeeId,
    required double hoursWorked,
    required double daysWorked,
    required double totalCost,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        activityId = Value(activityId),
        employeeId = Value(employeeId),
        hoursWorked = Value(hoursWorked),
        daysWorked = Value(daysWorked),
        totalCost = Value(totalCost);
  static Insertable<ActivityLabourRecord> custom({
    Expression<String>? id,
    Expression<String>? activityId,
    Expression<String>? employeeId,
    Expression<double>? hoursWorked,
    Expression<double>? daysWorked,
    Expression<double>? totalCost,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (employeeId != null) 'employee_id': employeeId,
      if (hoursWorked != null) 'hours_worked': hoursWorked,
      if (daysWorked != null) 'days_worked': daysWorked,
      if (totalCost != null) 'total_cost': totalCost,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityLabourRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? activityId,
      Value<String>? employeeId,
      Value<double>? hoursWorked,
      Value<double>? daysWorked,
      Value<double>? totalCost,
      Value<int>? rowid}) {
    return ActivityLabourRecordsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      employeeId: employeeId ?? this.employeeId,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      daysWorked: daysWorked ?? this.daysWorked,
      totalCost: totalCost ?? this.totalCost,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (hoursWorked.present) {
      map['hours_worked'] = Variable<double>(hoursWorked.value);
    }
    if (daysWorked.present) {
      map['days_worked'] = Variable<double>(daysWorked.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<double>(totalCost.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLabourRecordsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('employeeId: $employeeId, ')
          ..write('hoursWorked: $hoursWorked, ')
          ..write('daysWorked: $daysWorked, ')
          ..write('totalCost: $totalCost, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityOtherCostsTable extends ActivityOtherCosts
    with TableInfo<$ActivityOtherCostsTable, ActivityOtherCostRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityOtherCostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activityIdMeta =
      const VerificationMeta('activityId');
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
      'activity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, activityId, description, amount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_other_costs';
  @override
  VerificationContext validateIntegrity(
      Insertable<ActivityOtherCostRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
          _activityIdMeta,
          activityId.isAcceptableOrUnknown(
              data['activity_id']!, _activityIdMeta));
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityOtherCostRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityOtherCostRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      activityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
    );
  }

  @override
  $ActivityOtherCostsTable createAlias(String alias) {
    return $ActivityOtherCostsTable(attachedDatabase, alias);
  }
}

class ActivityOtherCostRow extends DataClass
    implements Insertable<ActivityOtherCostRow> {
  final String id;
  final String activityId;
  final String description;
  final double amount;
  const ActivityOtherCostRow(
      {required this.id,
      required this.activityId,
      required this.description,
      required this.amount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    return map;
  }

  ActivityOtherCostsCompanion toCompanion(bool nullToAbsent) {
    return ActivityOtherCostsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      description: Value(description),
      amount: Value(amount),
    );
  }

  factory ActivityOtherCostRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityOtherCostRow(
      id: serializer.fromJson<String>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityId': serializer.toJson<String>(activityId),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
    };
  }

  ActivityOtherCostRow copyWith(
          {String? id,
          String? activityId,
          String? description,
          double? amount}) =>
      ActivityOtherCostRow(
        id: id ?? this.id,
        activityId: activityId ?? this.activityId,
        description: description ?? this.description,
        amount: amount ?? this.amount,
      );
  ActivityOtherCostRow copyWithCompanion(ActivityOtherCostsCompanion data) {
    return ActivityOtherCostRow(
      id: data.id.present ? data.id.value : this.id,
      activityId:
          data.activityId.present ? data.activityId.value : this.activityId,
      description:
          data.description.present ? data.description.value : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityOtherCostRow(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('description: $description, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, activityId, description, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityOtherCostRow &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.description == this.description &&
          other.amount == this.amount);
}

class ActivityOtherCostsCompanion
    extends UpdateCompanion<ActivityOtherCostRow> {
  final Value<String> id;
  final Value<String> activityId;
  final Value<String> description;
  final Value<double> amount;
  final Value<int> rowid;
  const ActivityOtherCostsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityOtherCostsCompanion.insert({
    required String id,
    required String activityId,
    required String description,
    required double amount,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        activityId = Value(activityId),
        description = Value(description),
        amount = Value(amount);
  static Insertable<ActivityOtherCostRow> custom({
    Expression<String>? id,
    Expression<String>? activityId,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityOtherCostsCompanion copyWith(
      {Value<String>? id,
      Value<String>? activityId,
      Value<String>? description,
      Value<double>? amount,
      Value<int>? rowid}) {
    return ActivityOtherCostsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityOtherCostsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmployeesTable extends Employees
    with TableInfo<$EmployeesTable, Employee> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payRateMeta =
      const VerificationMeta('payRate');
  @override
  late final GeneratedColumn<double> payRate = GeneratedColumn<double>(
      'pay_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _payRateUnitMeta =
      const VerificationMeta('payRateUnit');
  @override
  late final GeneratedColumn<String> payRateUnit = GeneratedColumn<String>(
      'pay_rate_unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, role, payRate, payRateUnit, phone, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employees';
  @override
  VerificationContext validateIntegrity(Insertable<Employee> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('pay_rate')) {
      context.handle(_payRateMeta,
          payRate.isAcceptableOrUnknown(data['pay_rate']!, _payRateMeta));
    } else if (isInserting) {
      context.missing(_payRateMeta);
    }
    if (data.containsKey('pay_rate_unit')) {
      context.handle(
          _payRateUnitMeta,
          payRateUnit.isAcceptableOrUnknown(
              data['pay_rate_unit']!, _payRateUnitMeta));
    } else if (isInserting) {
      context.missing(_payRateUnitMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Employee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Employee(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      payRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pay_rate'])!,
      payRateUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pay_rate_unit'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $EmployeesTable createAlias(String alias) {
    return $EmployeesTable(attachedDatabase, alias);
  }
}

class Employee extends DataClass implements Insertable<Employee> {
  final String id;
  final String name;
  final String role;
  final double payRate;
  final String payRateUnit;
  final String? phone;
  final bool isActive;
  const Employee(
      {required this.id,
      required this.name,
      required this.role,
      required this.payRate,
      required this.payRateUnit,
      this.phone,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    map['pay_rate'] = Variable<double>(payRate);
    map['pay_rate_unit'] = Variable<String>(payRateUnit);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      id: Value(id),
      name: Value(name),
      role: Value(role),
      payRate: Value(payRate),
      payRateUnit: Value(payRateUnit),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      isActive: Value(isActive),
    );
  }

  factory Employee.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Employee(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      payRate: serializer.fromJson<double>(json['payRate']),
      payRateUnit: serializer.fromJson<String>(json['payRateUnit']),
      phone: serializer.fromJson<String?>(json['phone']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'payRate': serializer.toJson<double>(payRate),
      'payRateUnit': serializer.toJson<String>(payRateUnit),
      'phone': serializer.toJson<String?>(phone),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Employee copyWith(
          {String? id,
          String? name,
          String? role,
          double? payRate,
          String? payRateUnit,
          Value<String?> phone = const Value.absent(),
          bool? isActive}) =>
      Employee(
        id: id ?? this.id,
        name: name ?? this.name,
        role: role ?? this.role,
        payRate: payRate ?? this.payRate,
        payRateUnit: payRateUnit ?? this.payRateUnit,
        phone: phone.present ? phone.value : this.phone,
        isActive: isActive ?? this.isActive,
      );
  Employee copyWithCompanion(EmployeesCompanion data) {
    return Employee(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      payRate: data.payRate.present ? data.payRate.value : this.payRate,
      payRateUnit:
          data.payRateUnit.present ? data.payRateUnit.value : this.payRateUnit,
      phone: data.phone.present ? data.phone.value : this.phone,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Employee(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('payRate: $payRate, ')
          ..write('payRateUnit: $payRateUnit, ')
          ..write('phone: $phone, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, role, payRate, payRateUnit, phone, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Employee &&
          other.id == this.id &&
          other.name == this.name &&
          other.role == this.role &&
          other.payRate == this.payRate &&
          other.payRateUnit == this.payRateUnit &&
          other.phone == this.phone &&
          other.isActive == this.isActive);
}

class EmployeesCompanion extends UpdateCompanion<Employee> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> role;
  final Value<double> payRate;
  final Value<String> payRateUnit;
  final Value<String?> phone;
  final Value<bool> isActive;
  final Value<int> rowid;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.payRate = const Value.absent(),
    this.payRateUnit = const Value.absent(),
    this.phone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmployeesCompanion.insert({
    required String id,
    required String name,
    required String role,
    required double payRate,
    required String payRateUnit,
    this.phone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        role = Value(role),
        payRate = Value(payRate),
        payRateUnit = Value(payRateUnit);
  static Insertable<Employee> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? role,
    Expression<double>? payRate,
    Expression<String>? payRateUnit,
    Expression<String>? phone,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (payRate != null) 'pay_rate': payRate,
      if (payRateUnit != null) 'pay_rate_unit': payRateUnit,
      if (phone != null) 'phone': phone,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmployeesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? role,
      Value<double>? payRate,
      Value<String>? payRateUnit,
      Value<String?>? phone,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return EmployeesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      payRate: payRate ?? this.payRate,
      payRateUnit: payRateUnit ?? this.payRateUnit,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (payRate.present) {
      map['pay_rate'] = Variable<double>(payRate.value);
    }
    if (payRateUnit.present) {
      map['pay_rate_unit'] = Variable<String>(payRateUnit.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('payRate: $payRate, ')
          ..write('payRateUnit: $payRateUnit, ')
          ..write('phone: $phone, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
      'season', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fieldIdMeta =
      const VerificationMeta('fieldId');
  @override
  late final GeneratedColumn<String> fieldId = GeneratedColumn<String>(
      'field_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cropFieldIdMeta =
      const VerificationMeta('cropFieldId');
  @override
  late final GeneratedColumn<String> cropFieldId = GeneratedColumn<String>(
      'crop_field_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _harvestYieldIdMeta =
      const VerificationMeta('harvestYieldId');
  @override
  late final GeneratedColumn<String> harvestYieldId = GeneratedColumn<String>(
      'harvest_yield_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        category,
        amount,
        date,
        description,
        season,
        fieldId,
        cropFieldId,
        harvestYieldId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('season')) {
      context.handle(_seasonMeta,
          season.isAcceptableOrUnknown(data['season']!, _seasonMeta));
    }
    if (data.containsKey('field_id')) {
      context.handle(_fieldIdMeta,
          fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta));
    }
    if (data.containsKey('crop_field_id')) {
      context.handle(
          _cropFieldIdMeta,
          cropFieldId.isAcceptableOrUnknown(
              data['crop_field_id']!, _cropFieldIdMeta));
    }
    if (data.containsKey('harvest_yield_id')) {
      context.handle(
          _harvestYieldIdMeta,
          harvestYieldId.isAcceptableOrUnknown(
              data['harvest_yield_id']!, _harvestYieldIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      season: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}season']),
      fieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_id']),
      cropFieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_field_id']),
      harvestYieldId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}harvest_yield_id']),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String type;
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final String? season;
  final String? fieldId;
  final String? cropFieldId;
  final String? harvestYieldId;
  const Transaction(
      {required this.id,
      required this.type,
      required this.category,
      required this.amount,
      required this.date,
      required this.description,
      this.season,
      this.fieldId,
      this.cropFieldId,
      this.harvestYieldId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || season != null) {
      map['season'] = Variable<String>(season);
    }
    if (!nullToAbsent || fieldId != null) {
      map['field_id'] = Variable<String>(fieldId);
    }
    if (!nullToAbsent || cropFieldId != null) {
      map['crop_field_id'] = Variable<String>(cropFieldId);
    }
    if (!nullToAbsent || harvestYieldId != null) {
      map['harvest_yield_id'] = Variable<String>(harvestYieldId);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      category: Value(category),
      amount: Value(amount),
      date: Value(date),
      description: Value(description),
      season:
          season == null && nullToAbsent ? const Value.absent() : Value(season),
      fieldId: fieldId == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldId),
      cropFieldId: cropFieldId == null && nullToAbsent
          ? const Value.absent()
          : Value(cropFieldId),
      harvestYieldId: harvestYieldId == null && nullToAbsent
          ? const Value.absent()
          : Value(harvestYieldId),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String>(json['description']),
      season: serializer.fromJson<String?>(json['season']),
      fieldId: serializer.fromJson<String?>(json['fieldId']),
      cropFieldId: serializer.fromJson<String?>(json['cropFieldId']),
      harvestYieldId: serializer.fromJson<String?>(json['harvestYieldId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String>(description),
      'season': serializer.toJson<String?>(season),
      'fieldId': serializer.toJson<String?>(fieldId),
      'cropFieldId': serializer.toJson<String?>(cropFieldId),
      'harvestYieldId': serializer.toJson<String?>(harvestYieldId),
    };
  }

  Transaction copyWith(
          {String? id,
          String? type,
          String? category,
          double? amount,
          DateTime? date,
          String? description,
          Value<String?> season = const Value.absent(),
          Value<String?> fieldId = const Value.absent(),
          Value<String?> cropFieldId = const Value.absent(),
          Value<String?> harvestYieldId = const Value.absent()}) =>
      Transaction(
        id: id ?? this.id,
        type: type ?? this.type,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        description: description ?? this.description,
        season: season.present ? season.value : this.season,
        fieldId: fieldId.present ? fieldId.value : this.fieldId,
        cropFieldId: cropFieldId.present ? cropFieldId.value : this.cropFieldId,
        harvestYieldId:
            harvestYieldId.present ? harvestYieldId.value : this.harvestYieldId,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      description:
          data.description.present ? data.description.value : this.description,
      season: data.season.present ? data.season.value : this.season,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      cropFieldId:
          data.cropFieldId.present ? data.cropFieldId.value : this.cropFieldId,
      harvestYieldId: data.harvestYieldId.present
          ? data.harvestYieldId.value
          : this.harvestYieldId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('season: $season, ')
          ..write('fieldId: $fieldId, ')
          ..write('cropFieldId: $cropFieldId, ')
          ..write('harvestYieldId: $harvestYieldId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, category, amount, date, description,
      season, fieldId, cropFieldId, harvestYieldId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.type == this.type &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.description == this.description &&
          other.season == this.season &&
          other.fieldId == this.fieldId &&
          other.cropFieldId == this.cropFieldId &&
          other.harvestYieldId == this.harvestYieldId);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> category;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> description;
  final Value<String?> season;
  final Value<String?> fieldId;
  final Value<String?> cropFieldId;
  final Value<String?> harvestYieldId;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.season = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.cropFieldId = const Value.absent(),
    this.harvestYieldId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String type,
    required String category,
    required double amount,
    required DateTime date,
    required String description,
    this.season = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.cropFieldId = const Value.absent(),
    this.harvestYieldId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        category = Value(category),
        amount = Value(amount),
        date = Value(date),
        description = Value(description);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<String>? season,
    Expression<String>? fieldId,
    Expression<String>? cropFieldId,
    Expression<String>? harvestYieldId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (season != null) 'season': season,
      if (fieldId != null) 'field_id': fieldId,
      if (cropFieldId != null) 'crop_field_id': cropFieldId,
      if (harvestYieldId != null) 'harvest_yield_id': harvestYieldId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? category,
      Value<double>? amount,
      Value<DateTime>? date,
      Value<String>? description,
      Value<String?>? season,
      Value<String?>? fieldId,
      Value<String?>? cropFieldId,
      Value<String?>? harvestYieldId,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      season: season ?? this.season,
      fieldId: fieldId ?? this.fieldId,
      cropFieldId: cropFieldId ?? this.cropFieldId,
      harvestYieldId: harvestYieldId ?? this.harvestYieldId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<String>(fieldId.value);
    }
    if (cropFieldId.present) {
      map['crop_field_id'] = Variable<String>(cropFieldId.value);
    }
    if (harvestYieldId.present) {
      map['harvest_yield_id'] = Variable<String>(harvestYieldId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('season: $season, ')
          ..write('fieldId: $fieldId, ')
          ..write('cropFieldId: $cropFieldId, ')
          ..write('harvestYieldId: $harvestYieldId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OverheadExpensesTable extends OverheadExpenses
    with TableInfo<$OverheadExpensesTable, OverheadExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OverheadExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _recurringMeta =
      const VerificationMeta('recurring');
  @override
  late final GeneratedColumn<bool> recurring = GeneratedColumn<bool>(
      'recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, description, category, amount, date, recurring, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'overhead_expenses';
  @override
  VerificationContext validateIntegrity(Insertable<OverheadExpenseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('recurring')) {
      context.handle(_recurringMeta,
          recurring.isAcceptableOrUnknown(data['recurring']!, _recurringMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OverheadExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OverheadExpenseRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      recurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}recurring'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $OverheadExpensesTable createAlias(String alias) {
    return $OverheadExpensesTable(attachedDatabase, alias);
  }
}

class OverheadExpenseRow extends DataClass
    implements Insertable<OverheadExpenseRow> {
  final String id;
  final String description;
  final String category;
  final double amount;
  final DateTime date;
  final bool recurring;
  final String? notes;
  const OverheadExpenseRow(
      {required this.id,
      required this.description,
      required this.category,
      required this.amount,
      required this.date,
      required this.recurring,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['description'] = Variable<String>(description);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['recurring'] = Variable<bool>(recurring);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  OverheadExpensesCompanion toCompanion(bool nullToAbsent) {
    return OverheadExpensesCompanion(
      id: Value(id),
      description: Value(description),
      category: Value(category),
      amount: Value(amount),
      date: Value(date),
      recurring: Value(recurring),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory OverheadExpenseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OverheadExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      recurring: serializer.fromJson<bool>(json['recurring']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'recurring': serializer.toJson<bool>(recurring),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  OverheadExpenseRow copyWith(
          {String? id,
          String? description,
          String? category,
          double? amount,
          DateTime? date,
          bool? recurring,
          Value<String?> notes = const Value.absent()}) =>
      OverheadExpenseRow(
        id: id ?? this.id,
        description: description ?? this.description,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        recurring: recurring ?? this.recurring,
        notes: notes.present ? notes.value : this.notes,
      );
  OverheadExpenseRow copyWithCompanion(OverheadExpensesCompanion data) {
    return OverheadExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      description:
          data.description.present ? data.description.value : this.description,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      recurring: data.recurring.present ? data.recurring.value : this.recurring,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OverheadExpenseRow(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('recurring: $recurring, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, description, category, amount, date, recurring, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OverheadExpenseRow &&
          other.id == this.id &&
          other.description == this.description &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.recurring == this.recurring &&
          other.notes == this.notes);
}

class OverheadExpensesCompanion extends UpdateCompanion<OverheadExpenseRow> {
  final Value<String> id;
  final Value<String> description;
  final Value<String> category;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<bool> recurring;
  final Value<String?> notes;
  final Value<int> rowid;
  const OverheadExpensesCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.recurring = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OverheadExpensesCompanion.insert({
    required String id,
    required String description,
    required String category,
    required double amount,
    required DateTime date,
    this.recurring = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        description = Value(description),
        category = Value(category),
        amount = Value(amount),
        date = Value(date);
  static Insertable<OverheadExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<bool>? recurring,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (recurring != null) 'recurring': recurring,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OverheadExpensesCompanion copyWith(
      {Value<String>? id,
      Value<String>? description,
      Value<String>? category,
      Value<double>? amount,
      Value<DateTime>? date,
      Value<bool>? recurring,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return OverheadExpensesCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      recurring: recurring ?? this.recurring,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (recurring.present) {
      map['recurring'] = Variable<bool>(recurring.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OverheadExpensesCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('recurring: $recurring, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HarvestYieldsTable extends HarvestYields
    with TableInfo<$HarvestYieldsTable, HarvestYield> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HarvestYieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cropFieldIdMeta =
      const VerificationMeta('cropFieldId');
  @override
  late final GeneratedColumn<String> cropFieldId = GeneratedColumn<String>(
      'crop_field_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _harvestDateMeta =
      const VerificationMeta('harvestDate');
  @override
  late final GeneratedColumn<DateTime> harvestDate = GeneratedColumn<DateTime>(
      'harvest_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitWeightMeta =
      const VerificationMeta('unitWeight');
  @override
  late final GeneratedColumn<double> unitWeight = GeneratedColumn<double>(
      'unit_weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cropFieldId,
        harvestDate,
        quantity,
        unit,
        unitWeight,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'harvest_yields';
  @override
  VerificationContext validateIntegrity(Insertable<HarvestYield> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('crop_field_id')) {
      context.handle(
          _cropFieldIdMeta,
          cropFieldId.isAcceptableOrUnknown(
              data['crop_field_id']!, _cropFieldIdMeta));
    } else if (isInserting) {
      context.missing(_cropFieldIdMeta);
    }
    if (data.containsKey('harvest_date')) {
      context.handle(
          _harvestDateMeta,
          harvestDate.isAcceptableOrUnknown(
              data['harvest_date']!, _harvestDateMeta));
    } else if (isInserting) {
      context.missing(_harvestDateMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('unit_weight')) {
      context.handle(
          _unitWeightMeta,
          unitWeight.isAcceptableOrUnknown(
              data['unit_weight']!, _unitWeightMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HarvestYield map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HarvestYield(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cropFieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_field_id'])!,
      harvestDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}harvest_date'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      unitWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_weight']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $HarvestYieldsTable createAlias(String alias) {
    return $HarvestYieldsTable(attachedDatabase, alias);
  }
}

class HarvestYield extends DataClass implements Insertable<HarvestYield> {
  final String id;
  final String cropFieldId;
  final DateTime harvestDate;
  final double quantity;
  final String unit;
  final double? unitWeight;
  final String? notes;
  final DateTime createdAt;
  const HarvestYield(
      {required this.id,
      required this.cropFieldId,
      required this.harvestDate,
      required this.quantity,
      required this.unit,
      this.unitWeight,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['crop_field_id'] = Variable<String>(cropFieldId);
    map['harvest_date'] = Variable<DateTime>(harvestDate);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || unitWeight != null) {
      map['unit_weight'] = Variable<double>(unitWeight);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HarvestYieldsCompanion toCompanion(bool nullToAbsent) {
    return HarvestYieldsCompanion(
      id: Value(id),
      cropFieldId: Value(cropFieldId),
      harvestDate: Value(harvestDate),
      quantity: Value(quantity),
      unit: Value(unit),
      unitWeight: unitWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(unitWeight),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory HarvestYield.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HarvestYield(
      id: serializer.fromJson<String>(json['id']),
      cropFieldId: serializer.fromJson<String>(json['cropFieldId']),
      harvestDate: serializer.fromJson<DateTime>(json['harvestDate']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      unitWeight: serializer.fromJson<double?>(json['unitWeight']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cropFieldId': serializer.toJson<String>(cropFieldId),
      'harvestDate': serializer.toJson<DateTime>(harvestDate),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'unitWeight': serializer.toJson<double?>(unitWeight),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HarvestYield copyWith(
          {String? id,
          String? cropFieldId,
          DateTime? harvestDate,
          double? quantity,
          String? unit,
          Value<double?> unitWeight = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      HarvestYield(
        id: id ?? this.id,
        cropFieldId: cropFieldId ?? this.cropFieldId,
        harvestDate: harvestDate ?? this.harvestDate,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        unitWeight: unitWeight.present ? unitWeight.value : this.unitWeight,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  HarvestYield copyWithCompanion(HarvestYieldsCompanion data) {
    return HarvestYield(
      id: data.id.present ? data.id.value : this.id,
      cropFieldId:
          data.cropFieldId.present ? data.cropFieldId.value : this.cropFieldId,
      harvestDate:
          data.harvestDate.present ? data.harvestDate.value : this.harvestDate,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitWeight:
          data.unitWeight.present ? data.unitWeight.value : this.unitWeight,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HarvestYield(')
          ..write('id: $id, ')
          ..write('cropFieldId: $cropFieldId, ')
          ..write('harvestDate: $harvestDate, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitWeight: $unitWeight, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cropFieldId, harvestDate, quantity, unit,
      unitWeight, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HarvestYield &&
          other.id == this.id &&
          other.cropFieldId == this.cropFieldId &&
          other.harvestDate == this.harvestDate &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.unitWeight == this.unitWeight &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class HarvestYieldsCompanion extends UpdateCompanion<HarvestYield> {
  final Value<String> id;
  final Value<String> cropFieldId;
  final Value<DateTime> harvestDate;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<double?> unitWeight;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HarvestYieldsCompanion({
    this.id = const Value.absent(),
    this.cropFieldId = const Value.absent(),
    this.harvestDate = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitWeight = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HarvestYieldsCompanion.insert({
    required String id,
    required String cropFieldId,
    required DateTime harvestDate,
    required double quantity,
    required String unit,
    this.unitWeight = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cropFieldId = Value(cropFieldId),
        harvestDate = Value(harvestDate),
        quantity = Value(quantity),
        unit = Value(unit),
        createdAt = Value(createdAt);
  static Insertable<HarvestYield> custom({
    Expression<String>? id,
    Expression<String>? cropFieldId,
    Expression<DateTime>? harvestDate,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? unitWeight,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cropFieldId != null) 'crop_field_id': cropFieldId,
      if (harvestDate != null) 'harvest_date': harvestDate,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (unitWeight != null) 'unit_weight': unitWeight,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HarvestYieldsCompanion copyWith(
      {Value<String>? id,
      Value<String>? cropFieldId,
      Value<DateTime>? harvestDate,
      Value<double>? quantity,
      Value<String>? unit,
      Value<double?>? unitWeight,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return HarvestYieldsCompanion(
      id: id ?? this.id,
      cropFieldId: cropFieldId ?? this.cropFieldId,
      harvestDate: harvestDate ?? this.harvestDate,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitWeight: unitWeight ?? this.unitWeight,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cropFieldId.present) {
      map['crop_field_id'] = Variable<String>(cropFieldId.value);
    }
    if (harvestDate.present) {
      map['harvest_date'] = Variable<DateTime>(harvestDate.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitWeight.present) {
      map['unit_weight'] = Variable<double>(unitWeight.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HarvestYieldsCompanion(')
          ..write('id: $id, ')
          ..write('cropFieldId: $cropFieldId, ')
          ..write('harvestDate: $harvestDate, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitWeight: $unitWeight, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryItemsTable extends InventoryItems
    with TableInfo<$InventoryItemsTable, InventoryItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _acquisitionUnitCostMeta =
      const VerificationMeta('acquisitionUnitCost');
  @override
  late final GeneratedColumn<double> acquisitionUnitCost =
      GeneratedColumn<double>('acquisition_unit_cost', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _acquiredAtMeta =
      const VerificationMeta('acquiredAt');
  @override
  late final GeneratedColumn<DateTime> acquiredAt = GeneratedColumn<DateTime>(
      'acquired_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _unitWeightMeta =
      const VerificationMeta('unitWeight');
  @override
  late final GeneratedColumn<double> unitWeight = GeneratedColumn<double>(
      'unit_weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
      'season', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cropFieldIdMeta =
      const VerificationMeta('cropFieldId');
  @override
  late final GeneratedColumn<String> cropFieldId = GeneratedColumn<String>(
      'crop_field_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _harvestYieldIdMeta =
      const VerificationMeta('harvestYieldId');
  @override
  late final GeneratedColumn<String> harvestYieldId = GeneratedColumn<String>(
      'harvest_yield_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        unit,
        quantity,
        acquisitionUnitCost,
        acquiredAt,
        unitWeight,
        season,
        cropFieldId,
        harvestYieldId,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_items';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('acquisition_unit_cost')) {
      context.handle(
          _acquisitionUnitCostMeta,
          acquisitionUnitCost.isAcceptableOrUnknown(
              data['acquisition_unit_cost']!, _acquisitionUnitCostMeta));
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
          _acquiredAtMeta,
          acquiredAt.isAcceptableOrUnknown(
              data['acquired_at']!, _acquiredAtMeta));
    }
    if (data.containsKey('unit_weight')) {
      context.handle(
          _unitWeightMeta,
          unitWeight.isAcceptableOrUnknown(
              data['unit_weight']!, _unitWeightMeta));
    }
    if (data.containsKey('season')) {
      context.handle(_seasonMeta,
          season.isAcceptableOrUnknown(data['season']!, _seasonMeta));
    }
    if (data.containsKey('crop_field_id')) {
      context.handle(
          _cropFieldIdMeta,
          cropFieldId.isAcceptableOrUnknown(
              data['crop_field_id']!, _cropFieldIdMeta));
    }
    if (data.containsKey('harvest_yield_id')) {
      context.handle(
          _harvestYieldIdMeta,
          harvestYieldId.isAcceptableOrUnknown(
              data['harvest_yield_id']!, _harvestYieldIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      acquisitionUnitCost: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}acquisition_unit_cost']),
      acquiredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}acquired_at']),
      unitWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_weight']),
      season: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}season']),
      cropFieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_field_id']),
      harvestYieldId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}harvest_yield_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $InventoryItemsTable createAlias(String alias) {
    return $InventoryItemsTable(attachedDatabase, alias);
  }
}

class InventoryItemRow extends DataClass
    implements Insertable<InventoryItemRow> {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double quantity;
  final double? acquisitionUnitCost;
  final DateTime? acquiredAt;
  final double? unitWeight;
  final String? season;
  final String? cropFieldId;
  final String? harvestYieldId;
  final String? notes;
  const InventoryItemRow(
      {required this.id,
      required this.name,
      required this.category,
      required this.unit,
      required this.quantity,
      this.acquisitionUnitCost,
      this.acquiredAt,
      this.unitWeight,
      this.season,
      this.cropFieldId,
      this.harvestYieldId,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['unit'] = Variable<String>(unit);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || acquisitionUnitCost != null) {
      map['acquisition_unit_cost'] = Variable<double>(acquisitionUnitCost);
    }
    if (!nullToAbsent || acquiredAt != null) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt);
    }
    if (!nullToAbsent || unitWeight != null) {
      map['unit_weight'] = Variable<double>(unitWeight);
    }
    if (!nullToAbsent || season != null) {
      map['season'] = Variable<String>(season);
    }
    if (!nullToAbsent || cropFieldId != null) {
      map['crop_field_id'] = Variable<String>(cropFieldId);
    }
    if (!nullToAbsent || harvestYieldId != null) {
      map['harvest_yield_id'] = Variable<String>(harvestYieldId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  InventoryItemsCompanion toCompanion(bool nullToAbsent) {
    return InventoryItemsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      unit: Value(unit),
      quantity: Value(quantity),
      acquisitionUnitCost: acquisitionUnitCost == null && nullToAbsent
          ? const Value.absent()
          : Value(acquisitionUnitCost),
      acquiredAt: acquiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acquiredAt),
      unitWeight: unitWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(unitWeight),
      season:
          season == null && nullToAbsent ? const Value.absent() : Value(season),
      cropFieldId: cropFieldId == null && nullToAbsent
          ? const Value.absent()
          : Value(cropFieldId),
      harvestYieldId: harvestYieldId == null && nullToAbsent
          ? const Value.absent()
          : Value(harvestYieldId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory InventoryItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryItemRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      unit: serializer.fromJson<String>(json['unit']),
      quantity: serializer.fromJson<double>(json['quantity']),
      acquisitionUnitCost:
          serializer.fromJson<double?>(json['acquisitionUnitCost']),
      acquiredAt: serializer.fromJson<DateTime?>(json['acquiredAt']),
      unitWeight: serializer.fromJson<double?>(json['unitWeight']),
      season: serializer.fromJson<String?>(json['season']),
      cropFieldId: serializer.fromJson<String?>(json['cropFieldId']),
      harvestYieldId: serializer.fromJson<String?>(json['harvestYieldId']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'unit': serializer.toJson<String>(unit),
      'quantity': serializer.toJson<double>(quantity),
      'acquisitionUnitCost': serializer.toJson<double?>(acquisitionUnitCost),
      'acquiredAt': serializer.toJson<DateTime?>(acquiredAt),
      'unitWeight': serializer.toJson<double?>(unitWeight),
      'season': serializer.toJson<String?>(season),
      'cropFieldId': serializer.toJson<String?>(cropFieldId),
      'harvestYieldId': serializer.toJson<String?>(harvestYieldId),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  InventoryItemRow copyWith(
          {String? id,
          String? name,
          String? category,
          String? unit,
          double? quantity,
          Value<double?> acquisitionUnitCost = const Value.absent(),
          Value<DateTime?> acquiredAt = const Value.absent(),
          Value<double?> unitWeight = const Value.absent(),
          Value<String?> season = const Value.absent(),
          Value<String?> cropFieldId = const Value.absent(),
          Value<String?> harvestYieldId = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      InventoryItemRow(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        unit: unit ?? this.unit,
        quantity: quantity ?? this.quantity,
        acquisitionUnitCost: acquisitionUnitCost.present
            ? acquisitionUnitCost.value
            : this.acquisitionUnitCost,
        acquiredAt: acquiredAt.present ? acquiredAt.value : this.acquiredAt,
        unitWeight: unitWeight.present ? unitWeight.value : this.unitWeight,
        season: season.present ? season.value : this.season,
        cropFieldId: cropFieldId.present ? cropFieldId.value : this.cropFieldId,
        harvestYieldId:
            harvestYieldId.present ? harvestYieldId.value : this.harvestYieldId,
        notes: notes.present ? notes.value : this.notes,
      );
  InventoryItemRow copyWithCompanion(InventoryItemsCompanion data) {
    return InventoryItemRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      unit: data.unit.present ? data.unit.value : this.unit,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      acquisitionUnitCost: data.acquisitionUnitCost.present
          ? data.acquisitionUnitCost.value
          : this.acquisitionUnitCost,
      acquiredAt:
          data.acquiredAt.present ? data.acquiredAt.value : this.acquiredAt,
      unitWeight:
          data.unitWeight.present ? data.unitWeight.value : this.unitWeight,
      season: data.season.present ? data.season.value : this.season,
      cropFieldId:
          data.cropFieldId.present ? data.cropFieldId.value : this.cropFieldId,
      harvestYieldId: data.harvestYieldId.present
          ? data.harvestYieldId.value
          : this.harvestYieldId,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('acquisitionUnitCost: $acquisitionUnitCost, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('unitWeight: $unitWeight, ')
          ..write('season: $season, ')
          ..write('cropFieldId: $cropFieldId, ')
          ..write('harvestYieldId: $harvestYieldId, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      unit,
      quantity,
      acquisitionUnitCost,
      acquiredAt,
      unitWeight,
      season,
      cropFieldId,
      harvestYieldId,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryItemRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.unit == this.unit &&
          other.quantity == this.quantity &&
          other.acquisitionUnitCost == this.acquisitionUnitCost &&
          other.acquiredAt == this.acquiredAt &&
          other.unitWeight == this.unitWeight &&
          other.season == this.season &&
          other.cropFieldId == this.cropFieldId &&
          other.harvestYieldId == this.harvestYieldId &&
          other.notes == this.notes);
}

class InventoryItemsCompanion extends UpdateCompanion<InventoryItemRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> unit;
  final Value<double> quantity;
  final Value<double?> acquisitionUnitCost;
  final Value<DateTime?> acquiredAt;
  final Value<double?> unitWeight;
  final Value<String?> season;
  final Value<String?> cropFieldId;
  final Value<String?> harvestYieldId;
  final Value<String?> notes;
  final Value<int> rowid;
  const InventoryItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.acquisitionUnitCost = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.unitWeight = const Value.absent(),
    this.season = const Value.absent(),
    this.cropFieldId = const Value.absent(),
    this.harvestYieldId = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryItemsCompanion.insert({
    required String id,
    required String name,
    required String category,
    required String unit,
    required double quantity,
    this.acquisitionUnitCost = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.unitWeight = const Value.absent(),
    this.season = const Value.absent(),
    this.cropFieldId = const Value.absent(),
    this.harvestYieldId = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        unit = Value(unit),
        quantity = Value(quantity);
  static Insertable<InventoryItemRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? unit,
    Expression<double>? quantity,
    Expression<double>? acquisitionUnitCost,
    Expression<DateTime>? acquiredAt,
    Expression<double>? unitWeight,
    Expression<String>? season,
    Expression<String>? cropFieldId,
    Expression<String>? harvestYieldId,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (quantity != null) 'quantity': quantity,
      if (acquisitionUnitCost != null)
        'acquisition_unit_cost': acquisitionUnitCost,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (unitWeight != null) 'unit_weight': unitWeight,
      if (season != null) 'season': season,
      if (cropFieldId != null) 'crop_field_id': cropFieldId,
      if (harvestYieldId != null) 'harvest_yield_id': harvestYieldId,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? category,
      Value<String>? unit,
      Value<double>? quantity,
      Value<double?>? acquisitionUnitCost,
      Value<DateTime?>? acquiredAt,
      Value<double?>? unitWeight,
      Value<String?>? season,
      Value<String?>? cropFieldId,
      Value<String?>? harvestYieldId,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return InventoryItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      acquisitionUnitCost: acquisitionUnitCost ?? this.acquisitionUnitCost,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      unitWeight: unitWeight ?? this.unitWeight,
      season: season ?? this.season,
      cropFieldId: cropFieldId ?? this.cropFieldId,
      harvestYieldId: harvestYieldId ?? this.harvestYieldId,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (acquisitionUnitCost.present) {
      map['acquisition_unit_cost'] =
          Variable<double>(acquisitionUnitCost.value);
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt.value);
    }
    if (unitWeight.present) {
      map['unit_weight'] = Variable<double>(unitWeight.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (cropFieldId.present) {
      map['crop_field_id'] = Variable<String>(cropFieldId.value);
    }
    if (harvestYieldId.present) {
      map['harvest_yield_id'] = Variable<String>(harvestYieldId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('acquisitionUnitCost: $acquisitionUnitCost, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('unitWeight: $unitWeight, ')
          ..write('season: $season, ')
          ..write('cropFieldId: $cropFieldId, ')
          ..write('harvestYieldId: $harvestYieldId, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventorySalesTable extends InventorySales
    with TableInfo<$InventorySalesTable, InventorySaleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventorySalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inventoryItemIdMeta =
      const VerificationMeta('inventoryItemId');
  @override
  late final GeneratedColumn<String> inventoryItemId = GeneratedColumn<String>(
      'inventory_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantitySoldMeta =
      const VerificationMeta('quantitySold');
  @override
  late final GeneratedColumn<double> quantitySold = GeneratedColumn<double>(
      'quantity_sold', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pricePerUnitMeta =
      const VerificationMeta('pricePerUnit');
  @override
  late final GeneratedColumn<double> pricePerUnit = GeneratedColumn<double>(
      'price_per_unit', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _buyerNameMeta =
      const VerificationMeta('buyerName');
  @override
  late final GeneratedColumn<String> buyerName = GeneratedColumn<String>(
      'buyer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _saleDateMeta =
      const VerificationMeta('saleDate');
  @override
  late final GeneratedColumn<DateTime> saleDate = GeneratedColumn<DateTime>(
      'sale_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        inventoryItemId,
        quantitySold,
        unit,
        pricePerUnit,
        totalAmount,
        buyerName,
        saleDate,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_sales';
  @override
  VerificationContext validateIntegrity(Insertable<InventorySaleRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('inventory_item_id')) {
      context.handle(
          _inventoryItemIdMeta,
          inventoryItemId.isAcceptableOrUnknown(
              data['inventory_item_id']!, _inventoryItemIdMeta));
    } else if (isInserting) {
      context.missing(_inventoryItemIdMeta);
    }
    if (data.containsKey('quantity_sold')) {
      context.handle(
          _quantitySoldMeta,
          quantitySold.isAcceptableOrUnknown(
              data['quantity_sold']!, _quantitySoldMeta));
    } else if (isInserting) {
      context.missing(_quantitySoldMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('price_per_unit')) {
      context.handle(
          _pricePerUnitMeta,
          pricePerUnit.isAcceptableOrUnknown(
              data['price_per_unit']!, _pricePerUnitMeta));
    } else if (isInserting) {
      context.missing(_pricePerUnitMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('buyer_name')) {
      context.handle(_buyerNameMeta,
          buyerName.isAcceptableOrUnknown(data['buyer_name']!, _buyerNameMeta));
    }
    if (data.containsKey('sale_date')) {
      context.handle(_saleDateMeta,
          saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta));
    } else if (isInserting) {
      context.missing(_saleDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventorySaleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventorySaleRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      inventoryItemId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}inventory_item_id'])!,
      quantitySold: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity_sold'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      pricePerUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_per_unit'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      buyerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}buyer_name']),
      saleDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sale_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $InventorySalesTable createAlias(String alias) {
    return $InventorySalesTable(attachedDatabase, alias);
  }
}

class InventorySaleRow extends DataClass
    implements Insertable<InventorySaleRow> {
  final String id;
  final String inventoryItemId;
  final double quantitySold;
  final String unit;
  final double pricePerUnit;
  final double totalAmount;
  final String? buyerName;
  final DateTime saleDate;
  final String? notes;
  const InventorySaleRow(
      {required this.id,
      required this.inventoryItemId,
      required this.quantitySold,
      required this.unit,
      required this.pricePerUnit,
      required this.totalAmount,
      this.buyerName,
      required this.saleDate,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['inventory_item_id'] = Variable<String>(inventoryItemId);
    map['quantity_sold'] = Variable<double>(quantitySold);
    map['unit'] = Variable<String>(unit);
    map['price_per_unit'] = Variable<double>(pricePerUnit);
    map['total_amount'] = Variable<double>(totalAmount);
    if (!nullToAbsent || buyerName != null) {
      map['buyer_name'] = Variable<String>(buyerName);
    }
    map['sale_date'] = Variable<DateTime>(saleDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  InventorySalesCompanion toCompanion(bool nullToAbsent) {
    return InventorySalesCompanion(
      id: Value(id),
      inventoryItemId: Value(inventoryItemId),
      quantitySold: Value(quantitySold),
      unit: Value(unit),
      pricePerUnit: Value(pricePerUnit),
      totalAmount: Value(totalAmount),
      buyerName: buyerName == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerName),
      saleDate: Value(saleDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory InventorySaleRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventorySaleRow(
      id: serializer.fromJson<String>(json['id']),
      inventoryItemId: serializer.fromJson<String>(json['inventoryItemId']),
      quantitySold: serializer.fromJson<double>(json['quantitySold']),
      unit: serializer.fromJson<String>(json['unit']),
      pricePerUnit: serializer.fromJson<double>(json['pricePerUnit']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      buyerName: serializer.fromJson<String?>(json['buyerName']),
      saleDate: serializer.fromJson<DateTime>(json['saleDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'inventoryItemId': serializer.toJson<String>(inventoryItemId),
      'quantitySold': serializer.toJson<double>(quantitySold),
      'unit': serializer.toJson<String>(unit),
      'pricePerUnit': serializer.toJson<double>(pricePerUnit),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'buyerName': serializer.toJson<String?>(buyerName),
      'saleDate': serializer.toJson<DateTime>(saleDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  InventorySaleRow copyWith(
          {String? id,
          String? inventoryItemId,
          double? quantitySold,
          String? unit,
          double? pricePerUnit,
          double? totalAmount,
          Value<String?> buyerName = const Value.absent(),
          DateTime? saleDate,
          Value<String?> notes = const Value.absent()}) =>
      InventorySaleRow(
        id: id ?? this.id,
        inventoryItemId: inventoryItemId ?? this.inventoryItemId,
        quantitySold: quantitySold ?? this.quantitySold,
        unit: unit ?? this.unit,
        pricePerUnit: pricePerUnit ?? this.pricePerUnit,
        totalAmount: totalAmount ?? this.totalAmount,
        buyerName: buyerName.present ? buyerName.value : this.buyerName,
        saleDate: saleDate ?? this.saleDate,
        notes: notes.present ? notes.value : this.notes,
      );
  InventorySaleRow copyWithCompanion(InventorySalesCompanion data) {
    return InventorySaleRow(
      id: data.id.present ? data.id.value : this.id,
      inventoryItemId: data.inventoryItemId.present
          ? data.inventoryItemId.value
          : this.inventoryItemId,
      quantitySold: data.quantitySold.present
          ? data.quantitySold.value
          : this.quantitySold,
      unit: data.unit.present ? data.unit.value : this.unit,
      pricePerUnit: data.pricePerUnit.present
          ? data.pricePerUnit.value
          : this.pricePerUnit,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      buyerName: data.buyerName.present ? data.buyerName.value : this.buyerName,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventorySaleRow(')
          ..write('id: $id, ')
          ..write('inventoryItemId: $inventoryItemId, ')
          ..write('quantitySold: $quantitySold, ')
          ..write('unit: $unit, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('buyerName: $buyerName, ')
          ..write('saleDate: $saleDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, inventoryItemId, quantitySold, unit,
      pricePerUnit, totalAmount, buyerName, saleDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventorySaleRow &&
          other.id == this.id &&
          other.inventoryItemId == this.inventoryItemId &&
          other.quantitySold == this.quantitySold &&
          other.unit == this.unit &&
          other.pricePerUnit == this.pricePerUnit &&
          other.totalAmount == this.totalAmount &&
          other.buyerName == this.buyerName &&
          other.saleDate == this.saleDate &&
          other.notes == this.notes);
}

class InventorySalesCompanion extends UpdateCompanion<InventorySaleRow> {
  final Value<String> id;
  final Value<String> inventoryItemId;
  final Value<double> quantitySold;
  final Value<String> unit;
  final Value<double> pricePerUnit;
  final Value<double> totalAmount;
  final Value<String?> buyerName;
  final Value<DateTime> saleDate;
  final Value<String?> notes;
  final Value<int> rowid;
  const InventorySalesCompanion({
    this.id = const Value.absent(),
    this.inventoryItemId = const Value.absent(),
    this.quantitySold = const Value.absent(),
    this.unit = const Value.absent(),
    this.pricePerUnit = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.buyerName = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventorySalesCompanion.insert({
    required String id,
    required String inventoryItemId,
    required double quantitySold,
    required String unit,
    required double pricePerUnit,
    required double totalAmount,
    this.buyerName = const Value.absent(),
    required DateTime saleDate,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        inventoryItemId = Value(inventoryItemId),
        quantitySold = Value(quantitySold),
        unit = Value(unit),
        pricePerUnit = Value(pricePerUnit),
        totalAmount = Value(totalAmount),
        saleDate = Value(saleDate);
  static Insertable<InventorySaleRow> custom({
    Expression<String>? id,
    Expression<String>? inventoryItemId,
    Expression<double>? quantitySold,
    Expression<String>? unit,
    Expression<double>? pricePerUnit,
    Expression<double>? totalAmount,
    Expression<String>? buyerName,
    Expression<DateTime>? saleDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (inventoryItemId != null) 'inventory_item_id': inventoryItemId,
      if (quantitySold != null) 'quantity_sold': quantitySold,
      if (unit != null) 'unit': unit,
      if (pricePerUnit != null) 'price_per_unit': pricePerUnit,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (buyerName != null) 'buyer_name': buyerName,
      if (saleDate != null) 'sale_date': saleDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventorySalesCompanion copyWith(
      {Value<String>? id,
      Value<String>? inventoryItemId,
      Value<double>? quantitySold,
      Value<String>? unit,
      Value<double>? pricePerUnit,
      Value<double>? totalAmount,
      Value<String?>? buyerName,
      Value<DateTime>? saleDate,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return InventorySalesCompanion(
      id: id ?? this.id,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      quantitySold: quantitySold ?? this.quantitySold,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalAmount: totalAmount ?? this.totalAmount,
      buyerName: buyerName ?? this.buyerName,
      saleDate: saleDate ?? this.saleDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (inventoryItemId.present) {
      map['inventory_item_id'] = Variable<String>(inventoryItemId.value);
    }
    if (quantitySold.present) {
      map['quantity_sold'] = Variable<double>(quantitySold.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (pricePerUnit.present) {
      map['price_per_unit'] = Variable<double>(pricePerUnit.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (buyerName.present) {
      map['buyer_name'] = Variable<String>(buyerName.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<DateTime>(saleDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventorySalesCompanion(')
          ..write('id: $id, ')
          ..write('inventoryItemId: $inventoryItemId, ')
          ..write('quantitySold: $quantitySold, ')
          ..write('unit: $unit, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('buyerName: $buyerName, ')
          ..write('saleDate: $saleDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmDocumentsTable extends FarmDocuments
    with TableInfo<$FarmDocumentsTable, FarmDocumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
      'size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _linkedToMeta =
      const VerificationMeta('linkedTo');
  @override
  late final GeneratedColumn<String> linkedTo = GeneratedColumn<String>(
      'linked_to', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _linkedTypeMeta =
      const VerificationMeta('linkedType');
  @override
  late final GeneratedColumn<String> linkedType = GeneratedColumn<String>(
      'linked_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _uploadedAtMeta =
      const VerificationMeta('uploadedAt');
  @override
  late final GeneratedColumn<DateTime> uploadedAt = GeneratedColumn<DateTime>(
      'uploaded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, type, url, size, linkedTo, linkedType, notes, uploadedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_documents';
  @override
  VerificationContext validateIntegrity(Insertable<FarmDocumentRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    }
    if (data.containsKey('linked_to')) {
      context.handle(_linkedToMeta,
          linkedTo.isAcceptableOrUnknown(data['linked_to']!, _linkedToMeta));
    }
    if (data.containsKey('linked_type')) {
      context.handle(
          _linkedTypeMeta,
          linkedType.isAcceptableOrUnknown(
              data['linked_type']!, _linkedTypeMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
          _uploadedAtMeta,
          uploadedAt.isAcceptableOrUnknown(
              data['uploaded_at']!, _uploadedAtMeta));
    } else if (isInserting) {
      context.missing(_uploadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmDocumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmDocumentRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size']),
      linkedTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}linked_to']),
      linkedType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}linked_type']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      uploadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}uploaded_at'])!,
    );
  }

  @override
  $FarmDocumentsTable createAlias(String alias) {
    return $FarmDocumentsTable(attachedDatabase, alias);
  }
}

class FarmDocumentRow extends DataClass implements Insertable<FarmDocumentRow> {
  final String id;
  final String name;
  final String type;
  final String url;
  final int? size;
  final String? linkedTo;
  final String? linkedType;
  final String? notes;
  final DateTime uploadedAt;
  const FarmDocumentRow(
      {required this.id,
      required this.name,
      required this.type,
      required this.url,
      this.size,
      this.linkedTo,
      this.linkedType,
      this.notes,
      required this.uploadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<int>(size);
    }
    if (!nullToAbsent || linkedTo != null) {
      map['linked_to'] = Variable<String>(linkedTo);
    }
    if (!nullToAbsent || linkedType != null) {
      map['linked_type'] = Variable<String>(linkedType);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['uploaded_at'] = Variable<DateTime>(uploadedAt);
    return map;
  }

  FarmDocumentsCompanion toCompanion(bool nullToAbsent) {
    return FarmDocumentsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      url: Value(url),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      linkedTo: linkedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedTo),
      linkedType: linkedType == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedType),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      uploadedAt: Value(uploadedAt),
    );
  }

  factory FarmDocumentRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmDocumentRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      url: serializer.fromJson<String>(json['url']),
      size: serializer.fromJson<int?>(json['size']),
      linkedTo: serializer.fromJson<String?>(json['linkedTo']),
      linkedType: serializer.fromJson<String?>(json['linkedType']),
      notes: serializer.fromJson<String?>(json['notes']),
      uploadedAt: serializer.fromJson<DateTime>(json['uploadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'url': serializer.toJson<String>(url),
      'size': serializer.toJson<int?>(size),
      'linkedTo': serializer.toJson<String?>(linkedTo),
      'linkedType': serializer.toJson<String?>(linkedType),
      'notes': serializer.toJson<String?>(notes),
      'uploadedAt': serializer.toJson<DateTime>(uploadedAt),
    };
  }

  FarmDocumentRow copyWith(
          {String? id,
          String? name,
          String? type,
          String? url,
          Value<int?> size = const Value.absent(),
          Value<String?> linkedTo = const Value.absent(),
          Value<String?> linkedType = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? uploadedAt}) =>
      FarmDocumentRow(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        url: url ?? this.url,
        size: size.present ? size.value : this.size,
        linkedTo: linkedTo.present ? linkedTo.value : this.linkedTo,
        linkedType: linkedType.present ? linkedType.value : this.linkedType,
        notes: notes.present ? notes.value : this.notes,
        uploadedAt: uploadedAt ?? this.uploadedAt,
      );
  FarmDocumentRow copyWithCompanion(FarmDocumentsCompanion data) {
    return FarmDocumentRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      url: data.url.present ? data.url.value : this.url,
      size: data.size.present ? data.size.value : this.size,
      linkedTo: data.linkedTo.present ? data.linkedTo.value : this.linkedTo,
      linkedType:
          data.linkedType.present ? data.linkedType.value : this.linkedType,
      notes: data.notes.present ? data.notes.value : this.notes,
      uploadedAt:
          data.uploadedAt.present ? data.uploadedAt.value : this.uploadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmDocumentRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('url: $url, ')
          ..write('size: $size, ')
          ..write('linkedTo: $linkedTo, ')
          ..write('linkedType: $linkedType, ')
          ..write('notes: $notes, ')
          ..write('uploadedAt: $uploadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, type, url, size, linkedTo, linkedType, notes, uploadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmDocumentRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.url == this.url &&
          other.size == this.size &&
          other.linkedTo == this.linkedTo &&
          other.linkedType == this.linkedType &&
          other.notes == this.notes &&
          other.uploadedAt == this.uploadedAt);
}

class FarmDocumentsCompanion extends UpdateCompanion<FarmDocumentRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> url;
  final Value<int?> size;
  final Value<String?> linkedTo;
  final Value<String?> linkedType;
  final Value<String?> notes;
  final Value<DateTime> uploadedAt;
  final Value<int> rowid;
  const FarmDocumentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.url = const Value.absent(),
    this.size = const Value.absent(),
    this.linkedTo = const Value.absent(),
    this.linkedType = const Value.absent(),
    this.notes = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmDocumentsCompanion.insert({
    required String id,
    required String name,
    required String type,
    required String url,
    this.size = const Value.absent(),
    this.linkedTo = const Value.absent(),
    this.linkedType = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime uploadedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        url = Value(url),
        uploadedAt = Value(uploadedAt);
  static Insertable<FarmDocumentRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? url,
    Expression<int>? size,
    Expression<String>? linkedTo,
    Expression<String>? linkedType,
    Expression<String>? notes,
    Expression<DateTime>? uploadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (url != null) 'url': url,
      if (size != null) 'size': size,
      if (linkedTo != null) 'linked_to': linkedTo,
      if (linkedType != null) 'linked_type': linkedType,
      if (notes != null) 'notes': notes,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmDocumentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String>? url,
      Value<int?>? size,
      Value<String?>? linkedTo,
      Value<String?>? linkedType,
      Value<String?>? notes,
      Value<DateTime>? uploadedAt,
      Value<int>? rowid}) {
    return FarmDocumentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      url: url ?? this.url,
      size: size ?? this.size,
      linkedTo: linkedTo ?? this.linkedTo,
      linkedType: linkedType ?? this.linkedType,
      notes: notes ?? this.notes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (linkedTo.present) {
      map['linked_to'] = Variable<String>(linkedTo.value);
    }
    if (linkedType.present) {
      map['linked_type'] = Variable<String>(linkedType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('url: $url, ')
          ..write('size: $size, ')
          ..write('linkedTo: $linkedTo, ')
          ..write('linkedType: $linkedType, ')
          ..write('notes: $notes, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, NotificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
      'link', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, title, message, isRead, link, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(Insertable<NotificationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('link')) {
      context.handle(
          _linkMeta, link.isAcceptableOrUnknown(data['link']!, _linkMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      link: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class NotificationRow extends DataClass implements Insertable<NotificationRow> {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? link;
  final DateTime createdAt;
  const NotificationRow(
      {required this.id,
      required this.type,
      required this.title,
      required this.message,
      required this.isRead,
      this.link,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['message'] = Variable<String>(message);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      message: Value(message),
      isRead: Value(isRead),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      createdAt: Value(createdAt),
    );
  }

  factory NotificationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      link: serializer.fromJson<String?>(json['link']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String>(message),
      'isRead': serializer.toJson<bool>(isRead),
      'link': serializer.toJson<String?>(link),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NotificationRow copyWith(
          {String? id,
          String? type,
          String? title,
          String? message,
          bool? isRead,
          Value<String?> link = const Value.absent(),
          DateTime? createdAt}) =>
      NotificationRow(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        message: message ?? this.message,
        isRead: isRead ?? this.isRead,
        link: link.present ? link.value : this.link,
        createdAt: createdAt ?? this.createdAt,
      );
  NotificationRow copyWithCompanion(NotificationsCompanion data) {
    return NotificationRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      link: data.link.present ? data.link.value : this.link,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('isRead: $isRead, ')
          ..write('link: $link, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, title, message, isRead, link, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.message == this.message &&
          other.isRead == this.isRead &&
          other.link == this.link &&
          other.createdAt == this.createdAt);
}

class NotificationsCompanion extends UpdateCompanion<NotificationRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String> message;
  final Value<bool> isRead;
  final Value<String?> link;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.isRead = const Value.absent(),
    this.link = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsCompanion.insert({
    required String id,
    required String type,
    required String title,
    required String message,
    this.isRead = const Value.absent(),
    this.link = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        title = Value(title),
        message = Value(message),
        createdAt = Value(createdAt);
  static Insertable<NotificationRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? message,
    Expression<bool>? isRead,
    Expression<String>? link,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (isRead != null) 'is_read': isRead,
      if (link != null) 'link': link,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? title,
      Value<String>? message,
      Value<bool>? isRead,
      Value<String?>? link,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return NotificationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      link: link ?? this.link,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('isRead: $isRead, ')
          ..write('link: $link, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LivestockTypesTable extends LivestockTypes
    with TableInfo<$LivestockTypesTable, LivestockTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LivestockTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, category, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'livestock_types';
  @override
  VerificationContext validateIntegrity(Insertable<LivestockTypeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LivestockTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LivestockTypeRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
    );
  }

  @override
  $LivestockTypesTable createAlias(String alias) {
    return $LivestockTypesTable(attachedDatabase, alias);
  }
}

class LivestockTypeRow extends DataClass
    implements Insertable<LivestockTypeRow> {
  final String id;
  final String name;
  final String category;
  final String icon;
  const LivestockTypeRow(
      {required this.id,
      required this.name,
      required this.category,
      required this.icon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['icon'] = Variable<String>(icon);
    return map;
  }

  LivestockTypesCompanion toCompanion(bool nullToAbsent) {
    return LivestockTypesCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      icon: Value(icon),
    );
  }

  factory LivestockTypeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LivestockTypeRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      icon: serializer.fromJson<String>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'icon': serializer.toJson<String>(icon),
    };
  }

  LivestockTypeRow copyWith(
          {String? id, String? name, String? category, String? icon}) =>
      LivestockTypeRow(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        icon: icon ?? this.icon,
      );
  LivestockTypeRow copyWithCompanion(LivestockTypesCompanion data) {
    return LivestockTypeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LivestockTypeRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, category, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LivestockTypeRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.icon == this.icon);
}

class LivestockTypesCompanion extends UpdateCompanion<LivestockTypeRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> icon;
  final Value<int> rowid;
  const LivestockTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LivestockTypesCompanion.insert({
    required String id,
    required String name,
    required String category,
    required String icon,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        icon = Value(icon);
  static Insertable<LivestockTypeRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LivestockTypesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? category,
      Value<String>? icon,
      Value<int>? rowid}) {
    return LivestockTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LivestockTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('icon: $icon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalsTable extends Animals with TableInfo<$AnimalsTable, AnimalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _livestockTypeIdMeta =
      const VerificationMeta('livestockTypeId');
  @override
  late final GeneratedColumn<String> livestockTypeId = GeneratedColumn<String>(
      'livestock_type_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _animalGroupMeta =
      const VerificationMeta('animalGroup');
  @override
  late final GeneratedColumn<String> animalGroup = GeneratedColumn<String>(
      'animal_group', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
      'sex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _acquisitionDateMeta =
      const VerificationMeta('acquisitionDate');
  @override
  late final GeneratedColumn<DateTime> acquisitionDate =
      GeneratedColumn<DateTime>('acquisition_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _acquisitionTypeMeta =
      const VerificationMeta('acquisitionType');
  @override
  late final GeneratedColumn<String> acquisitionType = GeneratedColumn<String>(
      'acquisition_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _acquisitionCostMeta =
      const VerificationMeta('acquisitionCost');
  @override
  late final GeneratedColumn<double> acquisitionCost = GeneratedColumn<double>(
      'acquisition_cost', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Active'));
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
      'breed', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
      'colour', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        livestockTypeId,
        tag,
        name,
        animalGroup,
        sex,
        birthDate,
        acquisitionDate,
        acquisitionType,
        acquisitionCost,
        status,
        breed,
        colour,
        weight,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animals';
  @override
  VerificationContext validateIntegrity(Insertable<AnimalRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('livestock_type_id')) {
      context.handle(
          _livestockTypeIdMeta,
          livestockTypeId.isAcceptableOrUnknown(
              data['livestock_type_id']!, _livestockTypeIdMeta));
    } else if (isInserting) {
      context.missing(_livestockTypeIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('animal_group')) {
      context.handle(
          _animalGroupMeta,
          animalGroup.isAcceptableOrUnknown(
              data['animal_group']!, _animalGroupMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('acquisition_date')) {
      context.handle(
          _acquisitionDateMeta,
          acquisitionDate.isAcceptableOrUnknown(
              data['acquisition_date']!, _acquisitionDateMeta));
    } else if (isInserting) {
      context.missing(_acquisitionDateMeta);
    }
    if (data.containsKey('acquisition_type')) {
      context.handle(
          _acquisitionTypeMeta,
          acquisitionType.isAcceptableOrUnknown(
              data['acquisition_type']!, _acquisitionTypeMeta));
    } else if (isInserting) {
      context.missing(_acquisitionTypeMeta);
    }
    if (data.containsKey('acquisition_cost')) {
      context.handle(
          _acquisitionCostMeta,
          acquisitionCost.isAcceptableOrUnknown(
              data['acquisition_cost']!, _acquisitionCostMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('breed')) {
      context.handle(
          _breedMeta, breed.isAcceptableOrUnknown(data['breed']!, _breedMeta));
    }
    if (data.containsKey('colour')) {
      context.handle(_colourMeta,
          colour.isAcceptableOrUnknown(data['colour']!, _colourMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      livestockTypeId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}livestock_type_id'])!,
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      animalGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_group']),
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sex'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date']),
      acquisitionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}acquisition_date'])!,
      acquisitionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}acquisition_type'])!,
      acquisitionCost: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}acquisition_cost']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      breed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}breed']),
      colour: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}colour']),
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $AnimalsTable createAlias(String alias) {
    return $AnimalsTable(attachedDatabase, alias);
  }
}

class AnimalRow extends DataClass implements Insertable<AnimalRow> {
  final String id;
  final String livestockTypeId;
  final String? tag;
  final String? name;
  final String? animalGroup;
  final String sex;
  final DateTime? birthDate;
  final DateTime acquisitionDate;
  final String acquisitionType;
  final double? acquisitionCost;
  final String status;
  final String? breed;
  final String? colour;
  final double? weight;
  final String? notes;
  const AnimalRow(
      {required this.id,
      required this.livestockTypeId,
      this.tag,
      this.name,
      this.animalGroup,
      required this.sex,
      this.birthDate,
      required this.acquisitionDate,
      required this.acquisitionType,
      this.acquisitionCost,
      required this.status,
      this.breed,
      this.colour,
      this.weight,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['livestock_type_id'] = Variable<String>(livestockTypeId);
    if (!nullToAbsent || tag != null) {
      map['tag'] = Variable<String>(tag);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || animalGroup != null) {
      map['animal_group'] = Variable<String>(animalGroup);
    }
    map['sex'] = Variable<String>(sex);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    map['acquisition_date'] = Variable<DateTime>(acquisitionDate);
    map['acquisition_type'] = Variable<String>(acquisitionType);
    if (!nullToAbsent || acquisitionCost != null) {
      map['acquisition_cost'] = Variable<double>(acquisitionCost);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String>(colour);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AnimalsCompanion toCompanion(bool nullToAbsent) {
    return AnimalsCompanion(
      id: Value(id),
      livestockTypeId: Value(livestockTypeId),
      tag: tag == null && nullToAbsent ? const Value.absent() : Value(tag),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      animalGroup: animalGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(animalGroup),
      sex: Value(sex),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      acquisitionDate: Value(acquisitionDate),
      acquisitionType: Value(acquisitionType),
      acquisitionCost: acquisitionCost == null && nullToAbsent
          ? const Value.absent()
          : Value(acquisitionCost),
      status: Value(status),
      breed:
          breed == null && nullToAbsent ? const Value.absent() : Value(breed),
      colour:
          colour == null && nullToAbsent ? const Value.absent() : Value(colour),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory AnimalRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalRow(
      id: serializer.fromJson<String>(json['id']),
      livestockTypeId: serializer.fromJson<String>(json['livestockTypeId']),
      tag: serializer.fromJson<String?>(json['tag']),
      name: serializer.fromJson<String?>(json['name']),
      animalGroup: serializer.fromJson<String?>(json['animalGroup']),
      sex: serializer.fromJson<String>(json['sex']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      acquisitionDate: serializer.fromJson<DateTime>(json['acquisitionDate']),
      acquisitionType: serializer.fromJson<String>(json['acquisitionType']),
      acquisitionCost: serializer.fromJson<double?>(json['acquisitionCost']),
      status: serializer.fromJson<String>(json['status']),
      breed: serializer.fromJson<String?>(json['breed']),
      colour: serializer.fromJson<String?>(json['colour']),
      weight: serializer.fromJson<double?>(json['weight']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'livestockTypeId': serializer.toJson<String>(livestockTypeId),
      'tag': serializer.toJson<String?>(tag),
      'name': serializer.toJson<String?>(name),
      'animalGroup': serializer.toJson<String?>(animalGroup),
      'sex': serializer.toJson<String>(sex),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'acquisitionDate': serializer.toJson<DateTime>(acquisitionDate),
      'acquisitionType': serializer.toJson<String>(acquisitionType),
      'acquisitionCost': serializer.toJson<double?>(acquisitionCost),
      'status': serializer.toJson<String>(status),
      'breed': serializer.toJson<String?>(breed),
      'colour': serializer.toJson<String?>(colour),
      'weight': serializer.toJson<double?>(weight),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  AnimalRow copyWith(
          {String? id,
          String? livestockTypeId,
          Value<String?> tag = const Value.absent(),
          Value<String?> name = const Value.absent(),
          Value<String?> animalGroup = const Value.absent(),
          String? sex,
          Value<DateTime?> birthDate = const Value.absent(),
          DateTime? acquisitionDate,
          String? acquisitionType,
          Value<double?> acquisitionCost = const Value.absent(),
          String? status,
          Value<String?> breed = const Value.absent(),
          Value<String?> colour = const Value.absent(),
          Value<double?> weight = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      AnimalRow(
        id: id ?? this.id,
        livestockTypeId: livestockTypeId ?? this.livestockTypeId,
        tag: tag.present ? tag.value : this.tag,
        name: name.present ? name.value : this.name,
        animalGroup: animalGroup.present ? animalGroup.value : this.animalGroup,
        sex: sex ?? this.sex,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        acquisitionDate: acquisitionDate ?? this.acquisitionDate,
        acquisitionType: acquisitionType ?? this.acquisitionType,
        acquisitionCost: acquisitionCost.present
            ? acquisitionCost.value
            : this.acquisitionCost,
        status: status ?? this.status,
        breed: breed.present ? breed.value : this.breed,
        colour: colour.present ? colour.value : this.colour,
        weight: weight.present ? weight.value : this.weight,
        notes: notes.present ? notes.value : this.notes,
      );
  AnimalRow copyWithCompanion(AnimalsCompanion data) {
    return AnimalRow(
      id: data.id.present ? data.id.value : this.id,
      livestockTypeId: data.livestockTypeId.present
          ? data.livestockTypeId.value
          : this.livestockTypeId,
      tag: data.tag.present ? data.tag.value : this.tag,
      name: data.name.present ? data.name.value : this.name,
      animalGroup:
          data.animalGroup.present ? data.animalGroup.value : this.animalGroup,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      acquisitionDate: data.acquisitionDate.present
          ? data.acquisitionDate.value
          : this.acquisitionDate,
      acquisitionType: data.acquisitionType.present
          ? data.acquisitionType.value
          : this.acquisitionType,
      acquisitionCost: data.acquisitionCost.present
          ? data.acquisitionCost.value
          : this.acquisitionCost,
      status: data.status.present ? data.status.value : this.status,
      breed: data.breed.present ? data.breed.value : this.breed,
      colour: data.colour.present ? data.colour.value : this.colour,
      weight: data.weight.present ? data.weight.value : this.weight,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalRow(')
          ..write('id: $id, ')
          ..write('livestockTypeId: $livestockTypeId, ')
          ..write('tag: $tag, ')
          ..write('name: $name, ')
          ..write('animalGroup: $animalGroup, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('acquisitionDate: $acquisitionDate, ')
          ..write('acquisitionType: $acquisitionType, ')
          ..write('acquisitionCost: $acquisitionCost, ')
          ..write('status: $status, ')
          ..write('breed: $breed, ')
          ..write('colour: $colour, ')
          ..write('weight: $weight, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      livestockTypeId,
      tag,
      name,
      animalGroup,
      sex,
      birthDate,
      acquisitionDate,
      acquisitionType,
      acquisitionCost,
      status,
      breed,
      colour,
      weight,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalRow &&
          other.id == this.id &&
          other.livestockTypeId == this.livestockTypeId &&
          other.tag == this.tag &&
          other.name == this.name &&
          other.animalGroup == this.animalGroup &&
          other.sex == this.sex &&
          other.birthDate == this.birthDate &&
          other.acquisitionDate == this.acquisitionDate &&
          other.acquisitionType == this.acquisitionType &&
          other.acquisitionCost == this.acquisitionCost &&
          other.status == this.status &&
          other.breed == this.breed &&
          other.colour == this.colour &&
          other.weight == this.weight &&
          other.notes == this.notes);
}

class AnimalsCompanion extends UpdateCompanion<AnimalRow> {
  final Value<String> id;
  final Value<String> livestockTypeId;
  final Value<String?> tag;
  final Value<String?> name;
  final Value<String?> animalGroup;
  final Value<String> sex;
  final Value<DateTime?> birthDate;
  final Value<DateTime> acquisitionDate;
  final Value<String> acquisitionType;
  final Value<double?> acquisitionCost;
  final Value<String> status;
  final Value<String?> breed;
  final Value<String?> colour;
  final Value<double?> weight;
  final Value<String?> notes;
  final Value<int> rowid;
  const AnimalsCompanion({
    this.id = const Value.absent(),
    this.livestockTypeId = const Value.absent(),
    this.tag = const Value.absent(),
    this.name = const Value.absent(),
    this.animalGroup = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.acquisitionDate = const Value.absent(),
    this.acquisitionType = const Value.absent(),
    this.acquisitionCost = const Value.absent(),
    this.status = const Value.absent(),
    this.breed = const Value.absent(),
    this.colour = const Value.absent(),
    this.weight = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalsCompanion.insert({
    required String id,
    required String livestockTypeId,
    this.tag = const Value.absent(),
    this.name = const Value.absent(),
    this.animalGroup = const Value.absent(),
    required String sex,
    this.birthDate = const Value.absent(),
    required DateTime acquisitionDate,
    required String acquisitionType,
    this.acquisitionCost = const Value.absent(),
    this.status = const Value.absent(),
    this.breed = const Value.absent(),
    this.colour = const Value.absent(),
    this.weight = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        livestockTypeId = Value(livestockTypeId),
        sex = Value(sex),
        acquisitionDate = Value(acquisitionDate),
        acquisitionType = Value(acquisitionType);
  static Insertable<AnimalRow> custom({
    Expression<String>? id,
    Expression<String>? livestockTypeId,
    Expression<String>? tag,
    Expression<String>? name,
    Expression<String>? animalGroup,
    Expression<String>? sex,
    Expression<DateTime>? birthDate,
    Expression<DateTime>? acquisitionDate,
    Expression<String>? acquisitionType,
    Expression<double>? acquisitionCost,
    Expression<String>? status,
    Expression<String>? breed,
    Expression<String>? colour,
    Expression<double>? weight,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (livestockTypeId != null) 'livestock_type_id': livestockTypeId,
      if (tag != null) 'tag': tag,
      if (name != null) 'name': name,
      if (animalGroup != null) 'animal_group': animalGroup,
      if (sex != null) 'sex': sex,
      if (birthDate != null) 'birth_date': birthDate,
      if (acquisitionDate != null) 'acquisition_date': acquisitionDate,
      if (acquisitionType != null) 'acquisition_type': acquisitionType,
      if (acquisitionCost != null) 'acquisition_cost': acquisitionCost,
      if (status != null) 'status': status,
      if (breed != null) 'breed': breed,
      if (colour != null) 'colour': colour,
      if (weight != null) 'weight': weight,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? livestockTypeId,
      Value<String?>? tag,
      Value<String?>? name,
      Value<String?>? animalGroup,
      Value<String>? sex,
      Value<DateTime?>? birthDate,
      Value<DateTime>? acquisitionDate,
      Value<String>? acquisitionType,
      Value<double?>? acquisitionCost,
      Value<String>? status,
      Value<String?>? breed,
      Value<String?>? colour,
      Value<double?>? weight,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return AnimalsCompanion(
      id: id ?? this.id,
      livestockTypeId: livestockTypeId ?? this.livestockTypeId,
      tag: tag ?? this.tag,
      name: name ?? this.name,
      animalGroup: animalGroup ?? this.animalGroup,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      acquisitionType: acquisitionType ?? this.acquisitionType,
      acquisitionCost: acquisitionCost ?? this.acquisitionCost,
      status: status ?? this.status,
      breed: breed ?? this.breed,
      colour: colour ?? this.colour,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (livestockTypeId.present) {
      map['livestock_type_id'] = Variable<String>(livestockTypeId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (animalGroup.present) {
      map['animal_group'] = Variable<String>(animalGroup.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (acquisitionDate.present) {
      map['acquisition_date'] = Variable<DateTime>(acquisitionDate.value);
    }
    if (acquisitionType.present) {
      map['acquisition_type'] = Variable<String>(acquisitionType.value);
    }
    if (acquisitionCost.present) {
      map['acquisition_cost'] = Variable<double>(acquisitionCost.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalsCompanion(')
          ..write('id: $id, ')
          ..write('livestockTypeId: $livestockTypeId, ')
          ..write('tag: $tag, ')
          ..write('name: $name, ')
          ..write('animalGroup: $animalGroup, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('acquisitionDate: $acquisitionDate, ')
          ..write('acquisitionType: $acquisitionType, ')
          ..write('acquisitionCost: $acquisitionCost, ')
          ..write('status: $status, ')
          ..write('breed: $breed, ')
          ..write('colour: $colour, ')
          ..write('weight: $weight, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalHealthRecordsTable extends AnimalHealthRecords
    with TableInfo<$AnimalHealthRecordsTable, AnimalHealthRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalHealthRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _veterinarianMeta =
      const VerificationMeta('veterinarian');
  @override
  late final GeneratedColumn<String> veterinarian = GeneratedColumn<String>(
      'veterinarian', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
      'cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _nextDueDateMeta =
      const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
      'next_due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        animalId,
        type,
        description,
        veterinarian,
        cost,
        date,
        nextDueDate,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animal_health_records';
  @override
  VerificationContext validateIntegrity(Insertable<AnimalHealthRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('veterinarian')) {
      context.handle(
          _veterinarianMeta,
          veterinarian.isAcceptableOrUnknown(
              data['veterinarian']!, _veterinarianMeta));
    }
    if (data.containsKey('cost')) {
      context.handle(
          _costMeta, cost.isAcceptableOrUnknown(data['cost']!, _costMeta));
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
          _nextDueDateMeta,
          nextDueDate.isAcceptableOrUnknown(
              data['next_due_date']!, _nextDueDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimalHealthRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalHealthRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      veterinarian: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}veterinarian']),
      cost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      nextDueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_due_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $AnimalHealthRecordsTable createAlias(String alias) {
    return $AnimalHealthRecordsTable(attachedDatabase, alias);
  }
}

class AnimalHealthRecord extends DataClass
    implements Insertable<AnimalHealthRecord> {
  final String id;
  final String animalId;
  final String type;
  final String description;
  final String? veterinarian;
  final double cost;
  final DateTime date;
  final DateTime? nextDueDate;
  final String? notes;
  const AnimalHealthRecord(
      {required this.id,
      required this.animalId,
      required this.type,
      required this.description,
      this.veterinarian,
      required this.cost,
      required this.date,
      this.nextDueDate,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['animal_id'] = Variable<String>(animalId);
    map['type'] = Variable<String>(type);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || veterinarian != null) {
      map['veterinarian'] = Variable<String>(veterinarian);
    }
    map['cost'] = Variable<double>(cost);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || nextDueDate != null) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AnimalHealthRecordsCompanion toCompanion(bool nullToAbsent) {
    return AnimalHealthRecordsCompanion(
      id: Value(id),
      animalId: Value(animalId),
      type: Value(type),
      description: Value(description),
      veterinarian: veterinarian == null && nullToAbsent
          ? const Value.absent()
          : Value(veterinarian),
      cost: Value(cost),
      date: Value(date),
      nextDueDate: nextDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory AnimalHealthRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalHealthRecord(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String>(json['description']),
      veterinarian: serializer.fromJson<String?>(json['veterinarian']),
      cost: serializer.fromJson<double>(json['cost']),
      date: serializer.fromJson<DateTime>(json['date']),
      nextDueDate: serializer.fromJson<DateTime?>(json['nextDueDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animalId': serializer.toJson<String>(animalId),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String>(description),
      'veterinarian': serializer.toJson<String?>(veterinarian),
      'cost': serializer.toJson<double>(cost),
      'date': serializer.toJson<DateTime>(date),
      'nextDueDate': serializer.toJson<DateTime?>(nextDueDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  AnimalHealthRecord copyWith(
          {String? id,
          String? animalId,
          String? type,
          String? description,
          Value<String?> veterinarian = const Value.absent(),
          double? cost,
          DateTime? date,
          Value<DateTime?> nextDueDate = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      AnimalHealthRecord(
        id: id ?? this.id,
        animalId: animalId ?? this.animalId,
        type: type ?? this.type,
        description: description ?? this.description,
        veterinarian:
            veterinarian.present ? veterinarian.value : this.veterinarian,
        cost: cost ?? this.cost,
        date: date ?? this.date,
        nextDueDate: nextDueDate.present ? nextDueDate.value : this.nextDueDate,
        notes: notes.present ? notes.value : this.notes,
      );
  AnimalHealthRecord copyWithCompanion(AnimalHealthRecordsCompanion data) {
    return AnimalHealthRecord(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      type: data.type.present ? data.type.value : this.type,
      description:
          data.description.present ? data.description.value : this.description,
      veterinarian: data.veterinarian.present
          ? data.veterinarian.value
          : this.veterinarian,
      cost: data.cost.present ? data.cost.value : this.cost,
      date: data.date.present ? data.date.value : this.date,
      nextDueDate:
          data.nextDueDate.present ? data.nextDueDate.value : this.nextDueDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalHealthRecord(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('veterinarian: $veterinarian, ')
          ..write('cost: $cost, ')
          ..write('date: $date, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, animalId, type, description, veterinarian,
      cost, date, nextDueDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalHealthRecord &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.type == this.type &&
          other.description == this.description &&
          other.veterinarian == this.veterinarian &&
          other.cost == this.cost &&
          other.date == this.date &&
          other.nextDueDate == this.nextDueDate &&
          other.notes == this.notes);
}

class AnimalHealthRecordsCompanion extends UpdateCompanion<AnimalHealthRecord> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<String> type;
  final Value<String> description;
  final Value<String?> veterinarian;
  final Value<double> cost;
  final Value<DateTime> date;
  final Value<DateTime?> nextDueDate;
  final Value<String?> notes;
  final Value<int> rowid;
  const AnimalHealthRecordsCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.veterinarian = const Value.absent(),
    this.cost = const Value.absent(),
    this.date = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalHealthRecordsCompanion.insert({
    required String id,
    required String animalId,
    required String type,
    required String description,
    this.veterinarian = const Value.absent(),
    required double cost,
    required DateTime date,
    this.nextDueDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        type = Value(type),
        description = Value(description),
        cost = Value(cost),
        date = Value(date);
  static Insertable<AnimalHealthRecord> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<String>? type,
    Expression<String>? description,
    Expression<String>? veterinarian,
    Expression<double>? cost,
    Expression<DateTime>? date,
    Expression<DateTime>? nextDueDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (veterinarian != null) 'veterinarian': veterinarian,
      if (cost != null) 'cost': cost,
      if (date != null) 'date': date,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalHealthRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? animalId,
      Value<String>? type,
      Value<String>? description,
      Value<String?>? veterinarian,
      Value<double>? cost,
      Value<DateTime>? date,
      Value<DateTime?>? nextDueDate,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return AnimalHealthRecordsCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      type: type ?? this.type,
      description: description ?? this.description,
      veterinarian: veterinarian ?? this.veterinarian,
      cost: cost ?? this.cost,
      date: date ?? this.date,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (veterinarian.present) {
      map['veterinarian'] = Variable<String>(veterinarian.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalHealthRecordsCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('veterinarian: $veterinarian, ')
          ..write('cost: $cost, ')
          ..write('date: $date, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalProductionRecordsTable extends AnimalProductionRecords
    with TableInfo<$AnimalProductionRecordsTable, AnimalProductionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalProductionRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pricePerUnitMeta =
      const VerificationMeta('pricePerUnit');
  @override
  late final GeneratedColumn<double> pricePerUnit = GeneratedColumn<double>(
      'price_per_unit', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalValueMeta =
      const VerificationMeta('totalValue');
  @override
  late final GeneratedColumn<double> totalValue = GeneratedColumn<double>(
      'total_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        animalId,
        type,
        quantity,
        unit,
        date,
        pricePerUnit,
        totalValue,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animal_production_records';
  @override
  VerificationContext validateIntegrity(
      Insertable<AnimalProductionRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('price_per_unit')) {
      context.handle(
          _pricePerUnitMeta,
          pricePerUnit.isAcceptableOrUnknown(
              data['price_per_unit']!, _pricePerUnitMeta));
    }
    if (data.containsKey('total_value')) {
      context.handle(
          _totalValueMeta,
          totalValue.isAcceptableOrUnknown(
              data['total_value']!, _totalValueMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimalProductionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalProductionRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      pricePerUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_per_unit']),
      totalValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_value']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $AnimalProductionRecordsTable createAlias(String alias) {
    return $AnimalProductionRecordsTable(attachedDatabase, alias);
  }
}

class AnimalProductionRecord extends DataClass
    implements Insertable<AnimalProductionRecord> {
  final String id;
  final String animalId;
  final String type;
  final double quantity;
  final String unit;
  final DateTime date;
  final double? pricePerUnit;
  final double? totalValue;
  final String? notes;
  const AnimalProductionRecord(
      {required this.id,
      required this.animalId,
      required this.type,
      required this.quantity,
      required this.unit,
      required this.date,
      this.pricePerUnit,
      this.totalValue,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['animal_id'] = Variable<String>(animalId);
    map['type'] = Variable<String>(type);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || pricePerUnit != null) {
      map['price_per_unit'] = Variable<double>(pricePerUnit);
    }
    if (!nullToAbsent || totalValue != null) {
      map['total_value'] = Variable<double>(totalValue);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AnimalProductionRecordsCompanion toCompanion(bool nullToAbsent) {
    return AnimalProductionRecordsCompanion(
      id: Value(id),
      animalId: Value(animalId),
      type: Value(type),
      quantity: Value(quantity),
      unit: Value(unit),
      date: Value(date),
      pricePerUnit: pricePerUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePerUnit),
      totalValue: totalValue == null && nullToAbsent
          ? const Value.absent()
          : Value(totalValue),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory AnimalProductionRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalProductionRecord(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      type: serializer.fromJson<String>(json['type']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      date: serializer.fromJson<DateTime>(json['date']),
      pricePerUnit: serializer.fromJson<double?>(json['pricePerUnit']),
      totalValue: serializer.fromJson<double?>(json['totalValue']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animalId': serializer.toJson<String>(animalId),
      'type': serializer.toJson<String>(type),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'date': serializer.toJson<DateTime>(date),
      'pricePerUnit': serializer.toJson<double?>(pricePerUnit),
      'totalValue': serializer.toJson<double?>(totalValue),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  AnimalProductionRecord copyWith(
          {String? id,
          String? animalId,
          String? type,
          double? quantity,
          String? unit,
          DateTime? date,
          Value<double?> pricePerUnit = const Value.absent(),
          Value<double?> totalValue = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      AnimalProductionRecord(
        id: id ?? this.id,
        animalId: animalId ?? this.animalId,
        type: type ?? this.type,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        date: date ?? this.date,
        pricePerUnit:
            pricePerUnit.present ? pricePerUnit.value : this.pricePerUnit,
        totalValue: totalValue.present ? totalValue.value : this.totalValue,
        notes: notes.present ? notes.value : this.notes,
      );
  AnimalProductionRecord copyWithCompanion(
      AnimalProductionRecordsCompanion data) {
    return AnimalProductionRecord(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      date: data.date.present ? data.date.value : this.date,
      pricePerUnit: data.pricePerUnit.present
          ? data.pricePerUnit.value
          : this.pricePerUnit,
      totalValue:
          data.totalValue.present ? data.totalValue.value : this.totalValue,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalProductionRecord(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('date: $date, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('totalValue: $totalValue, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, animalId, type, quantity, unit, date,
      pricePerUnit, totalValue, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalProductionRecord &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.date == this.date &&
          other.pricePerUnit == this.pricePerUnit &&
          other.totalValue == this.totalValue &&
          other.notes == this.notes);
}

class AnimalProductionRecordsCompanion
    extends UpdateCompanion<AnimalProductionRecord> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<String> type;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<DateTime> date;
  final Value<double?> pricePerUnit;
  final Value<double?> totalValue;
  final Value<String?> notes;
  final Value<int> rowid;
  const AnimalProductionRecordsCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.date = const Value.absent(),
    this.pricePerUnit = const Value.absent(),
    this.totalValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalProductionRecordsCompanion.insert({
    required String id,
    required String animalId,
    required String type,
    required double quantity,
    required String unit,
    required DateTime date,
    this.pricePerUnit = const Value.absent(),
    this.totalValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        type = Value(type),
        quantity = Value(quantity),
        unit = Value(unit),
        date = Value(date);
  static Insertable<AnimalProductionRecord> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<String>? type,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<DateTime>? date,
    Expression<double>? pricePerUnit,
    Expression<double>? totalValue,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (date != null) 'date': date,
      if (pricePerUnit != null) 'price_per_unit': pricePerUnit,
      if (totalValue != null) 'total_value': totalValue,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalProductionRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? animalId,
      Value<String>? type,
      Value<double>? quantity,
      Value<String>? unit,
      Value<DateTime>? date,
      Value<double?>? pricePerUnit,
      Value<double?>? totalValue,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return AnimalProductionRecordsCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalValue: totalValue ?? this.totalValue,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (pricePerUnit.present) {
      map['price_per_unit'] = Variable<double>(pricePerUnit.value);
    }
    if (totalValue.present) {
      map['total_value'] = Variable<double>(totalValue.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalProductionRecordsCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('date: $date, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('totalValue: $totalValue, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalWeightRecordsTable extends AnimalWeightRecords
    with TableInfo<$AnimalWeightRecordsTable, AnimalWeightRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalWeightRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, animalId, weight, unit, date, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animal_weight_records';
  @override
  VerificationContext validateIntegrity(Insertable<AnimalWeightRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimalWeightRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalWeightRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $AnimalWeightRecordsTable createAlias(String alias) {
    return $AnimalWeightRecordsTable(attachedDatabase, alias);
  }
}

class AnimalWeightRecord extends DataClass
    implements Insertable<AnimalWeightRecord> {
  final String id;
  final String animalId;
  final double weight;
  final String unit;
  final DateTime date;
  final String? notes;
  const AnimalWeightRecord(
      {required this.id,
      required this.animalId,
      required this.weight,
      required this.unit,
      required this.date,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['animal_id'] = Variable<String>(animalId);
    map['weight'] = Variable<double>(weight);
    map['unit'] = Variable<String>(unit);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AnimalWeightRecordsCompanion toCompanion(bool nullToAbsent) {
    return AnimalWeightRecordsCompanion(
      id: Value(id),
      animalId: Value(animalId),
      weight: Value(weight),
      unit: Value(unit),
      date: Value(date),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory AnimalWeightRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalWeightRecord(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      weight: serializer.fromJson<double>(json['weight']),
      unit: serializer.fromJson<String>(json['unit']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animalId': serializer.toJson<String>(animalId),
      'weight': serializer.toJson<double>(weight),
      'unit': serializer.toJson<String>(unit),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  AnimalWeightRecord copyWith(
          {String? id,
          String? animalId,
          double? weight,
          String? unit,
          DateTime? date,
          Value<String?> notes = const Value.absent()}) =>
      AnimalWeightRecord(
        id: id ?? this.id,
        animalId: animalId ?? this.animalId,
        weight: weight ?? this.weight,
        unit: unit ?? this.unit,
        date: date ?? this.date,
        notes: notes.present ? notes.value : this.notes,
      );
  AnimalWeightRecord copyWithCompanion(AnimalWeightRecordsCompanion data) {
    return AnimalWeightRecord(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      weight: data.weight.present ? data.weight.value : this.weight,
      unit: data.unit.present ? data.unit.value : this.unit,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalWeightRecord(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('weight: $weight, ')
          ..write('unit: $unit, ')
          ..write('date: $date, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, animalId, weight, unit, date, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalWeightRecord &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.weight == this.weight &&
          other.unit == this.unit &&
          other.date == this.date &&
          other.notes == this.notes);
}

class AnimalWeightRecordsCompanion extends UpdateCompanion<AnimalWeightRecord> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<double> weight;
  final Value<String> unit;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<int> rowid;
  const AnimalWeightRecordsCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.weight = const Value.absent(),
    this.unit = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalWeightRecordsCompanion.insert({
    required String id,
    required String animalId,
    required double weight,
    required String unit,
    required DateTime date,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        weight = Value(weight),
        unit = Value(unit),
        date = Value(date);
  static Insertable<AnimalWeightRecord> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<double>? weight,
    Expression<String>? unit,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (weight != null) 'weight': weight,
      if (unit != null) 'unit': unit,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalWeightRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? animalId,
      Value<double>? weight,
      Value<String>? unit,
      Value<DateTime>? date,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return AnimalWeightRecordsCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalWeightRecordsCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('weight: $weight, ')
          ..write('unit: $unit, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalExpenseRecordsTable extends AnimalExpenseRecords
    with TableInfo<$AnimalExpenseRecordsTable, AnimalExpenseRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalExpenseRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, animalId, category, description, amount, date, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animal_expense_records';
  @override
  VerificationContext validateIntegrity(
      Insertable<AnimalExpenseRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimalExpenseRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalExpenseRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $AnimalExpenseRecordsTable createAlias(String alias) {
    return $AnimalExpenseRecordsTable(attachedDatabase, alias);
  }
}

class AnimalExpenseRecord extends DataClass
    implements Insertable<AnimalExpenseRecord> {
  final String id;
  final String? animalId;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final String? notes;
  const AnimalExpenseRecord(
      {required this.id,
      this.animalId,
      required this.category,
      required this.description,
      required this.amount,
      required this.date,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || animalId != null) {
      map['animal_id'] = Variable<String>(animalId);
    }
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AnimalExpenseRecordsCompanion toCompanion(bool nullToAbsent) {
    return AnimalExpenseRecordsCompanion(
      id: Value(id),
      animalId: animalId == null && nullToAbsent
          ? const Value.absent()
          : Value(animalId),
      category: Value(category),
      description: Value(description),
      amount: Value(amount),
      date: Value(date),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory AnimalExpenseRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalExpenseRecord(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String?>(json['animalId']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animalId': serializer.toJson<String?>(animalId),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  AnimalExpenseRecord copyWith(
          {String? id,
          Value<String?> animalId = const Value.absent(),
          String? category,
          String? description,
          double? amount,
          DateTime? date,
          Value<String?> notes = const Value.absent()}) =>
      AnimalExpenseRecord(
        id: id ?? this.id,
        animalId: animalId.present ? animalId.value : this.animalId,
        category: category ?? this.category,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        notes: notes.present ? notes.value : this.notes,
      );
  AnimalExpenseRecord copyWithCompanion(AnimalExpenseRecordsCompanion data) {
    return AnimalExpenseRecord(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalExpenseRecord(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, animalId, category, description, amount, date, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalExpenseRecord &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.category == this.category &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.notes == this.notes);
}

class AnimalExpenseRecordsCompanion
    extends UpdateCompanion<AnimalExpenseRecord> {
  final Value<String> id;
  final Value<String?> animalId;
  final Value<String> category;
  final Value<String> description;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<int> rowid;
  const AnimalExpenseRecordsCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalExpenseRecordsCompanion.insert({
    required String id,
    this.animalId = const Value.absent(),
    required String category,
    required String description,
    required double amount,
    required DateTime date,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        description = Value(description),
        amount = Value(amount),
        date = Value(date);
  static Insertable<AnimalExpenseRecord> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<String>? category,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalExpenseRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? animalId,
      Value<String>? category,
      Value<String>? description,
      Value<double>? amount,
      Value<DateTime>? date,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return AnimalExpenseRecordsCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalExpenseRecordsCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalSaleRecordsTable extends AnimalSaleRecords
    with TableInfo<$AnimalSaleRecordsTable, AnimalSaleRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalSaleRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saleDateMeta =
      const VerificationMeta('saleDate');
  @override
  late final GeneratedColumn<DateTime> saleDate = GeneratedColumn<DateTime>(
      'sale_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _weightAtSaleMeta =
      const VerificationMeta('weightAtSale');
  @override
  late final GeneratedColumn<double> weightAtSale = GeneratedColumn<double>(
      'weight_at_sale', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _pricePerKgMeta =
      const VerificationMeta('pricePerKg');
  @override
  late final GeneratedColumn<double> pricePerKg = GeneratedColumn<double>(
      'price_per_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _buyerMeta = const VerificationMeta('buyer');
  @override
  late final GeneratedColumn<String> buyer = GeneratedColumn<String>(
      'buyer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        animalId,
        saleDate,
        quantity,
        weightAtSale,
        pricePerKg,
        totalAmount,
        buyer,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animal_sale_records';
  @override
  VerificationContext validateIntegrity(Insertable<AnimalSaleRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('sale_date')) {
      context.handle(_saleDateMeta,
          saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta));
    } else if (isInserting) {
      context.missing(_saleDateMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('weight_at_sale')) {
      context.handle(
          _weightAtSaleMeta,
          weightAtSale.isAcceptableOrUnknown(
              data['weight_at_sale']!, _weightAtSaleMeta));
    }
    if (data.containsKey('price_per_kg')) {
      context.handle(
          _pricePerKgMeta,
          pricePerKg.isAcceptableOrUnknown(
              data['price_per_kg']!, _pricePerKgMeta));
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('buyer')) {
      context.handle(
          _buyerMeta, buyer.isAcceptableOrUnknown(data['buyer']!, _buyerMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimalSaleRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalSaleRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      saleDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sale_date'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      weightAtSale: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_at_sale']),
      pricePerKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_per_kg']),
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      buyer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}buyer']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $AnimalSaleRecordsTable createAlias(String alias) {
    return $AnimalSaleRecordsTable(attachedDatabase, alias);
  }
}

class AnimalSaleRecord extends DataClass
    implements Insertable<AnimalSaleRecord> {
  final String id;
  final String animalId;
  final DateTime saleDate;
  final int quantity;
  final double? weightAtSale;
  final double? pricePerKg;
  final double totalAmount;
  final String? buyer;
  final String? notes;
  const AnimalSaleRecord(
      {required this.id,
      required this.animalId,
      required this.saleDate,
      required this.quantity,
      this.weightAtSale,
      this.pricePerKg,
      required this.totalAmount,
      this.buyer,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['animal_id'] = Variable<String>(animalId);
    map['sale_date'] = Variable<DateTime>(saleDate);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || weightAtSale != null) {
      map['weight_at_sale'] = Variable<double>(weightAtSale);
    }
    if (!nullToAbsent || pricePerKg != null) {
      map['price_per_kg'] = Variable<double>(pricePerKg);
    }
    map['total_amount'] = Variable<double>(totalAmount);
    if (!nullToAbsent || buyer != null) {
      map['buyer'] = Variable<String>(buyer);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AnimalSaleRecordsCompanion toCompanion(bool nullToAbsent) {
    return AnimalSaleRecordsCompanion(
      id: Value(id),
      animalId: Value(animalId),
      saleDate: Value(saleDate),
      quantity: Value(quantity),
      weightAtSale: weightAtSale == null && nullToAbsent
          ? const Value.absent()
          : Value(weightAtSale),
      pricePerKg: pricePerKg == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePerKg),
      totalAmount: Value(totalAmount),
      buyer:
          buyer == null && nullToAbsent ? const Value.absent() : Value(buyer),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory AnimalSaleRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalSaleRecord(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      saleDate: serializer.fromJson<DateTime>(json['saleDate']),
      quantity: serializer.fromJson<int>(json['quantity']),
      weightAtSale: serializer.fromJson<double?>(json['weightAtSale']),
      pricePerKg: serializer.fromJson<double?>(json['pricePerKg']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      buyer: serializer.fromJson<String?>(json['buyer']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animalId': serializer.toJson<String>(animalId),
      'saleDate': serializer.toJson<DateTime>(saleDate),
      'quantity': serializer.toJson<int>(quantity),
      'weightAtSale': serializer.toJson<double?>(weightAtSale),
      'pricePerKg': serializer.toJson<double?>(pricePerKg),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'buyer': serializer.toJson<String?>(buyer),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  AnimalSaleRecord copyWith(
          {String? id,
          String? animalId,
          DateTime? saleDate,
          int? quantity,
          Value<double?> weightAtSale = const Value.absent(),
          Value<double?> pricePerKg = const Value.absent(),
          double? totalAmount,
          Value<String?> buyer = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      AnimalSaleRecord(
        id: id ?? this.id,
        animalId: animalId ?? this.animalId,
        saleDate: saleDate ?? this.saleDate,
        quantity: quantity ?? this.quantity,
        weightAtSale:
            weightAtSale.present ? weightAtSale.value : this.weightAtSale,
        pricePerKg: pricePerKg.present ? pricePerKg.value : this.pricePerKg,
        totalAmount: totalAmount ?? this.totalAmount,
        buyer: buyer.present ? buyer.value : this.buyer,
        notes: notes.present ? notes.value : this.notes,
      );
  AnimalSaleRecord copyWithCompanion(AnimalSaleRecordsCompanion data) {
    return AnimalSaleRecord(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      weightAtSale: data.weightAtSale.present
          ? data.weightAtSale.value
          : this.weightAtSale,
      pricePerKg:
          data.pricePerKg.present ? data.pricePerKg.value : this.pricePerKg,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      buyer: data.buyer.present ? data.buyer.value : this.buyer,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalSaleRecord(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('saleDate: $saleDate, ')
          ..write('quantity: $quantity, ')
          ..write('weightAtSale: $weightAtSale, ')
          ..write('pricePerKg: $pricePerKg, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('buyer: $buyer, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, animalId, saleDate, quantity,
      weightAtSale, pricePerKg, totalAmount, buyer, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalSaleRecord &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.saleDate == this.saleDate &&
          other.quantity == this.quantity &&
          other.weightAtSale == this.weightAtSale &&
          other.pricePerKg == this.pricePerKg &&
          other.totalAmount == this.totalAmount &&
          other.buyer == this.buyer &&
          other.notes == this.notes);
}

class AnimalSaleRecordsCompanion extends UpdateCompanion<AnimalSaleRecord> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<DateTime> saleDate;
  final Value<int> quantity;
  final Value<double?> weightAtSale;
  final Value<double?> pricePerKg;
  final Value<double> totalAmount;
  final Value<String?> buyer;
  final Value<String?> notes;
  final Value<int> rowid;
  const AnimalSaleRecordsCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.quantity = const Value.absent(),
    this.weightAtSale = const Value.absent(),
    this.pricePerKg = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.buyer = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalSaleRecordsCompanion.insert({
    required String id,
    required String animalId,
    required DateTime saleDate,
    this.quantity = const Value.absent(),
    this.weightAtSale = const Value.absent(),
    this.pricePerKg = const Value.absent(),
    required double totalAmount,
    this.buyer = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        saleDate = Value(saleDate),
        totalAmount = Value(totalAmount);
  static Insertable<AnimalSaleRecord> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<DateTime>? saleDate,
    Expression<int>? quantity,
    Expression<double>? weightAtSale,
    Expression<double>? pricePerKg,
    Expression<double>? totalAmount,
    Expression<String>? buyer,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (saleDate != null) 'sale_date': saleDate,
      if (quantity != null) 'quantity': quantity,
      if (weightAtSale != null) 'weight_at_sale': weightAtSale,
      if (pricePerKg != null) 'price_per_kg': pricePerKg,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (buyer != null) 'buyer': buyer,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalSaleRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? animalId,
      Value<DateTime>? saleDate,
      Value<int>? quantity,
      Value<double?>? weightAtSale,
      Value<double?>? pricePerKg,
      Value<double>? totalAmount,
      Value<String?>? buyer,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return AnimalSaleRecordsCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      saleDate: saleDate ?? this.saleDate,
      quantity: quantity ?? this.quantity,
      weightAtSale: weightAtSale ?? this.weightAtSale,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      totalAmount: totalAmount ?? this.totalAmount,
      buyer: buyer ?? this.buyer,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<DateTime>(saleDate.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (weightAtSale.present) {
      map['weight_at_sale'] = Variable<double>(weightAtSale.value);
    }
    if (pricePerKg.present) {
      map['price_per_kg'] = Variable<double>(pricePerKg.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (buyer.present) {
      map['buyer'] = Variable<String>(buyer.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalSaleRecordsCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('saleDate: $saleDate, ')
          ..write('quantity: $quantity, ')
          ..write('weightAtSale: $weightAtSale, ')
          ..write('pricePerKg: $pricePerKg, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('buyer: $buyer, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FarmProfileTable farmProfile = $FarmProfileTable(this);
  late final $FieldsTable fields = $FieldsTable(this);
  late final $FieldBoundariesTable fieldBoundaries =
      $FieldBoundariesTable(this);
  late final $FieldZonesTable fieldZones = $FieldZonesTable(this);
  late final $FarmMarkersTable farmMarkers = $FarmMarkersTable(this);
  late final $CropTypesTable cropTypes = $CropTypesTable(this);
  late final $CropFieldsTable cropFields = $CropFieldsTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $ActivityInputsTable activityInputs = $ActivityInputsTable(this);
  late final $ActivityLabourRecordsTable activityLabourRecords =
      $ActivityLabourRecordsTable(this);
  late final $ActivityOtherCostsTable activityOtherCosts =
      $ActivityOtherCostsTable(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $OverheadExpensesTable overheadExpenses =
      $OverheadExpensesTable(this);
  late final $HarvestYieldsTable harvestYields = $HarvestYieldsTable(this);
  late final $InventoryItemsTable inventoryItems = $InventoryItemsTable(this);
  late final $InventorySalesTable inventorySales = $InventorySalesTable(this);
  late final $FarmDocumentsTable farmDocuments = $FarmDocumentsTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $LivestockTypesTable livestockTypes = $LivestockTypesTable(this);
  late final $AnimalsTable animals = $AnimalsTable(this);
  late final $AnimalHealthRecordsTable animalHealthRecords =
      $AnimalHealthRecordsTable(this);
  late final $AnimalProductionRecordsTable animalProductionRecords =
      $AnimalProductionRecordsTable(this);
  late final $AnimalWeightRecordsTable animalWeightRecords =
      $AnimalWeightRecordsTable(this);
  late final $AnimalExpenseRecordsTable animalExpenseRecords =
      $AnimalExpenseRecordsTable(this);
  late final $AnimalSaleRecordsTable animalSaleRecords =
      $AnimalSaleRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        farmProfile,
        fields,
        fieldBoundaries,
        fieldZones,
        farmMarkers,
        cropTypes,
        cropFields,
        activities,
        activityInputs,
        activityLabourRecords,
        activityOtherCosts,
        employees,
        transactions,
        overheadExpenses,
        harvestYields,
        inventoryItems,
        inventorySales,
        farmDocuments,
        notifications,
        livestockTypes,
        animals,
        animalHealthRecords,
        animalProductionRecords,
        animalWeightRecords,
        animalExpenseRecords,
        animalSaleRecords
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$FarmProfileTableCreateCompanionBuilder = FarmProfileCompanion
    Function({
  required String id,
  required String name,
  required String location,
  Value<double?> locationLat,
  Value<double?> locationLng,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$FarmProfileTableUpdateCompanionBuilder = FarmProfileCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> location,
  Value<double?> locationLat,
  Value<double?> locationLng,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$FarmProfileTableFilterComposer
    extends Composer<_$AppDatabase, $FarmProfileTable> {
  $$FarmProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FarmProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmProfileTable> {
  $$FarmProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FarmProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmProfileTable> {
  $$FarmProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => column);

  GeneratedColumn<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FarmProfileTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FarmProfileTable,
    FarmProfileData,
    $$FarmProfileTableFilterComposer,
    $$FarmProfileTableOrderingComposer,
    $$FarmProfileTableAnnotationComposer,
    $$FarmProfileTableCreateCompanionBuilder,
    $$FarmProfileTableUpdateCompanionBuilder,
    (
      FarmProfileData,
      BaseReferences<_$AppDatabase, $FarmProfileTable, FarmProfileData>
    ),
    FarmProfileData,
    PrefetchHooks Function()> {
  $$FarmProfileTableTableManager(_$AppDatabase db, $FarmProfileTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<double?> locationLat = const Value.absent(),
            Value<double?> locationLng = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmProfileCompanion(
            id: id,
            name: name,
            location: location,
            locationLat: locationLat,
            locationLng: locationLng,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String location,
            Value<double?> locationLat = const Value.absent(),
            Value<double?> locationLng = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmProfileCompanion.insert(
            id: id,
            name: name,
            location: location,
            locationLat: locationLat,
            locationLng: locationLng,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FarmProfileTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FarmProfileTable,
    FarmProfileData,
    $$FarmProfileTableFilterComposer,
    $$FarmProfileTableOrderingComposer,
    $$FarmProfileTableAnnotationComposer,
    $$FarmProfileTableCreateCompanionBuilder,
    $$FarmProfileTableUpdateCompanionBuilder,
    (
      FarmProfileData,
      BaseReferences<_$AppDatabase, $FarmProfileTable, FarmProfileData>
    ),
    FarmProfileData,
    PrefetchHooks Function()>;
typedef $$FieldsTableCreateCompanionBuilder = FieldsCompanion Function({
  required String id,
  required String name,
  required double totalArea,
  required double cultivatableArea,
  required String soilType,
  Value<double?> locationLat,
  Value<double?> locationLng,
  Value<String?> notes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$FieldsTableUpdateCompanionBuilder = FieldsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> totalArea,
  Value<double> cultivatableArea,
  Value<String> soilType,
  Value<double?> locationLat,
  Value<double?> locationLng,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$FieldsTableFilterComposer
    extends Composer<_$AppDatabase, $FieldsTable> {
  $$FieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalArea => $composableBuilder(
      column: $table.totalArea, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cultivatableArea => $composableBuilder(
      column: $table.cultivatableArea,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get soilType => $composableBuilder(
      column: $table.soilType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FieldsTableOrderingComposer
    extends Composer<_$AppDatabase, $FieldsTable> {
  $$FieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalArea => $composableBuilder(
      column: $table.totalArea, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cultivatableArea => $composableBuilder(
      column: $table.cultivatableArea,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get soilType => $composableBuilder(
      column: $table.soilType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FieldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FieldsTable> {
  $$FieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get totalArea =>
      $composableBuilder(column: $table.totalArea, builder: (column) => column);

  GeneratedColumn<double> get cultivatableArea => $composableBuilder(
      column: $table.cultivatableArea, builder: (column) => column);

  GeneratedColumn<String> get soilType =>
      $composableBuilder(column: $table.soilType, builder: (column) => column);

  GeneratedColumn<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => column);

  GeneratedColumn<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FieldsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FieldsTable,
    Field,
    $$FieldsTableFilterComposer,
    $$FieldsTableOrderingComposer,
    $$FieldsTableAnnotationComposer,
    $$FieldsTableCreateCompanionBuilder,
    $$FieldsTableUpdateCompanionBuilder,
    (Field, BaseReferences<_$AppDatabase, $FieldsTable, Field>),
    Field,
    PrefetchHooks Function()> {
  $$FieldsTableTableManager(_$AppDatabase db, $FieldsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FieldsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> totalArea = const Value.absent(),
            Value<double> cultivatableArea = const Value.absent(),
            Value<String> soilType = const Value.absent(),
            Value<double?> locationLat = const Value.absent(),
            Value<double?> locationLng = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FieldsCompanion(
            id: id,
            name: name,
            totalArea: totalArea,
            cultivatableArea: cultivatableArea,
            soilType: soilType,
            locationLat: locationLat,
            locationLng: locationLng,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required double totalArea,
            required double cultivatableArea,
            required String soilType,
            Value<double?> locationLat = const Value.absent(),
            Value<double?> locationLng = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FieldsCompanion.insert(
            id: id,
            name: name,
            totalArea: totalArea,
            cultivatableArea: cultivatableArea,
            soilType: soilType,
            locationLat: locationLat,
            locationLng: locationLng,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FieldsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FieldsTable,
    Field,
    $$FieldsTableFilterComposer,
    $$FieldsTableOrderingComposer,
    $$FieldsTableAnnotationComposer,
    $$FieldsTableCreateCompanionBuilder,
    $$FieldsTableUpdateCompanionBuilder,
    (Field, BaseReferences<_$AppDatabase, $FieldsTable, Field>),
    Field,
    PrefetchHooks Function()>;
typedef $$FieldBoundariesTableCreateCompanionBuilder = FieldBoundariesCompanion
    Function({
  required String id,
  required String fieldId,
  required String geoJson,
  Value<double?> areaHa,
  Value<double?> centroidLat,
  Value<double?> centroidLng,
  Value<int> rowid,
});
typedef $$FieldBoundariesTableUpdateCompanionBuilder = FieldBoundariesCompanion
    Function({
  Value<String> id,
  Value<String> fieldId,
  Value<String> geoJson,
  Value<double?> areaHa,
  Value<double?> centroidLat,
  Value<double?> centroidLng,
  Value<int> rowid,
});

class $$FieldBoundariesTableFilterComposer
    extends Composer<_$AppDatabase, $FieldBoundariesTable> {
  $$FieldBoundariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get geoJson => $composableBuilder(
      column: $table.geoJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get areaHa => $composableBuilder(
      column: $table.areaHa, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get centroidLat => $composableBuilder(
      column: $table.centroidLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get centroidLng => $composableBuilder(
      column: $table.centroidLng, builder: (column) => ColumnFilters(column));
}

class $$FieldBoundariesTableOrderingComposer
    extends Composer<_$AppDatabase, $FieldBoundariesTable> {
  $$FieldBoundariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geoJson => $composableBuilder(
      column: $table.geoJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get areaHa => $composableBuilder(
      column: $table.areaHa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get centroidLat => $composableBuilder(
      column: $table.centroidLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get centroidLng => $composableBuilder(
      column: $table.centroidLng, builder: (column) => ColumnOrderings(column));
}

class $$FieldBoundariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FieldBoundariesTable> {
  $$FieldBoundariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fieldId =>
      $composableBuilder(column: $table.fieldId, builder: (column) => column);

  GeneratedColumn<String> get geoJson =>
      $composableBuilder(column: $table.geoJson, builder: (column) => column);

  GeneratedColumn<double> get areaHa =>
      $composableBuilder(column: $table.areaHa, builder: (column) => column);

  GeneratedColumn<double> get centroidLat => $composableBuilder(
      column: $table.centroidLat, builder: (column) => column);

  GeneratedColumn<double> get centroidLng => $composableBuilder(
      column: $table.centroidLng, builder: (column) => column);
}

class $$FieldBoundariesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FieldBoundariesTable,
    FieldBoundaryRow,
    $$FieldBoundariesTableFilterComposer,
    $$FieldBoundariesTableOrderingComposer,
    $$FieldBoundariesTableAnnotationComposer,
    $$FieldBoundariesTableCreateCompanionBuilder,
    $$FieldBoundariesTableUpdateCompanionBuilder,
    (
      FieldBoundaryRow,
      BaseReferences<_$AppDatabase, $FieldBoundariesTable, FieldBoundaryRow>
    ),
    FieldBoundaryRow,
    PrefetchHooks Function()> {
  $$FieldBoundariesTableTableManager(
      _$AppDatabase db, $FieldBoundariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldBoundariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldBoundariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FieldBoundariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fieldId = const Value.absent(),
            Value<String> geoJson = const Value.absent(),
            Value<double?> areaHa = const Value.absent(),
            Value<double?> centroidLat = const Value.absent(),
            Value<double?> centroidLng = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FieldBoundariesCompanion(
            id: id,
            fieldId: fieldId,
            geoJson: geoJson,
            areaHa: areaHa,
            centroidLat: centroidLat,
            centroidLng: centroidLng,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fieldId,
            required String geoJson,
            Value<double?> areaHa = const Value.absent(),
            Value<double?> centroidLat = const Value.absent(),
            Value<double?> centroidLng = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FieldBoundariesCompanion.insert(
            id: id,
            fieldId: fieldId,
            geoJson: geoJson,
            areaHa: areaHa,
            centroidLat: centroidLat,
            centroidLng: centroidLng,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FieldBoundariesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FieldBoundariesTable,
    FieldBoundaryRow,
    $$FieldBoundariesTableFilterComposer,
    $$FieldBoundariesTableOrderingComposer,
    $$FieldBoundariesTableAnnotationComposer,
    $$FieldBoundariesTableCreateCompanionBuilder,
    $$FieldBoundariesTableUpdateCompanionBuilder,
    (
      FieldBoundaryRow,
      BaseReferences<_$AppDatabase, $FieldBoundariesTable, FieldBoundaryRow>
    ),
    FieldBoundaryRow,
    PrefetchHooks Function()>;
typedef $$FieldZonesTableCreateCompanionBuilder = FieldZonesCompanion Function({
  required String id,
  required String boundaryId,
  required String fieldId,
  required String name,
  required String type,
  Value<String?> cropFieldId,
  required String geoJson,
  Value<double?> areaHa,
  Value<String?> colour,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$FieldZonesTableUpdateCompanionBuilder = FieldZonesCompanion Function({
  Value<String> id,
  Value<String> boundaryId,
  Value<String> fieldId,
  Value<String> name,
  Value<String> type,
  Value<String?> cropFieldId,
  Value<String> geoJson,
  Value<double?> areaHa,
  Value<String?> colour,
  Value<String?> notes,
  Value<int> rowid,
});

class $$FieldZonesTableFilterComposer
    extends Composer<_$AppDatabase, $FieldZonesTable> {
  $$FieldZonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boundaryId => $composableBuilder(
      column: $table.boundaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get geoJson => $composableBuilder(
      column: $table.geoJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get areaHa => $composableBuilder(
      column: $table.areaHa, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colour => $composableBuilder(
      column: $table.colour, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$FieldZonesTableOrderingComposer
    extends Composer<_$AppDatabase, $FieldZonesTable> {
  $$FieldZonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boundaryId => $composableBuilder(
      column: $table.boundaryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geoJson => $composableBuilder(
      column: $table.geoJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get areaHa => $composableBuilder(
      column: $table.areaHa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colour => $composableBuilder(
      column: $table.colour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$FieldZonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FieldZonesTable> {
  $$FieldZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get boundaryId => $composableBuilder(
      column: $table.boundaryId, builder: (column) => column);

  GeneratedColumn<String> get fieldId =>
      $composableBuilder(column: $table.fieldId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => column);

  GeneratedColumn<String> get geoJson =>
      $composableBuilder(column: $table.geoJson, builder: (column) => column);

  GeneratedColumn<double> get areaHa =>
      $composableBuilder(column: $table.areaHa, builder: (column) => column);

  GeneratedColumn<String> get colour =>
      $composableBuilder(column: $table.colour, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$FieldZonesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FieldZonesTable,
    FieldZoneRow,
    $$FieldZonesTableFilterComposer,
    $$FieldZonesTableOrderingComposer,
    $$FieldZonesTableAnnotationComposer,
    $$FieldZonesTableCreateCompanionBuilder,
    $$FieldZonesTableUpdateCompanionBuilder,
    (
      FieldZoneRow,
      BaseReferences<_$AppDatabase, $FieldZonesTable, FieldZoneRow>
    ),
    FieldZoneRow,
    PrefetchHooks Function()> {
  $$FieldZonesTableTableManager(_$AppDatabase db, $FieldZonesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FieldZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> boundaryId = const Value.absent(),
            Value<String> fieldId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> cropFieldId = const Value.absent(),
            Value<String> geoJson = const Value.absent(),
            Value<double?> areaHa = const Value.absent(),
            Value<String?> colour = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FieldZonesCompanion(
            id: id,
            boundaryId: boundaryId,
            fieldId: fieldId,
            name: name,
            type: type,
            cropFieldId: cropFieldId,
            geoJson: geoJson,
            areaHa: areaHa,
            colour: colour,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String boundaryId,
            required String fieldId,
            required String name,
            required String type,
            Value<String?> cropFieldId = const Value.absent(),
            required String geoJson,
            Value<double?> areaHa = const Value.absent(),
            Value<String?> colour = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FieldZonesCompanion.insert(
            id: id,
            boundaryId: boundaryId,
            fieldId: fieldId,
            name: name,
            type: type,
            cropFieldId: cropFieldId,
            geoJson: geoJson,
            areaHa: areaHa,
            colour: colour,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FieldZonesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FieldZonesTable,
    FieldZoneRow,
    $$FieldZonesTableFilterComposer,
    $$FieldZonesTableOrderingComposer,
    $$FieldZonesTableAnnotationComposer,
    $$FieldZonesTableCreateCompanionBuilder,
    $$FieldZonesTableUpdateCompanionBuilder,
    (
      FieldZoneRow,
      BaseReferences<_$AppDatabase, $FieldZonesTable, FieldZoneRow>
    ),
    FieldZoneRow,
    PrefetchHooks Function()>;
typedef $$FarmMarkersTableCreateCompanionBuilder = FarmMarkersCompanion
    Function({
  required String id,
  Value<String?> fieldId,
  required String type,
  required String label,
  required double lat,
  required double lng,
  Value<String?> notes,
  Value<String?> icon,
  Value<int> rowid,
});
typedef $$FarmMarkersTableUpdateCompanionBuilder = FarmMarkersCompanion
    Function({
  Value<String> id,
  Value<String?> fieldId,
  Value<String> type,
  Value<String> label,
  Value<double> lat,
  Value<double> lng,
  Value<String?> notes,
  Value<String?> icon,
  Value<int> rowid,
});

class $$FarmMarkersTableFilterComposer
    extends Composer<_$AppDatabase, $FarmMarkersTable> {
  $$FarmMarkersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));
}

class $$FarmMarkersTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmMarkersTable> {
  $$FarmMarkersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));
}

class $$FarmMarkersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmMarkersTable> {
  $$FarmMarkersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fieldId =>
      $composableBuilder(column: $table.fieldId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$FarmMarkersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FarmMarkersTable,
    FarmMarkerRow,
    $$FarmMarkersTableFilterComposer,
    $$FarmMarkersTableOrderingComposer,
    $$FarmMarkersTableAnnotationComposer,
    $$FarmMarkersTableCreateCompanionBuilder,
    $$FarmMarkersTableUpdateCompanionBuilder,
    (
      FarmMarkerRow,
      BaseReferences<_$AppDatabase, $FarmMarkersTable, FarmMarkerRow>
    ),
    FarmMarkerRow,
    PrefetchHooks Function()> {
  $$FarmMarkersTableTableManager(_$AppDatabase db, $FarmMarkersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmMarkersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmMarkersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmMarkersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> fieldId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmMarkersCompanion(
            id: id,
            fieldId: fieldId,
            type: type,
            label: label,
            lat: lat,
            lng: lng,
            notes: notes,
            icon: icon,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> fieldId = const Value.absent(),
            required String type,
            required String label,
            required double lat,
            required double lng,
            Value<String?> notes = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmMarkersCompanion.insert(
            id: id,
            fieldId: fieldId,
            type: type,
            label: label,
            lat: lat,
            lng: lng,
            notes: notes,
            icon: icon,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FarmMarkersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FarmMarkersTable,
    FarmMarkerRow,
    $$FarmMarkersTableFilterComposer,
    $$FarmMarkersTableOrderingComposer,
    $$FarmMarkersTableAnnotationComposer,
    $$FarmMarkersTableCreateCompanionBuilder,
    $$FarmMarkersTableUpdateCompanionBuilder,
    (
      FarmMarkerRow,
      BaseReferences<_$AppDatabase, $FarmMarkersTable, FarmMarkerRow>
    ),
    FarmMarkerRow,
    PrefetchHooks Function()>;
typedef $$CropTypesTableCreateCompanionBuilder = CropTypesCompanion Function({
  required String id,
  required String name,
  Value<bool> isCustom,
  Value<int> rowid,
});
typedef $$CropTypesTableUpdateCompanionBuilder = CropTypesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<bool> isCustom,
  Value<int> rowid,
});

class $$CropTypesTableFilterComposer
    extends Composer<_$AppDatabase, $CropTypesTable> {
  $$CropTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnFilters(column));
}

class $$CropTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $CropTypesTable> {
  $$CropTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnOrderings(column));
}

class $$CropTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CropTypesTable> {
  $$CropTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);
}

class $$CropTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CropTypesTable,
    CropTypeRow,
    $$CropTypesTableFilterComposer,
    $$CropTypesTableOrderingComposer,
    $$CropTypesTableAnnotationComposer,
    $$CropTypesTableCreateCompanionBuilder,
    $$CropTypesTableUpdateCompanionBuilder,
    (CropTypeRow, BaseReferences<_$AppDatabase, $CropTypesTable, CropTypeRow>),
    CropTypeRow,
    PrefetchHooks Function()> {
  $$CropTypesTableTableManager(_$AppDatabase db, $CropTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CropTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CropTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CropTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CropTypesCompanion(
            id: id,
            name: name,
            isCustom: isCustom,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<bool> isCustom = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CropTypesCompanion.insert(
            id: id,
            name: name,
            isCustom: isCustom,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CropTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CropTypesTable,
    CropTypeRow,
    $$CropTypesTableFilterComposer,
    $$CropTypesTableOrderingComposer,
    $$CropTypesTableAnnotationComposer,
    $$CropTypesTableCreateCompanionBuilder,
    $$CropTypesTableUpdateCompanionBuilder,
    (CropTypeRow, BaseReferences<_$AppDatabase, $CropTypesTable, CropTypeRow>),
    CropTypeRow,
    PrefetchHooks Function()>;
typedef $$CropFieldsTableCreateCompanionBuilder = CropFieldsCompanion Function({
  required String id,
  required String cropTypeId,
  required String fieldId,
  required String variety,
  required double areaPlanted,
  required String season,
  required DateTime plantingDate,
  required DateTime expectedHarvestDate,
  Value<String> status,
  Value<bool> isArchived,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CropFieldsTableUpdateCompanionBuilder = CropFieldsCompanion Function({
  Value<String> id,
  Value<String> cropTypeId,
  Value<String> fieldId,
  Value<String> variety,
  Value<double> areaPlanted,
  Value<String> season,
  Value<DateTime> plantingDate,
  Value<DateTime> expectedHarvestDate,
  Value<String> status,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CropFieldsTableFilterComposer
    extends Composer<_$AppDatabase, $CropFieldsTable> {
  $$CropFieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropTypeId => $composableBuilder(
      column: $table.cropTypeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variety => $composableBuilder(
      column: $table.variety, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get areaPlanted => $composableBuilder(
      column: $table.areaPlanted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get plantingDate => $composableBuilder(
      column: $table.plantingDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expectedHarvestDate => $composableBuilder(
      column: $table.expectedHarvestDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CropFieldsTableOrderingComposer
    extends Composer<_$AppDatabase, $CropFieldsTable> {
  $$CropFieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropTypeId => $composableBuilder(
      column: $table.cropTypeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variety => $composableBuilder(
      column: $table.variety, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get areaPlanted => $composableBuilder(
      column: $table.areaPlanted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get plantingDate => $composableBuilder(
      column: $table.plantingDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expectedHarvestDate => $composableBuilder(
      column: $table.expectedHarvestDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CropFieldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CropFieldsTable> {
  $$CropFieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cropTypeId => $composableBuilder(
      column: $table.cropTypeId, builder: (column) => column);

  GeneratedColumn<String> get fieldId =>
      $composableBuilder(column: $table.fieldId, builder: (column) => column);

  GeneratedColumn<String> get variety =>
      $composableBuilder(column: $table.variety, builder: (column) => column);

  GeneratedColumn<double> get areaPlanted => $composableBuilder(
      column: $table.areaPlanted, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<DateTime> get plantingDate => $composableBuilder(
      column: $table.plantingDate, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedHarvestDate => $composableBuilder(
      column: $table.expectedHarvestDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CropFieldsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CropFieldsTable,
    CropField,
    $$CropFieldsTableFilterComposer,
    $$CropFieldsTableOrderingComposer,
    $$CropFieldsTableAnnotationComposer,
    $$CropFieldsTableCreateCompanionBuilder,
    $$CropFieldsTableUpdateCompanionBuilder,
    (CropField, BaseReferences<_$AppDatabase, $CropFieldsTable, CropField>),
    CropField,
    PrefetchHooks Function()> {
  $$CropFieldsTableTableManager(_$AppDatabase db, $CropFieldsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CropFieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CropFieldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CropFieldsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cropTypeId = const Value.absent(),
            Value<String> fieldId = const Value.absent(),
            Value<String> variety = const Value.absent(),
            Value<double> areaPlanted = const Value.absent(),
            Value<String> season = const Value.absent(),
            Value<DateTime> plantingDate = const Value.absent(),
            Value<DateTime> expectedHarvestDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CropFieldsCompanion(
            id: id,
            cropTypeId: cropTypeId,
            fieldId: fieldId,
            variety: variety,
            areaPlanted: areaPlanted,
            season: season,
            plantingDate: plantingDate,
            expectedHarvestDate: expectedHarvestDate,
            status: status,
            isArchived: isArchived,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cropTypeId,
            required String fieldId,
            required String variety,
            required double areaPlanted,
            required String season,
            required DateTime plantingDate,
            required DateTime expectedHarvestDate,
            Value<String> status = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CropFieldsCompanion.insert(
            id: id,
            cropTypeId: cropTypeId,
            fieldId: fieldId,
            variety: variety,
            areaPlanted: areaPlanted,
            season: season,
            plantingDate: plantingDate,
            expectedHarvestDate: expectedHarvestDate,
            status: status,
            isArchived: isArchived,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CropFieldsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CropFieldsTable,
    CropField,
    $$CropFieldsTableFilterComposer,
    $$CropFieldsTableOrderingComposer,
    $$CropFieldsTableAnnotationComposer,
    $$CropFieldsTableCreateCompanionBuilder,
    $$CropFieldsTableUpdateCompanionBuilder,
    (CropField, BaseReferences<_$AppDatabase, $CropFieldsTable, CropField>),
    CropField,
    PrefetchHooks Function()>;
typedef $$ActivitiesTableCreateCompanionBuilder = ActivitiesCompanion Function({
  required String id,
  required String activityType,
  required DateTime date,
  Value<String?> notes,
  required String fieldId,
  Value<String?> cropFieldId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ActivitiesTableUpdateCompanionBuilder = ActivitiesCompanion Function({
  Value<String> id,
  Value<String> activityType,
  Value<DateTime> date,
  Value<String?> notes,
  Value<String> fieldId,
  Value<String?> cropFieldId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityType => $composableBuilder(
      column: $table.activityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityType => $composableBuilder(
      column: $table.activityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activityType => $composableBuilder(
      column: $table.activityType, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get fieldId =>
      $composableBuilder(column: $table.fieldId, builder: (column) => column);

  GeneratedColumn<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ActivitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivitiesTable,
    Activity,
    $$ActivitiesTableFilterComposer,
    $$ActivitiesTableOrderingComposer,
    $$ActivitiesTableAnnotationComposer,
    $$ActivitiesTableCreateCompanionBuilder,
    $$ActivitiesTableUpdateCompanionBuilder,
    (Activity, BaseReferences<_$AppDatabase, $ActivitiesTable, Activity>),
    Activity,
    PrefetchHooks Function()> {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> activityType = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> fieldId = const Value.absent(),
            Value<String?> cropFieldId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivitiesCompanion(
            id: id,
            activityType: activityType,
            date: date,
            notes: notes,
            fieldId: fieldId,
            cropFieldId: cropFieldId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String activityType,
            required DateTime date,
            Value<String?> notes = const Value.absent(),
            required String fieldId,
            Value<String?> cropFieldId = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivitiesCompanion.insert(
            id: id,
            activityType: activityType,
            date: date,
            notes: notes,
            fieldId: fieldId,
            cropFieldId: cropFieldId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActivitiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivitiesTable,
    Activity,
    $$ActivitiesTableFilterComposer,
    $$ActivitiesTableOrderingComposer,
    $$ActivitiesTableAnnotationComposer,
    $$ActivitiesTableCreateCompanionBuilder,
    $$ActivitiesTableUpdateCompanionBuilder,
    (Activity, BaseReferences<_$AppDatabase, $ActivitiesTable, Activity>),
    Activity,
    PrefetchHooks Function()>;
typedef $$ActivityInputsTableCreateCompanionBuilder = ActivityInputsCompanion
    Function({
  required String id,
  required String activityId,
  required String inputName,
  required String category,
  required double quantity,
  required String unit,
  required double unitCost,
  required double totalCost,
  Value<int> rowid,
});
typedef $$ActivityInputsTableUpdateCompanionBuilder = ActivityInputsCompanion
    Function({
  Value<String> id,
  Value<String> activityId,
  Value<String> inputName,
  Value<String> category,
  Value<double> quantity,
  Value<String> unit,
  Value<double> unitCost,
  Value<double> totalCost,
  Value<int> rowid,
});

class $$ActivityInputsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityInputsTable> {
  $$ActivityInputsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inputName => $composableBuilder(
      column: $table.inputName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalCost => $composableBuilder(
      column: $table.totalCost, builder: (column) => ColumnFilters(column));
}

class $$ActivityInputsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityInputsTable> {
  $$ActivityInputsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inputName => $composableBuilder(
      column: $table.inputName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalCost => $composableBuilder(
      column: $table.totalCost, builder: (column) => ColumnOrderings(column));
}

class $$ActivityInputsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityInputsTable> {
  $$ActivityInputsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => column);

  GeneratedColumn<String> get inputName =>
      $composableBuilder(column: $table.inputName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<double> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);
}

class $$ActivityInputsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityInputsTable,
    ActivityInputRow,
    $$ActivityInputsTableFilterComposer,
    $$ActivityInputsTableOrderingComposer,
    $$ActivityInputsTableAnnotationComposer,
    $$ActivityInputsTableCreateCompanionBuilder,
    $$ActivityInputsTableUpdateCompanionBuilder,
    (
      ActivityInputRow,
      BaseReferences<_$AppDatabase, $ActivityInputsTable, ActivityInputRow>
    ),
    ActivityInputRow,
    PrefetchHooks Function()> {
  $$ActivityInputsTableTableManager(
      _$AppDatabase db, $ActivityInputsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityInputsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityInputsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityInputsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> activityId = const Value.absent(),
            Value<String> inputName = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<double> totalCost = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityInputsCompanion(
            id: id,
            activityId: activityId,
            inputName: inputName,
            category: category,
            quantity: quantity,
            unit: unit,
            unitCost: unitCost,
            totalCost: totalCost,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String activityId,
            required String inputName,
            required String category,
            required double quantity,
            required String unit,
            required double unitCost,
            required double totalCost,
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityInputsCompanion.insert(
            id: id,
            activityId: activityId,
            inputName: inputName,
            category: category,
            quantity: quantity,
            unit: unit,
            unitCost: unitCost,
            totalCost: totalCost,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActivityInputsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivityInputsTable,
    ActivityInputRow,
    $$ActivityInputsTableFilterComposer,
    $$ActivityInputsTableOrderingComposer,
    $$ActivityInputsTableAnnotationComposer,
    $$ActivityInputsTableCreateCompanionBuilder,
    $$ActivityInputsTableUpdateCompanionBuilder,
    (
      ActivityInputRow,
      BaseReferences<_$AppDatabase, $ActivityInputsTable, ActivityInputRow>
    ),
    ActivityInputRow,
    PrefetchHooks Function()>;
typedef $$ActivityLabourRecordsTableCreateCompanionBuilder
    = ActivityLabourRecordsCompanion Function({
  required String id,
  required String activityId,
  required String employeeId,
  required double hoursWorked,
  required double daysWorked,
  required double totalCost,
  Value<int> rowid,
});
typedef $$ActivityLabourRecordsTableUpdateCompanionBuilder
    = ActivityLabourRecordsCompanion Function({
  Value<String> id,
  Value<String> activityId,
  Value<String> employeeId,
  Value<double> hoursWorked,
  Value<double> daysWorked,
  Value<double> totalCost,
  Value<int> rowid,
});

class $$ActivityLabourRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityLabourRecordsTable> {
  $$ActivityLabourRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get employeeId => $composableBuilder(
      column: $table.employeeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hoursWorked => $composableBuilder(
      column: $table.hoursWorked, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get daysWorked => $composableBuilder(
      column: $table.daysWorked, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalCost => $composableBuilder(
      column: $table.totalCost, builder: (column) => ColumnFilters(column));
}

class $$ActivityLabourRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityLabourRecordsTable> {
  $$ActivityLabourRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get employeeId => $composableBuilder(
      column: $table.employeeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hoursWorked => $composableBuilder(
      column: $table.hoursWorked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get daysWorked => $composableBuilder(
      column: $table.daysWorked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalCost => $composableBuilder(
      column: $table.totalCost, builder: (column) => ColumnOrderings(column));
}

class $$ActivityLabourRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityLabourRecordsTable> {
  $$ActivityLabourRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
      column: $table.employeeId, builder: (column) => column);

  GeneratedColumn<double> get hoursWorked => $composableBuilder(
      column: $table.hoursWorked, builder: (column) => column);

  GeneratedColumn<double> get daysWorked => $composableBuilder(
      column: $table.daysWorked, builder: (column) => column);

  GeneratedColumn<double> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);
}

class $$ActivityLabourRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityLabourRecordsTable,
    ActivityLabourRecord,
    $$ActivityLabourRecordsTableFilterComposer,
    $$ActivityLabourRecordsTableOrderingComposer,
    $$ActivityLabourRecordsTableAnnotationComposer,
    $$ActivityLabourRecordsTableCreateCompanionBuilder,
    $$ActivityLabourRecordsTableUpdateCompanionBuilder,
    (
      ActivityLabourRecord,
      BaseReferences<_$AppDatabase, $ActivityLabourRecordsTable,
          ActivityLabourRecord>
    ),
    ActivityLabourRecord,
    PrefetchHooks Function()> {
  $$ActivityLabourRecordsTableTableManager(
      _$AppDatabase db, $ActivityLabourRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityLabourRecordsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityLabourRecordsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityLabourRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> activityId = const Value.absent(),
            Value<String> employeeId = const Value.absent(),
            Value<double> hoursWorked = const Value.absent(),
            Value<double> daysWorked = const Value.absent(),
            Value<double> totalCost = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityLabourRecordsCompanion(
            id: id,
            activityId: activityId,
            employeeId: employeeId,
            hoursWorked: hoursWorked,
            daysWorked: daysWorked,
            totalCost: totalCost,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String activityId,
            required String employeeId,
            required double hoursWorked,
            required double daysWorked,
            required double totalCost,
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityLabourRecordsCompanion.insert(
            id: id,
            activityId: activityId,
            employeeId: employeeId,
            hoursWorked: hoursWorked,
            daysWorked: daysWorked,
            totalCost: totalCost,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActivityLabourRecordsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ActivityLabourRecordsTable,
        ActivityLabourRecord,
        $$ActivityLabourRecordsTableFilterComposer,
        $$ActivityLabourRecordsTableOrderingComposer,
        $$ActivityLabourRecordsTableAnnotationComposer,
        $$ActivityLabourRecordsTableCreateCompanionBuilder,
        $$ActivityLabourRecordsTableUpdateCompanionBuilder,
        (
          ActivityLabourRecord,
          BaseReferences<_$AppDatabase, $ActivityLabourRecordsTable,
              ActivityLabourRecord>
        ),
        ActivityLabourRecord,
        PrefetchHooks Function()>;
typedef $$ActivityOtherCostsTableCreateCompanionBuilder
    = ActivityOtherCostsCompanion Function({
  required String id,
  required String activityId,
  required String description,
  required double amount,
  Value<int> rowid,
});
typedef $$ActivityOtherCostsTableUpdateCompanionBuilder
    = ActivityOtherCostsCompanion Function({
  Value<String> id,
  Value<String> activityId,
  Value<String> description,
  Value<double> amount,
  Value<int> rowid,
});

class $$ActivityOtherCostsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityOtherCostsTable> {
  $$ActivityOtherCostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));
}

class $$ActivityOtherCostsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityOtherCostsTable> {
  $$ActivityOtherCostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));
}

class $$ActivityOtherCostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityOtherCostsTable> {
  $$ActivityOtherCostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);
}

class $$ActivityOtherCostsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityOtherCostsTable,
    ActivityOtherCostRow,
    $$ActivityOtherCostsTableFilterComposer,
    $$ActivityOtherCostsTableOrderingComposer,
    $$ActivityOtherCostsTableAnnotationComposer,
    $$ActivityOtherCostsTableCreateCompanionBuilder,
    $$ActivityOtherCostsTableUpdateCompanionBuilder,
    (
      ActivityOtherCostRow,
      BaseReferences<_$AppDatabase, $ActivityOtherCostsTable,
          ActivityOtherCostRow>
    ),
    ActivityOtherCostRow,
    PrefetchHooks Function()> {
  $$ActivityOtherCostsTableTableManager(
      _$AppDatabase db, $ActivityOtherCostsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityOtherCostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityOtherCostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityOtherCostsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> activityId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityOtherCostsCompanion(
            id: id,
            activityId: activityId,
            description: description,
            amount: amount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String activityId,
            required String description,
            required double amount,
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityOtherCostsCompanion.insert(
            id: id,
            activityId: activityId,
            description: description,
            amount: amount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActivityOtherCostsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivityOtherCostsTable,
    ActivityOtherCostRow,
    $$ActivityOtherCostsTableFilterComposer,
    $$ActivityOtherCostsTableOrderingComposer,
    $$ActivityOtherCostsTableAnnotationComposer,
    $$ActivityOtherCostsTableCreateCompanionBuilder,
    $$ActivityOtherCostsTableUpdateCompanionBuilder,
    (
      ActivityOtherCostRow,
      BaseReferences<_$AppDatabase, $ActivityOtherCostsTable,
          ActivityOtherCostRow>
    ),
    ActivityOtherCostRow,
    PrefetchHooks Function()>;
typedef $$EmployeesTableCreateCompanionBuilder = EmployeesCompanion Function({
  required String id,
  required String name,
  required String role,
  required double payRate,
  required String payRateUnit,
  Value<String?> phone,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$EmployeesTableUpdateCompanionBuilder = EmployeesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> role,
  Value<double> payRate,
  Value<String> payRateUnit,
  Value<String?> phone,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$EmployeesTableFilterComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get payRate => $composableBuilder(
      column: $table.payRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payRateUnit => $composableBuilder(
      column: $table.payRateUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$EmployeesTableOrderingComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get payRate => $composableBuilder(
      column: $table.payRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payRateUnit => $composableBuilder(
      column: $table.payRateUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$EmployeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<double> get payRate =>
      $composableBuilder(column: $table.payRate, builder: (column) => column);

  GeneratedColumn<String> get payRateUnit => $composableBuilder(
      column: $table.payRateUnit, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$EmployeesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EmployeesTable,
    Employee,
    $$EmployeesTableFilterComposer,
    $$EmployeesTableOrderingComposer,
    $$EmployeesTableAnnotationComposer,
    $$EmployeesTableCreateCompanionBuilder,
    $$EmployeesTableUpdateCompanionBuilder,
    (Employee, BaseReferences<_$AppDatabase, $EmployeesTable, Employee>),
    Employee,
    PrefetchHooks Function()> {
  $$EmployeesTableTableManager(_$AppDatabase db, $EmployeesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmployeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmployeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmployeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<double> payRate = const Value.absent(),
            Value<String> payRateUnit = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EmployeesCompanion(
            id: id,
            name: name,
            role: role,
            payRate: payRate,
            payRateUnit: payRateUnit,
            phone: phone,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String role,
            required double payRate,
            required String payRateUnit,
            Value<String?> phone = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EmployeesCompanion.insert(
            id: id,
            name: name,
            role: role,
            payRate: payRate,
            payRateUnit: payRateUnit,
            phone: phone,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EmployeesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EmployeesTable,
    Employee,
    $$EmployeesTableFilterComposer,
    $$EmployeesTableOrderingComposer,
    $$EmployeesTableAnnotationComposer,
    $$EmployeesTableCreateCompanionBuilder,
    $$EmployeesTableUpdateCompanionBuilder,
    (Employee, BaseReferences<_$AppDatabase, $EmployeesTable, Employee>),
    Employee,
    PrefetchHooks Function()>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String id,
  required String type,
  required String category,
  required double amount,
  required DateTime date,
  required String description,
  Value<String?> season,
  Value<String?> fieldId,
  Value<String?> cropFieldId,
  Value<String?> harvestYieldId,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String> category,
  Value<double> amount,
  Value<DateTime> date,
  Value<String> description,
  Value<String?> season,
  Value<String?> fieldId,
  Value<String?> cropFieldId,
  Value<String?> harvestYieldId,
  Value<int> rowid,
});

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get harvestYieldId => $composableBuilder(
      column: $table.harvestYieldId,
      builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldId => $composableBuilder(
      column: $table.fieldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get harvestYieldId => $composableBuilder(
      column: $table.harvestYieldId,
      builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get fieldId =>
      $composableBuilder(column: $table.fieldId, builder: (column) => column);

  GeneratedColumn<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => column);

  GeneratedColumn<String> get harvestYieldId => $composableBuilder(
      column: $table.harvestYieldId, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> season = const Value.absent(),
            Value<String?> fieldId = const Value.absent(),
            Value<String?> cropFieldId = const Value.absent(),
            Value<String?> harvestYieldId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            type: type,
            category: category,
            amount: amount,
            date: date,
            description: description,
            season: season,
            fieldId: fieldId,
            cropFieldId: cropFieldId,
            harvestYieldId: harvestYieldId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String category,
            required double amount,
            required DateTime date,
            required String description,
            Value<String?> season = const Value.absent(),
            Value<String?> fieldId = const Value.absent(),
            Value<String?> cropFieldId = const Value.absent(),
            Value<String?> harvestYieldId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            type: type,
            category: category,
            amount: amount,
            date: date,
            description: description,
            season: season,
            fieldId: fieldId,
            cropFieldId: cropFieldId,
            harvestYieldId: harvestYieldId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()>;
typedef $$OverheadExpensesTableCreateCompanionBuilder
    = OverheadExpensesCompanion Function({
  required String id,
  required String description,
  required String category,
  required double amount,
  required DateTime date,
  Value<bool> recurring,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$OverheadExpensesTableUpdateCompanionBuilder
    = OverheadExpensesCompanion Function({
  Value<String> id,
  Value<String> description,
  Value<String> category,
  Value<double> amount,
  Value<DateTime> date,
  Value<bool> recurring,
  Value<String?> notes,
  Value<int> rowid,
});

class $$OverheadExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $OverheadExpensesTable> {
  $$OverheadExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get recurring => $composableBuilder(
      column: $table.recurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$OverheadExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $OverheadExpensesTable> {
  $$OverheadExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get recurring => $composableBuilder(
      column: $table.recurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$OverheadExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OverheadExpensesTable> {
  $$OverheadExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get recurring =>
      $composableBuilder(column: $table.recurring, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$OverheadExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OverheadExpensesTable,
    OverheadExpenseRow,
    $$OverheadExpensesTableFilterComposer,
    $$OverheadExpensesTableOrderingComposer,
    $$OverheadExpensesTableAnnotationComposer,
    $$OverheadExpensesTableCreateCompanionBuilder,
    $$OverheadExpensesTableUpdateCompanionBuilder,
    (
      OverheadExpenseRow,
      BaseReferences<_$AppDatabase, $OverheadExpensesTable, OverheadExpenseRow>
    ),
    OverheadExpenseRow,
    PrefetchHooks Function()> {
  $$OverheadExpensesTableTableManager(
      _$AppDatabase db, $OverheadExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OverheadExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OverheadExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OverheadExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<bool> recurring = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OverheadExpensesCompanion(
            id: id,
            description: description,
            category: category,
            amount: amount,
            date: date,
            recurring: recurring,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String description,
            required String category,
            required double amount,
            required DateTime date,
            Value<bool> recurring = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OverheadExpensesCompanion.insert(
            id: id,
            description: description,
            category: category,
            amount: amount,
            date: date,
            recurring: recurring,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OverheadExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OverheadExpensesTable,
    OverheadExpenseRow,
    $$OverheadExpensesTableFilterComposer,
    $$OverheadExpensesTableOrderingComposer,
    $$OverheadExpensesTableAnnotationComposer,
    $$OverheadExpensesTableCreateCompanionBuilder,
    $$OverheadExpensesTableUpdateCompanionBuilder,
    (
      OverheadExpenseRow,
      BaseReferences<_$AppDatabase, $OverheadExpensesTable, OverheadExpenseRow>
    ),
    OverheadExpenseRow,
    PrefetchHooks Function()>;
typedef $$HarvestYieldsTableCreateCompanionBuilder = HarvestYieldsCompanion
    Function({
  required String id,
  required String cropFieldId,
  required DateTime harvestDate,
  required double quantity,
  required String unit,
  Value<double?> unitWeight,
  Value<String?> notes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$HarvestYieldsTableUpdateCompanionBuilder = HarvestYieldsCompanion
    Function({
  Value<String> id,
  Value<String> cropFieldId,
  Value<DateTime> harvestDate,
  Value<double> quantity,
  Value<String> unit,
  Value<double?> unitWeight,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$HarvestYieldsTableFilterComposer
    extends Composer<_$AppDatabase, $HarvestYieldsTable> {
  $$HarvestYieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get harvestDate => $composableBuilder(
      column: $table.harvestDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitWeight => $composableBuilder(
      column: $table.unitWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$HarvestYieldsTableOrderingComposer
    extends Composer<_$AppDatabase, $HarvestYieldsTable> {
  $$HarvestYieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get harvestDate => $composableBuilder(
      column: $table.harvestDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitWeight => $composableBuilder(
      column: $table.unitWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$HarvestYieldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HarvestYieldsTable> {
  $$HarvestYieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => column);

  GeneratedColumn<DateTime> get harvestDate => $composableBuilder(
      column: $table.harvestDate, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get unitWeight => $composableBuilder(
      column: $table.unitWeight, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HarvestYieldsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HarvestYieldsTable,
    HarvestYield,
    $$HarvestYieldsTableFilterComposer,
    $$HarvestYieldsTableOrderingComposer,
    $$HarvestYieldsTableAnnotationComposer,
    $$HarvestYieldsTableCreateCompanionBuilder,
    $$HarvestYieldsTableUpdateCompanionBuilder,
    (
      HarvestYield,
      BaseReferences<_$AppDatabase, $HarvestYieldsTable, HarvestYield>
    ),
    HarvestYield,
    PrefetchHooks Function()> {
  $$HarvestYieldsTableTableManager(_$AppDatabase db, $HarvestYieldsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HarvestYieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HarvestYieldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HarvestYieldsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cropFieldId = const Value.absent(),
            Value<DateTime> harvestDate = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double?> unitWeight = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HarvestYieldsCompanion(
            id: id,
            cropFieldId: cropFieldId,
            harvestDate: harvestDate,
            quantity: quantity,
            unit: unit,
            unitWeight: unitWeight,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cropFieldId,
            required DateTime harvestDate,
            required double quantity,
            required String unit,
            Value<double?> unitWeight = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              HarvestYieldsCompanion.insert(
            id: id,
            cropFieldId: cropFieldId,
            harvestDate: harvestDate,
            quantity: quantity,
            unit: unit,
            unitWeight: unitWeight,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HarvestYieldsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HarvestYieldsTable,
    HarvestYield,
    $$HarvestYieldsTableFilterComposer,
    $$HarvestYieldsTableOrderingComposer,
    $$HarvestYieldsTableAnnotationComposer,
    $$HarvestYieldsTableCreateCompanionBuilder,
    $$HarvestYieldsTableUpdateCompanionBuilder,
    (
      HarvestYield,
      BaseReferences<_$AppDatabase, $HarvestYieldsTable, HarvestYield>
    ),
    HarvestYield,
    PrefetchHooks Function()>;
typedef $$InventoryItemsTableCreateCompanionBuilder = InventoryItemsCompanion
    Function({
  required String id,
  required String name,
  required String category,
  required String unit,
  required double quantity,
  Value<double?> acquisitionUnitCost,
  Value<DateTime?> acquiredAt,
  Value<double?> unitWeight,
  Value<String?> season,
  Value<String?> cropFieldId,
  Value<String?> harvestYieldId,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$InventoryItemsTableUpdateCompanionBuilder = InventoryItemsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String> unit,
  Value<double> quantity,
  Value<double?> acquisitionUnitCost,
  Value<DateTime?> acquiredAt,
  Value<double?> unitWeight,
  Value<String?> season,
  Value<String?> cropFieldId,
  Value<String?> harvestYieldId,
  Value<String?> notes,
  Value<int> rowid,
});

class $$InventoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get acquisitionUnitCost => $composableBuilder(
      column: $table.acquisitionUnitCost,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get acquiredAt => $composableBuilder(
      column: $table.acquiredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitWeight => $composableBuilder(
      column: $table.unitWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get harvestYieldId => $composableBuilder(
      column: $table.harvestYieldId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$InventoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get acquisitionUnitCost => $composableBuilder(
      column: $table.acquisitionUnitCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get acquiredAt => $composableBuilder(
      column: $table.acquiredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitWeight => $composableBuilder(
      column: $table.unitWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get harvestYieldId => $composableBuilder(
      column: $table.harvestYieldId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$InventoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get acquisitionUnitCost => $composableBuilder(
      column: $table.acquisitionUnitCost, builder: (column) => column);

  GeneratedColumn<DateTime> get acquiredAt => $composableBuilder(
      column: $table.acquiredAt, builder: (column) => column);

  GeneratedColumn<double> get unitWeight => $composableBuilder(
      column: $table.unitWeight, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get cropFieldId => $composableBuilder(
      column: $table.cropFieldId, builder: (column) => column);

  GeneratedColumn<String> get harvestYieldId => $composableBuilder(
      column: $table.harvestYieldId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$InventoryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryItemsTable,
    InventoryItemRow,
    $$InventoryItemsTableFilterComposer,
    $$InventoryItemsTableOrderingComposer,
    $$InventoryItemsTableAnnotationComposer,
    $$InventoryItemsTableCreateCompanionBuilder,
    $$InventoryItemsTableUpdateCompanionBuilder,
    (
      InventoryItemRow,
      BaseReferences<_$AppDatabase, $InventoryItemsTable, InventoryItemRow>
    ),
    InventoryItemRow,
    PrefetchHooks Function()> {
  $$InventoryItemsTableTableManager(
      _$AppDatabase db, $InventoryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double?> acquisitionUnitCost = const Value.absent(),
            Value<DateTime?> acquiredAt = const Value.absent(),
            Value<double?> unitWeight = const Value.absent(),
            Value<String?> season = const Value.absent(),
            Value<String?> cropFieldId = const Value.absent(),
            Value<String?> harvestYieldId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryItemsCompanion(
            id: id,
            name: name,
            category: category,
            unit: unit,
            quantity: quantity,
            acquisitionUnitCost: acquisitionUnitCost,
            acquiredAt: acquiredAt,
            unitWeight: unitWeight,
            season: season,
            cropFieldId: cropFieldId,
            harvestYieldId: harvestYieldId,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String category,
            required String unit,
            required double quantity,
            Value<double?> acquisitionUnitCost = const Value.absent(),
            Value<DateTime?> acquiredAt = const Value.absent(),
            Value<double?> unitWeight = const Value.absent(),
            Value<String?> season = const Value.absent(),
            Value<String?> cropFieldId = const Value.absent(),
            Value<String?> harvestYieldId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryItemsCompanion.insert(
            id: id,
            name: name,
            category: category,
            unit: unit,
            quantity: quantity,
            acquisitionUnitCost: acquisitionUnitCost,
            acquiredAt: acquiredAt,
            unitWeight: unitWeight,
            season: season,
            cropFieldId: cropFieldId,
            harvestYieldId: harvestYieldId,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InventoryItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryItemsTable,
    InventoryItemRow,
    $$InventoryItemsTableFilterComposer,
    $$InventoryItemsTableOrderingComposer,
    $$InventoryItemsTableAnnotationComposer,
    $$InventoryItemsTableCreateCompanionBuilder,
    $$InventoryItemsTableUpdateCompanionBuilder,
    (
      InventoryItemRow,
      BaseReferences<_$AppDatabase, $InventoryItemsTable, InventoryItemRow>
    ),
    InventoryItemRow,
    PrefetchHooks Function()>;
typedef $$InventorySalesTableCreateCompanionBuilder = InventorySalesCompanion
    Function({
  required String id,
  required String inventoryItemId,
  required double quantitySold,
  required String unit,
  required double pricePerUnit,
  required double totalAmount,
  Value<String?> buyerName,
  required DateTime saleDate,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$InventorySalesTableUpdateCompanionBuilder = InventorySalesCompanion
    Function({
  Value<String> id,
  Value<String> inventoryItemId,
  Value<double> quantitySold,
  Value<String> unit,
  Value<double> pricePerUnit,
  Value<double> totalAmount,
  Value<String?> buyerName,
  Value<DateTime> saleDate,
  Value<String?> notes,
  Value<int> rowid,
});

class $$InventorySalesTableFilterComposer
    extends Composer<_$AppDatabase, $InventorySalesTable> {
  $$InventorySalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inventoryItemId => $composableBuilder(
      column: $table.inventoryItemId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantitySold => $composableBuilder(
      column: $table.quantitySold, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get buyerName => $composableBuilder(
      column: $table.buyerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$InventorySalesTableOrderingComposer
    extends Composer<_$AppDatabase, $InventorySalesTable> {
  $$InventorySalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inventoryItemId => $composableBuilder(
      column: $table.inventoryItemId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantitySold => $composableBuilder(
      column: $table.quantitySold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get buyerName => $composableBuilder(
      column: $table.buyerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$InventorySalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventorySalesTable> {
  $$InventorySalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get inventoryItemId => $composableBuilder(
      column: $table.inventoryItemId, builder: (column) => column);

  GeneratedColumn<double> get quantitySold => $composableBuilder(
      column: $table.quantitySold, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<String> get buyerName =>
      $composableBuilder(column: $table.buyerName, builder: (column) => column);

  GeneratedColumn<DateTime> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$InventorySalesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventorySalesTable,
    InventorySaleRow,
    $$InventorySalesTableFilterComposer,
    $$InventorySalesTableOrderingComposer,
    $$InventorySalesTableAnnotationComposer,
    $$InventorySalesTableCreateCompanionBuilder,
    $$InventorySalesTableUpdateCompanionBuilder,
    (
      InventorySaleRow,
      BaseReferences<_$AppDatabase, $InventorySalesTable, InventorySaleRow>
    ),
    InventorySaleRow,
    PrefetchHooks Function()> {
  $$InventorySalesTableTableManager(
      _$AppDatabase db, $InventorySalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventorySalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventorySalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventorySalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> inventoryItemId = const Value.absent(),
            Value<double> quantitySold = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> pricePerUnit = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<String?> buyerName = const Value.absent(),
            Value<DateTime> saleDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventorySalesCompanion(
            id: id,
            inventoryItemId: inventoryItemId,
            quantitySold: quantitySold,
            unit: unit,
            pricePerUnit: pricePerUnit,
            totalAmount: totalAmount,
            buyerName: buyerName,
            saleDate: saleDate,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String inventoryItemId,
            required double quantitySold,
            required String unit,
            required double pricePerUnit,
            required double totalAmount,
            Value<String?> buyerName = const Value.absent(),
            required DateTime saleDate,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventorySalesCompanion.insert(
            id: id,
            inventoryItemId: inventoryItemId,
            quantitySold: quantitySold,
            unit: unit,
            pricePerUnit: pricePerUnit,
            totalAmount: totalAmount,
            buyerName: buyerName,
            saleDate: saleDate,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InventorySalesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventorySalesTable,
    InventorySaleRow,
    $$InventorySalesTableFilterComposer,
    $$InventorySalesTableOrderingComposer,
    $$InventorySalesTableAnnotationComposer,
    $$InventorySalesTableCreateCompanionBuilder,
    $$InventorySalesTableUpdateCompanionBuilder,
    (
      InventorySaleRow,
      BaseReferences<_$AppDatabase, $InventorySalesTable, InventorySaleRow>
    ),
    InventorySaleRow,
    PrefetchHooks Function()>;
typedef $$FarmDocumentsTableCreateCompanionBuilder = FarmDocumentsCompanion
    Function({
  required String id,
  required String name,
  required String type,
  required String url,
  Value<int?> size,
  Value<String?> linkedTo,
  Value<String?> linkedType,
  Value<String?> notes,
  required DateTime uploadedAt,
  Value<int> rowid,
});
typedef $$FarmDocumentsTableUpdateCompanionBuilder = FarmDocumentsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<String> url,
  Value<int?> size,
  Value<String?> linkedTo,
  Value<String?> linkedType,
  Value<String?> notes,
  Value<DateTime> uploadedAt,
  Value<int> rowid,
});

class $$FarmDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $FarmDocumentsTable> {
  $$FarmDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedTo => $composableBuilder(
      column: $table.linkedTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedType => $composableBuilder(
      column: $table.linkedType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnFilters(column));
}

class $$FarmDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmDocumentsTable> {
  $$FarmDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedTo => $composableBuilder(
      column: $table.linkedTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedType => $composableBuilder(
      column: $table.linkedType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnOrderings(column));
}

class $$FarmDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmDocumentsTable> {
  $$FarmDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get linkedTo =>
      $composableBuilder(column: $table.linkedTo, builder: (column) => column);

  GeneratedColumn<String> get linkedType => $composableBuilder(
      column: $table.linkedType, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => column);
}

class $$FarmDocumentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FarmDocumentsTable,
    FarmDocumentRow,
    $$FarmDocumentsTableFilterComposer,
    $$FarmDocumentsTableOrderingComposer,
    $$FarmDocumentsTableAnnotationComposer,
    $$FarmDocumentsTableCreateCompanionBuilder,
    $$FarmDocumentsTableUpdateCompanionBuilder,
    (
      FarmDocumentRow,
      BaseReferences<_$AppDatabase, $FarmDocumentsTable, FarmDocumentRow>
    ),
    FarmDocumentRow,
    PrefetchHooks Function()> {
  $$FarmDocumentsTableTableManager(_$AppDatabase db, $FarmDocumentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<int?> size = const Value.absent(),
            Value<String?> linkedTo = const Value.absent(),
            Value<String?> linkedType = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> uploadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmDocumentsCompanion(
            id: id,
            name: name,
            type: type,
            url: url,
            size: size,
            linkedTo: linkedTo,
            linkedType: linkedType,
            notes: notes,
            uploadedAt: uploadedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String type,
            required String url,
            Value<int?> size = const Value.absent(),
            Value<String?> linkedTo = const Value.absent(),
            Value<String?> linkedType = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime uploadedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmDocumentsCompanion.insert(
            id: id,
            name: name,
            type: type,
            url: url,
            size: size,
            linkedTo: linkedTo,
            linkedType: linkedType,
            notes: notes,
            uploadedAt: uploadedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FarmDocumentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FarmDocumentsTable,
    FarmDocumentRow,
    $$FarmDocumentsTableFilterComposer,
    $$FarmDocumentsTableOrderingComposer,
    $$FarmDocumentsTableAnnotationComposer,
    $$FarmDocumentsTableCreateCompanionBuilder,
    $$FarmDocumentsTableUpdateCompanionBuilder,
    (
      FarmDocumentRow,
      BaseReferences<_$AppDatabase, $FarmDocumentsTable, FarmDocumentRow>
    ),
    FarmDocumentRow,
    PrefetchHooks Function()>;
typedef $$NotificationsTableCreateCompanionBuilder = NotificationsCompanion
    Function({
  required String id,
  required String type,
  required String title,
  required String message,
  Value<bool> isRead,
  Value<String?> link,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$NotificationsTableUpdateCompanionBuilder = NotificationsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String> title,
  Value<String> message,
  Value<bool> isRead,
  Value<String?> link,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get link => $composableBuilder(
      column: $table.link, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get link => $composableBuilder(
      column: $table.link, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationsTable,
    NotificationRow,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (
      NotificationRow,
      BaseReferences<_$AppDatabase, $NotificationsTable, NotificationRow>
    ),
    NotificationRow,
    PrefetchHooks Function()> {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<String?> link = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationsCompanion(
            id: id,
            type: type,
            title: title,
            message: message,
            isRead: isRead,
            link: link,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String title,
            required String message,
            Value<bool> isRead = const Value.absent(),
            Value<String?> link = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationsCompanion.insert(
            id: id,
            type: type,
            title: title,
            message: message,
            isRead: isRead,
            link: link,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotificationsTable,
    NotificationRow,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (
      NotificationRow,
      BaseReferences<_$AppDatabase, $NotificationsTable, NotificationRow>
    ),
    NotificationRow,
    PrefetchHooks Function()>;
typedef $$LivestockTypesTableCreateCompanionBuilder = LivestockTypesCompanion
    Function({
  required String id,
  required String name,
  required String category,
  required String icon,
  Value<int> rowid,
});
typedef $$LivestockTypesTableUpdateCompanionBuilder = LivestockTypesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String> icon,
  Value<int> rowid,
});

class $$LivestockTypesTableFilterComposer
    extends Composer<_$AppDatabase, $LivestockTypesTable> {
  $$LivestockTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));
}

class $$LivestockTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $LivestockTypesTable> {
  $$LivestockTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));
}

class $$LivestockTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LivestockTypesTable> {
  $$LivestockTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$LivestockTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LivestockTypesTable,
    LivestockTypeRow,
    $$LivestockTypesTableFilterComposer,
    $$LivestockTypesTableOrderingComposer,
    $$LivestockTypesTableAnnotationComposer,
    $$LivestockTypesTableCreateCompanionBuilder,
    $$LivestockTypesTableUpdateCompanionBuilder,
    (
      LivestockTypeRow,
      BaseReferences<_$AppDatabase, $LivestockTypesTable, LivestockTypeRow>
    ),
    LivestockTypeRow,
    PrefetchHooks Function()> {
  $$LivestockTypesTableTableManager(
      _$AppDatabase db, $LivestockTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LivestockTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LivestockTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LivestockTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LivestockTypesCompanion(
            id: id,
            name: name,
            category: category,
            icon: icon,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String category,
            required String icon,
            Value<int> rowid = const Value.absent(),
          }) =>
              LivestockTypesCompanion.insert(
            id: id,
            name: name,
            category: category,
            icon: icon,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LivestockTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LivestockTypesTable,
    LivestockTypeRow,
    $$LivestockTypesTableFilterComposer,
    $$LivestockTypesTableOrderingComposer,
    $$LivestockTypesTableAnnotationComposer,
    $$LivestockTypesTableCreateCompanionBuilder,
    $$LivestockTypesTableUpdateCompanionBuilder,
    (
      LivestockTypeRow,
      BaseReferences<_$AppDatabase, $LivestockTypesTable, LivestockTypeRow>
    ),
    LivestockTypeRow,
    PrefetchHooks Function()>;
typedef $$AnimalsTableCreateCompanionBuilder = AnimalsCompanion Function({
  required String id,
  required String livestockTypeId,
  Value<String?> tag,
  Value<String?> name,
  Value<String?> animalGroup,
  required String sex,
  Value<DateTime?> birthDate,
  required DateTime acquisitionDate,
  required String acquisitionType,
  Value<double?> acquisitionCost,
  Value<String> status,
  Value<String?> breed,
  Value<String?> colour,
  Value<double?> weight,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$AnimalsTableUpdateCompanionBuilder = AnimalsCompanion Function({
  Value<String> id,
  Value<String> livestockTypeId,
  Value<String?> tag,
  Value<String?> name,
  Value<String?> animalGroup,
  Value<String> sex,
  Value<DateTime?> birthDate,
  Value<DateTime> acquisitionDate,
  Value<String> acquisitionType,
  Value<double?> acquisitionCost,
  Value<String> status,
  Value<String?> breed,
  Value<String?> colour,
  Value<double?> weight,
  Value<String?> notes,
  Value<int> rowid,
});

class $$AnimalsTableFilterComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get livestockTypeId => $composableBuilder(
      column: $table.livestockTypeId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalGroup => $composableBuilder(
      column: $table.animalGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get acquisitionDate => $composableBuilder(
      column: $table.acquisitionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get acquisitionType => $composableBuilder(
      column: $table.acquisitionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get acquisitionCost => $composableBuilder(
      column: $table.acquisitionCost,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colour => $composableBuilder(
      column: $table.colour, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$AnimalsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get livestockTypeId => $composableBuilder(
      column: $table.livestockTypeId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalGroup => $composableBuilder(
      column: $table.animalGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get acquisitionDate => $composableBuilder(
      column: $table.acquisitionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get acquisitionType => $composableBuilder(
      column: $table.acquisitionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get acquisitionCost => $composableBuilder(
      column: $table.acquisitionCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colour => $composableBuilder(
      column: $table.colour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$AnimalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get livestockTypeId => $composableBuilder(
      column: $table.livestockTypeId, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get animalGroup => $composableBuilder(
      column: $table.animalGroup, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<DateTime> get acquisitionDate => $composableBuilder(
      column: $table.acquisitionDate, builder: (column) => column);

  GeneratedColumn<String> get acquisitionType => $composableBuilder(
      column: $table.acquisitionType, builder: (column) => column);

  GeneratedColumn<double> get acquisitionCost => $composableBuilder(
      column: $table.acquisitionCost, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get colour =>
      $composableBuilder(column: $table.colour, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$AnimalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnimalsTable,
    AnimalRow,
    $$AnimalsTableFilterComposer,
    $$AnimalsTableOrderingComposer,
    $$AnimalsTableAnnotationComposer,
    $$AnimalsTableCreateCompanionBuilder,
    $$AnimalsTableUpdateCompanionBuilder,
    (AnimalRow, BaseReferences<_$AppDatabase, $AnimalsTable, AnimalRow>),
    AnimalRow,
    PrefetchHooks Function()> {
  $$AnimalsTableTableManager(_$AppDatabase db, $AnimalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> livestockTypeId = const Value.absent(),
            Value<String?> tag = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> animalGroup = const Value.absent(),
            Value<String> sex = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<DateTime> acquisitionDate = const Value.absent(),
            Value<String> acquisitionType = const Value.absent(),
            Value<double?> acquisitionCost = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> breed = const Value.absent(),
            Value<String?> colour = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalsCompanion(
            id: id,
            livestockTypeId: livestockTypeId,
            tag: tag,
            name: name,
            animalGroup: animalGroup,
            sex: sex,
            birthDate: birthDate,
            acquisitionDate: acquisitionDate,
            acquisitionType: acquisitionType,
            acquisitionCost: acquisitionCost,
            status: status,
            breed: breed,
            colour: colour,
            weight: weight,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String livestockTypeId,
            Value<String?> tag = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> animalGroup = const Value.absent(),
            required String sex,
            Value<DateTime?> birthDate = const Value.absent(),
            required DateTime acquisitionDate,
            required String acquisitionType,
            Value<double?> acquisitionCost = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> breed = const Value.absent(),
            Value<String?> colour = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalsCompanion.insert(
            id: id,
            livestockTypeId: livestockTypeId,
            tag: tag,
            name: name,
            animalGroup: animalGroup,
            sex: sex,
            birthDate: birthDate,
            acquisitionDate: acquisitionDate,
            acquisitionType: acquisitionType,
            acquisitionCost: acquisitionCost,
            status: status,
            breed: breed,
            colour: colour,
            weight: weight,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnimalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnimalsTable,
    AnimalRow,
    $$AnimalsTableFilterComposer,
    $$AnimalsTableOrderingComposer,
    $$AnimalsTableAnnotationComposer,
    $$AnimalsTableCreateCompanionBuilder,
    $$AnimalsTableUpdateCompanionBuilder,
    (AnimalRow, BaseReferences<_$AppDatabase, $AnimalsTable, AnimalRow>),
    AnimalRow,
    PrefetchHooks Function()>;
typedef $$AnimalHealthRecordsTableCreateCompanionBuilder
    = AnimalHealthRecordsCompanion Function({
  required String id,
  required String animalId,
  required String type,
  required String description,
  Value<String?> veterinarian,
  required double cost,
  required DateTime date,
  Value<DateTime?> nextDueDate,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$AnimalHealthRecordsTableUpdateCompanionBuilder
    = AnimalHealthRecordsCompanion Function({
  Value<String> id,
  Value<String> animalId,
  Value<String> type,
  Value<String> description,
  Value<String?> veterinarian,
  Value<double> cost,
  Value<DateTime> date,
  Value<DateTime?> nextDueDate,
  Value<String?> notes,
  Value<int> rowid,
});

class $$AnimalHealthRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AnimalHealthRecordsTable> {
  $$AnimalHealthRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get veterinarian => $composableBuilder(
      column: $table.veterinarian, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cost => $composableBuilder(
      column: $table.cost, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$AnimalHealthRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimalHealthRecordsTable> {
  $$AnimalHealthRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get veterinarian => $composableBuilder(
      column: $table.veterinarian,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cost => $composableBuilder(
      column: $table.cost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$AnimalHealthRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimalHealthRecordsTable> {
  $$AnimalHealthRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get veterinarian => $composableBuilder(
      column: $table.veterinarian, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$AnimalHealthRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnimalHealthRecordsTable,
    AnimalHealthRecord,
    $$AnimalHealthRecordsTableFilterComposer,
    $$AnimalHealthRecordsTableOrderingComposer,
    $$AnimalHealthRecordsTableAnnotationComposer,
    $$AnimalHealthRecordsTableCreateCompanionBuilder,
    $$AnimalHealthRecordsTableUpdateCompanionBuilder,
    (
      AnimalHealthRecord,
      BaseReferences<_$AppDatabase, $AnimalHealthRecordsTable,
          AnimalHealthRecord>
    ),
    AnimalHealthRecord,
    PrefetchHooks Function()> {
  $$AnimalHealthRecordsTableTableManager(
      _$AppDatabase db, $AnimalHealthRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalHealthRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalHealthRecordsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalHealthRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> veterinarian = const Value.absent(),
            Value<double> cost = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime?> nextDueDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalHealthRecordsCompanion(
            id: id,
            animalId: animalId,
            type: type,
            description: description,
            veterinarian: veterinarian,
            cost: cost,
            date: date,
            nextDueDate: nextDueDate,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String animalId,
            required String type,
            required String description,
            Value<String?> veterinarian = const Value.absent(),
            required double cost,
            required DateTime date,
            Value<DateTime?> nextDueDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalHealthRecordsCompanion.insert(
            id: id,
            animalId: animalId,
            type: type,
            description: description,
            veterinarian: veterinarian,
            cost: cost,
            date: date,
            nextDueDate: nextDueDate,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnimalHealthRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnimalHealthRecordsTable,
    AnimalHealthRecord,
    $$AnimalHealthRecordsTableFilterComposer,
    $$AnimalHealthRecordsTableOrderingComposer,
    $$AnimalHealthRecordsTableAnnotationComposer,
    $$AnimalHealthRecordsTableCreateCompanionBuilder,
    $$AnimalHealthRecordsTableUpdateCompanionBuilder,
    (
      AnimalHealthRecord,
      BaseReferences<_$AppDatabase, $AnimalHealthRecordsTable,
          AnimalHealthRecord>
    ),
    AnimalHealthRecord,
    PrefetchHooks Function()>;
typedef $$AnimalProductionRecordsTableCreateCompanionBuilder
    = AnimalProductionRecordsCompanion Function({
  required String id,
  required String animalId,
  required String type,
  required double quantity,
  required String unit,
  required DateTime date,
  Value<double?> pricePerUnit,
  Value<double?> totalValue,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$AnimalProductionRecordsTableUpdateCompanionBuilder
    = AnimalProductionRecordsCompanion Function({
  Value<String> id,
  Value<String> animalId,
  Value<String> type,
  Value<double> quantity,
  Value<String> unit,
  Value<DateTime> date,
  Value<double?> pricePerUnit,
  Value<double?> totalValue,
  Value<String?> notes,
  Value<int> rowid,
});

class $$AnimalProductionRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AnimalProductionRecordsTable> {
  $$AnimalProductionRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalValue => $composableBuilder(
      column: $table.totalValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$AnimalProductionRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimalProductionRecordsTable> {
  $$AnimalProductionRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalValue => $composableBuilder(
      column: $table.totalValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$AnimalProductionRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimalProductionRecordsTable> {
  $$AnimalProductionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit, builder: (column) => column);

  GeneratedColumn<double> get totalValue => $composableBuilder(
      column: $table.totalValue, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$AnimalProductionRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnimalProductionRecordsTable,
    AnimalProductionRecord,
    $$AnimalProductionRecordsTableFilterComposer,
    $$AnimalProductionRecordsTableOrderingComposer,
    $$AnimalProductionRecordsTableAnnotationComposer,
    $$AnimalProductionRecordsTableCreateCompanionBuilder,
    $$AnimalProductionRecordsTableUpdateCompanionBuilder,
    (
      AnimalProductionRecord,
      BaseReferences<_$AppDatabase, $AnimalProductionRecordsTable,
          AnimalProductionRecord>
    ),
    AnimalProductionRecord,
    PrefetchHooks Function()> {
  $$AnimalProductionRecordsTableTableManager(
      _$AppDatabase db, $AnimalProductionRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalProductionRecordsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalProductionRecordsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalProductionRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double?> pricePerUnit = const Value.absent(),
            Value<double?> totalValue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalProductionRecordsCompanion(
            id: id,
            animalId: animalId,
            type: type,
            quantity: quantity,
            unit: unit,
            date: date,
            pricePerUnit: pricePerUnit,
            totalValue: totalValue,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String animalId,
            required String type,
            required double quantity,
            required String unit,
            required DateTime date,
            Value<double?> pricePerUnit = const Value.absent(),
            Value<double?> totalValue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalProductionRecordsCompanion.insert(
            id: id,
            animalId: animalId,
            type: type,
            quantity: quantity,
            unit: unit,
            date: date,
            pricePerUnit: pricePerUnit,
            totalValue: totalValue,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnimalProductionRecordsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AnimalProductionRecordsTable,
        AnimalProductionRecord,
        $$AnimalProductionRecordsTableFilterComposer,
        $$AnimalProductionRecordsTableOrderingComposer,
        $$AnimalProductionRecordsTableAnnotationComposer,
        $$AnimalProductionRecordsTableCreateCompanionBuilder,
        $$AnimalProductionRecordsTableUpdateCompanionBuilder,
        (
          AnimalProductionRecord,
          BaseReferences<_$AppDatabase, $AnimalProductionRecordsTable,
              AnimalProductionRecord>
        ),
        AnimalProductionRecord,
        PrefetchHooks Function()>;
typedef $$AnimalWeightRecordsTableCreateCompanionBuilder
    = AnimalWeightRecordsCompanion Function({
  required String id,
  required String animalId,
  required double weight,
  required String unit,
  required DateTime date,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$AnimalWeightRecordsTableUpdateCompanionBuilder
    = AnimalWeightRecordsCompanion Function({
  Value<String> id,
  Value<String> animalId,
  Value<double> weight,
  Value<String> unit,
  Value<DateTime> date,
  Value<String?> notes,
  Value<int> rowid,
});

class $$AnimalWeightRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AnimalWeightRecordsTable> {
  $$AnimalWeightRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$AnimalWeightRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimalWeightRecordsTable> {
  $$AnimalWeightRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$AnimalWeightRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimalWeightRecordsTable> {
  $$AnimalWeightRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$AnimalWeightRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnimalWeightRecordsTable,
    AnimalWeightRecord,
    $$AnimalWeightRecordsTableFilterComposer,
    $$AnimalWeightRecordsTableOrderingComposer,
    $$AnimalWeightRecordsTableAnnotationComposer,
    $$AnimalWeightRecordsTableCreateCompanionBuilder,
    $$AnimalWeightRecordsTableUpdateCompanionBuilder,
    (
      AnimalWeightRecord,
      BaseReferences<_$AppDatabase, $AnimalWeightRecordsTable,
          AnimalWeightRecord>
    ),
    AnimalWeightRecord,
    PrefetchHooks Function()> {
  $$AnimalWeightRecordsTableTableManager(
      _$AppDatabase db, $AnimalWeightRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalWeightRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalWeightRecordsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalWeightRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalWeightRecordsCompanion(
            id: id,
            animalId: animalId,
            weight: weight,
            unit: unit,
            date: date,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String animalId,
            required double weight,
            required String unit,
            required DateTime date,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalWeightRecordsCompanion.insert(
            id: id,
            animalId: animalId,
            weight: weight,
            unit: unit,
            date: date,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnimalWeightRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnimalWeightRecordsTable,
    AnimalWeightRecord,
    $$AnimalWeightRecordsTableFilterComposer,
    $$AnimalWeightRecordsTableOrderingComposer,
    $$AnimalWeightRecordsTableAnnotationComposer,
    $$AnimalWeightRecordsTableCreateCompanionBuilder,
    $$AnimalWeightRecordsTableUpdateCompanionBuilder,
    (
      AnimalWeightRecord,
      BaseReferences<_$AppDatabase, $AnimalWeightRecordsTable,
          AnimalWeightRecord>
    ),
    AnimalWeightRecord,
    PrefetchHooks Function()>;
typedef $$AnimalExpenseRecordsTableCreateCompanionBuilder
    = AnimalExpenseRecordsCompanion Function({
  required String id,
  Value<String?> animalId,
  required String category,
  required String description,
  required double amount,
  required DateTime date,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$AnimalExpenseRecordsTableUpdateCompanionBuilder
    = AnimalExpenseRecordsCompanion Function({
  Value<String> id,
  Value<String?> animalId,
  Value<String> category,
  Value<String> description,
  Value<double> amount,
  Value<DateTime> date,
  Value<String?> notes,
  Value<int> rowid,
});

class $$AnimalExpenseRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AnimalExpenseRecordsTable> {
  $$AnimalExpenseRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$AnimalExpenseRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimalExpenseRecordsTable> {
  $$AnimalExpenseRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$AnimalExpenseRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimalExpenseRecordsTable> {
  $$AnimalExpenseRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$AnimalExpenseRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnimalExpenseRecordsTable,
    AnimalExpenseRecord,
    $$AnimalExpenseRecordsTableFilterComposer,
    $$AnimalExpenseRecordsTableOrderingComposer,
    $$AnimalExpenseRecordsTableAnnotationComposer,
    $$AnimalExpenseRecordsTableCreateCompanionBuilder,
    $$AnimalExpenseRecordsTableUpdateCompanionBuilder,
    (
      AnimalExpenseRecord,
      BaseReferences<_$AppDatabase, $AnimalExpenseRecordsTable,
          AnimalExpenseRecord>
    ),
    AnimalExpenseRecord,
    PrefetchHooks Function()> {
  $$AnimalExpenseRecordsTableTableManager(
      _$AppDatabase db, $AnimalExpenseRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalExpenseRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalExpenseRecordsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalExpenseRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> animalId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalExpenseRecordsCompanion(
            id: id,
            animalId: animalId,
            category: category,
            description: description,
            amount: amount,
            date: date,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> animalId = const Value.absent(),
            required String category,
            required String description,
            required double amount,
            required DateTime date,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalExpenseRecordsCompanion.insert(
            id: id,
            animalId: animalId,
            category: category,
            description: description,
            amount: amount,
            date: date,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnimalExpenseRecordsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AnimalExpenseRecordsTable,
        AnimalExpenseRecord,
        $$AnimalExpenseRecordsTableFilterComposer,
        $$AnimalExpenseRecordsTableOrderingComposer,
        $$AnimalExpenseRecordsTableAnnotationComposer,
        $$AnimalExpenseRecordsTableCreateCompanionBuilder,
        $$AnimalExpenseRecordsTableUpdateCompanionBuilder,
        (
          AnimalExpenseRecord,
          BaseReferences<_$AppDatabase, $AnimalExpenseRecordsTable,
              AnimalExpenseRecord>
        ),
        AnimalExpenseRecord,
        PrefetchHooks Function()>;
typedef $$AnimalSaleRecordsTableCreateCompanionBuilder
    = AnimalSaleRecordsCompanion Function({
  required String id,
  required String animalId,
  required DateTime saleDate,
  Value<int> quantity,
  Value<double?> weightAtSale,
  Value<double?> pricePerKg,
  required double totalAmount,
  Value<String?> buyer,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$AnimalSaleRecordsTableUpdateCompanionBuilder
    = AnimalSaleRecordsCompanion Function({
  Value<String> id,
  Value<String> animalId,
  Value<DateTime> saleDate,
  Value<int> quantity,
  Value<double?> weightAtSale,
  Value<double?> pricePerKg,
  Value<double> totalAmount,
  Value<String?> buyer,
  Value<String?> notes,
  Value<int> rowid,
});

class $$AnimalSaleRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AnimalSaleRecordsTable> {
  $$AnimalSaleRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightAtSale => $composableBuilder(
      column: $table.weightAtSale, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pricePerKg => $composableBuilder(
      column: $table.pricePerKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get buyer => $composableBuilder(
      column: $table.buyer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$AnimalSaleRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimalSaleRecordsTable> {
  $$AnimalSaleRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightAtSale => $composableBuilder(
      column: $table.weightAtSale,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pricePerKg => $composableBuilder(
      column: $table.pricePerKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get buyer => $composableBuilder(
      column: $table.buyer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$AnimalSaleRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimalSaleRecordsTable> {
  $$AnimalSaleRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<DateTime> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get weightAtSale => $composableBuilder(
      column: $table.weightAtSale, builder: (column) => column);

  GeneratedColumn<double> get pricePerKg => $composableBuilder(
      column: $table.pricePerKg, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<String> get buyer =>
      $composableBuilder(column: $table.buyer, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$AnimalSaleRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnimalSaleRecordsTable,
    AnimalSaleRecord,
    $$AnimalSaleRecordsTableFilterComposer,
    $$AnimalSaleRecordsTableOrderingComposer,
    $$AnimalSaleRecordsTableAnnotationComposer,
    $$AnimalSaleRecordsTableCreateCompanionBuilder,
    $$AnimalSaleRecordsTableUpdateCompanionBuilder,
    (
      AnimalSaleRecord,
      BaseReferences<_$AppDatabase, $AnimalSaleRecordsTable, AnimalSaleRecord>
    ),
    AnimalSaleRecord,
    PrefetchHooks Function()> {
  $$AnimalSaleRecordsTableTableManager(
      _$AppDatabase db, $AnimalSaleRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalSaleRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalSaleRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalSaleRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<DateTime> saleDate = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double?> weightAtSale = const Value.absent(),
            Value<double?> pricePerKg = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<String?> buyer = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalSaleRecordsCompanion(
            id: id,
            animalId: animalId,
            saleDate: saleDate,
            quantity: quantity,
            weightAtSale: weightAtSale,
            pricePerKg: pricePerKg,
            totalAmount: totalAmount,
            buyer: buyer,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String animalId,
            required DateTime saleDate,
            Value<int> quantity = const Value.absent(),
            Value<double?> weightAtSale = const Value.absent(),
            Value<double?> pricePerKg = const Value.absent(),
            required double totalAmount,
            Value<String?> buyer = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalSaleRecordsCompanion.insert(
            id: id,
            animalId: animalId,
            saleDate: saleDate,
            quantity: quantity,
            weightAtSale: weightAtSale,
            pricePerKg: pricePerKg,
            totalAmount: totalAmount,
            buyer: buyer,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnimalSaleRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnimalSaleRecordsTable,
    AnimalSaleRecord,
    $$AnimalSaleRecordsTableFilterComposer,
    $$AnimalSaleRecordsTableOrderingComposer,
    $$AnimalSaleRecordsTableAnnotationComposer,
    $$AnimalSaleRecordsTableCreateCompanionBuilder,
    $$AnimalSaleRecordsTableUpdateCompanionBuilder,
    (
      AnimalSaleRecord,
      BaseReferences<_$AppDatabase, $AnimalSaleRecordsTable, AnimalSaleRecord>
    ),
    AnimalSaleRecord,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FarmProfileTableTableManager get farmProfile =>
      $$FarmProfileTableTableManager(_db, _db.farmProfile);
  $$FieldsTableTableManager get fields =>
      $$FieldsTableTableManager(_db, _db.fields);
  $$FieldBoundariesTableTableManager get fieldBoundaries =>
      $$FieldBoundariesTableTableManager(_db, _db.fieldBoundaries);
  $$FieldZonesTableTableManager get fieldZones =>
      $$FieldZonesTableTableManager(_db, _db.fieldZones);
  $$FarmMarkersTableTableManager get farmMarkers =>
      $$FarmMarkersTableTableManager(_db, _db.farmMarkers);
  $$CropTypesTableTableManager get cropTypes =>
      $$CropTypesTableTableManager(_db, _db.cropTypes);
  $$CropFieldsTableTableManager get cropFields =>
      $$CropFieldsTableTableManager(_db, _db.cropFields);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$ActivityInputsTableTableManager get activityInputs =>
      $$ActivityInputsTableTableManager(_db, _db.activityInputs);
  $$ActivityLabourRecordsTableTableManager get activityLabourRecords =>
      $$ActivityLabourRecordsTableTableManager(_db, _db.activityLabourRecords);
  $$ActivityOtherCostsTableTableManager get activityOtherCosts =>
      $$ActivityOtherCostsTableTableManager(_db, _db.activityOtherCosts);
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db, _db.employees);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$OverheadExpensesTableTableManager get overheadExpenses =>
      $$OverheadExpensesTableTableManager(_db, _db.overheadExpenses);
  $$HarvestYieldsTableTableManager get harvestYields =>
      $$HarvestYieldsTableTableManager(_db, _db.harvestYields);
  $$InventoryItemsTableTableManager get inventoryItems =>
      $$InventoryItemsTableTableManager(_db, _db.inventoryItems);
  $$InventorySalesTableTableManager get inventorySales =>
      $$InventorySalesTableTableManager(_db, _db.inventorySales);
  $$FarmDocumentsTableTableManager get farmDocuments =>
      $$FarmDocumentsTableTableManager(_db, _db.farmDocuments);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$LivestockTypesTableTableManager get livestockTypes =>
      $$LivestockTypesTableTableManager(_db, _db.livestockTypes);
  $$AnimalsTableTableManager get animals =>
      $$AnimalsTableTableManager(_db, _db.animals);
  $$AnimalHealthRecordsTableTableManager get animalHealthRecords =>
      $$AnimalHealthRecordsTableTableManager(_db, _db.animalHealthRecords);
  $$AnimalProductionRecordsTableTableManager get animalProductionRecords =>
      $$AnimalProductionRecordsTableTableManager(
          _db, _db.animalProductionRecords);
  $$AnimalWeightRecordsTableTableManager get animalWeightRecords =>
      $$AnimalWeightRecordsTableTableManager(_db, _db.animalWeightRecords);
  $$AnimalExpenseRecordsTableTableManager get animalExpenseRecords =>
      $$AnimalExpenseRecordsTableTableManager(_db, _db.animalExpenseRecords);
  $$AnimalSaleRecordsTableTableManager get animalSaleRecords =>
      $$AnimalSaleRecordsTableTableManager(_db, _db.animalSaleRecords);
}
