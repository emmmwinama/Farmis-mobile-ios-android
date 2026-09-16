import 'package:dio/dio.dart';

/// Anything [fakeApiDio] can route a request to: something with a fixed
/// [basePath] prefix and a [handle] that answers one request.
abstract class FakeApiResource {
  String get basePath;
  Response<dynamic> handle(RequestOptions options);
}

Response<dynamic> _okResponse(Map<String, dynamic> data, {int statusCode = 200}) =>
    Response(requestOptions: RequestOptions(path: ''), data: data, statusCode: statusCode);

Response<dynamic> _notFoundResponse() => throw DioException(
      requestOptions: RequestOptions(path: ''),
      response: Response(
        requestOptions: RequestOptions(path: ''),
        data: {'error': 'Not found.'},
        statusCode: 404,
      ),
      type: DioExceptionType.badResponse,
    );

/// A minimal in-memory stand-in for one `/api/mobile/<resource>` REST
/// collection, used to unit-test repositories that talk to Ulimi's mobile
/// API without touching the network. Supports exactly the shape every
/// ported repository uses: `{"data": ...}` on success, a plain list of rows
/// for the index, and 404 for an unknown id on update/delete — matching
/// docs/MOBILE-API.md's response conventions.
class FakeRestResource implements FakeApiResource {
  FakeRestResource(this.basePath, {this.idPrefix = 'srv'});

  @override
  final String basePath; // e.g. '/api/mobile/fields'
  final String idPrefix;
  final rows = <String, Map<String, dynamic>>{};
  int _seq = 0;

  /// Builds the row this resource stores from a create/update request body.
  /// Override per-resource quirks (server-forced fields, computed columns)
  /// by passing [onCreate]/[onUpdate].
  Map<String, dynamic> Function(Map<String, dynamic> body, String id) onCreate =
      (body, id) => {...body, 'id': id};
  Map<String, dynamic> Function(Map<String, dynamic> existing, Map<String, dynamic> body) onUpdate =
      (existing, body) => {...existing, ...body};

  /// Extra `POST $basePath/{id}/{action}` endpoints beyond the standard
  /// CRUD ones — e.g. archive/restore/sell. Keyed by action name; each
  /// handler gets the current row and returns the updated one.
  final actions = <String, Map<String, dynamic> Function(Map<String, dynamic> existing)>{};

  @override
  Response<dynamic> handle(RequestOptions options) {
    final path = options.path;
    final method = options.method;

    if (method == 'GET' && path == basePath) {
      return _ok({'data': rows.values.toList()});
    }
    if (method == 'POST' && path == basePath) {
      final id = '$idPrefix-${_seq++}';
      final body = Map<String, dynamic>.from(options.data as Map? ?? {});
      final row = onCreate(body, id);
      rows[id] = row;
      return _ok({'data': row}, statusCode: 201);
    }
    if (method == 'GET' && path.startsWith('$basePath/')) {
      final id = path.substring(basePath.length + 1);
      final row = rows[id];
      if (row == null) return _notFound();
      return _ok({'data': row});
    }
    if (method == 'PUT' && path.startsWith('$basePath/')) {
      final id = path.substring(basePath.length + 1);
      final existing = rows[id];
      if (existing == null) return _notFound();
      final body = Map<String, dynamic>.from(options.data as Map? ?? {});
      final row = onUpdate(existing, body);
      rows[id] = row;
      return _ok({'data': row});
    }
    if (method == 'POST' && path.startsWith('$basePath/') && path.endsWith('/delete')) {
      final id = path.substring(basePath.length + 1, path.length - '/delete'.length);
      rows.remove(id);
      return _ok({'data': true});
    }
    for (final entry in actions.entries) {
      final suffix = '/${entry.key}';
      if (method == 'POST' && path.startsWith('$basePath/') && path.endsWith(suffix)) {
        final id = path.substring(basePath.length + 1, path.length - suffix.length);
        final existing = rows[id];
        if (existing == null) return _notFound();
        final row = entry.value(existing);
        rows[id] = row;
        return _ok({'data': row});
      }
    }

    throw StateError('FakeRestResource($basePath): unhandled request $method $path');
  }

  Response<dynamic> _ok(Map<String, dynamic> data, {int statusCode = 200}) => Response(
        requestOptions: RequestOptions(path: ''),
        data: data,
        statusCode: statusCode,
      );

  Response<dynamic> _notFound() => throw DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          data: {'error': 'Not found.'},
          statusCode: 404,
        ),
        type: DioExceptionType.badResponse,
      );
}

/// A `/api/mobile/crops` fake that mimics the server's real quirks:
/// `crop_type` is a free-text name resolved-or-created into an id (never a
/// foreign key the client looks up first), and archive/restore are actions
/// distinct from a status value.
FakeRestResource fakeCropsResource() {
  final typeIdByName = <String, String>{};
  var typeSeq = 0;
  String resolveType(String name) {
    final key = name.trim().toLowerCase();
    return typeIdByName.putIfAbsent(key, () => 'ct-${typeSeq++}');
  }

  final resource = FakeRestResource('/api/mobile/crops');
  resource.onCreate = (body, id) => {
        ...body,
        'id': id,
        'crop_type_id': resolveType(body['crop_type'] as String),
        'crop_name': body['crop_type'],
        'is_archived': 0,
      };
  resource.onUpdate = (existing, body) {
    final merged = {...existing, ...body};
    if (body['crop_type'] != null) {
      merged['crop_type_id'] = resolveType(body['crop_type'] as String);
      merged['crop_name'] = body['crop_type'];
    }
    return merged;
  };
  resource.actions['archive'] = (existing) => {...existing, 'is_archived': 1};
  resource.actions['restore'] = (existing) => {...existing, 'is_archived': 0};
  return resource;
}

/// A `/api/mobile/livestock/animals` fake covering the nested routes that
/// don't fit [FakeRestResource]'s flat-collection shape: per-kind event
/// logs (`/animals/{id}/events/{kind}`, `.../{eventId}/delete`) and the
/// `/animals/{id}/sell` action.
class FakeLivestockAnimalsResource implements FakeApiResource {
  FakeLivestockAnimalsResource(this.basePath, {this.idPrefix = 'an'});

  @override
  final String basePath;
  final String idPrefix;
  final rows = <String, Map<String, dynamic>>{};
  final events = <String, List<Map<String, dynamic>>>{};
  int _seq = 0;
  int _eventSeq = 0;

  @override
  Response<dynamic> handle(RequestOptions options) {
    final path = options.path;
    final method = options.method;

    if (method == 'GET' && path == basePath) {
      return _okResponse({'data': rows.values.toList()});
    }
    if (method == 'POST' && path == basePath) {
      final id = '$idPrefix-${_seq++}';
      final body = Map<String, dynamic>.from(options.data as Map? ?? {});
      final row = {...body, 'id': id};
      rows[id] = row;
      return _okResponse({'data': row}, statusCode: 201);
    }

    if (method == 'POST' && path.endsWith('/sell')) {
      final id = path.substring(basePath.length + 1, path.length - '/sell'.length);
      final existing = rows[id];
      if (existing == null) return _notFoundResponse();
      final updated = {...existing, 'status': 'Sold'};
      rows[id] = updated;
      return _okResponse({'data': updated});
    }

    final deleteEventMatch =
        RegExp('^${RegExp.escape(basePath)}/([^/]+)/events/([^/]+)/([^/]+)/delete\$')
            .firstMatch(path);
    if (method == 'POST' && deleteEventMatch != null) {
      final animalId = deleteEventMatch.group(1)!;
      final kind = deleteEventMatch.group(2)!;
      final eventId = deleteEventMatch.group(3)!;
      events['$animalId/$kind']?.removeWhere((e) => e['id'] == eventId);
      return _okResponse({'data': true});
    }

    final eventsMatch =
        RegExp('^${RegExp.escape(basePath)}/([^/]+)/events/([^/]+)\$').firstMatch(path);
    if (eventsMatch != null) {
      final animalId = eventsMatch.group(1)!;
      final kind = eventsMatch.group(2)!;
      final key = '$animalId/$kind';
      if (method == 'GET') {
        return _okResponse({'data': events[key] ?? []});
      }
      if (method == 'POST') {
        final id = 'ev-${_eventSeq++}';
        final body = Map<String, dynamic>.from(options.data as Map? ?? {});
        final row = {...body, 'id': id};
        events.putIfAbsent(key, () => []).insert(0, row);
        if (kind == 'weight') {
          final existing = rows[animalId];
          if (existing != null) rows[animalId] = {...existing, 'weight': body['weight']};
        }
        return _okResponse({
          'data': {'id': id}
        }, statusCode: 201);
      }
    }

    if (method == 'POST' && path.endsWith('/delete')) {
      final id = path.substring(basePath.length + 1, path.length - '/delete'.length);
      rows.remove(id);
      return _okResponse({'data': true});
    }
    if (method == 'GET' && path.startsWith('$basePath/')) {
      final id = path.substring(basePath.length + 1);
      final row = rows[id];
      if (row == null) return _notFoundResponse();
      return _okResponse({'data': row});
    }
    if (method == 'PUT' && path.startsWith('$basePath/')) {
      final id = path.substring(basePath.length + 1);
      final existing = rows[id];
      if (existing == null) return _notFoundResponse();
      final body = Map<String, dynamic>.from(options.data as Map? ?? {});
      final row = {...existing, ...body};
      rows[id] = row;
      return _okResponse({'data': row});
    }

    throw StateError('FakeLivestockAnimalsResource($basePath): unhandled request $method $path');
  }
}

/// A `/api/mobile/equipment` fake: standard CRUD plus one nested
/// `/{id}/logs` list+create+delete collection that doesn't fit
/// [FakeRestResource]'s single flat-collection shape.
class FakeEquipmentResource implements FakeApiResource {
  FakeEquipmentResource(this.basePath, {this.idPrefix = 'eq'});

  @override
  final String basePath;
  final String idPrefix;
  final rows = <String, Map<String, dynamic>>{};
  final logs = <String, List<Map<String, dynamic>>>{};
  int _seq = 0;
  int _logSeq = 0;

  @override
  Response<dynamic> handle(RequestOptions options) {
    final path = options.path;
    final method = options.method;

    if (method == 'GET' && path == basePath) {
      return _okResponse({'data': rows.values.toList()});
    }
    if (method == 'POST' && path == basePath) {
      final id = '$idPrefix-${_seq++}';
      final body = Map<String, dynamic>.from(options.data as Map? ?? {});
      final row = {...body, 'id': id};
      rows[id] = row;
      return _okResponse({'data': row}, statusCode: 201);
    }

    final deleteLogMatch =
        RegExp('^${RegExp.escape(basePath)}/([^/]+)/logs/([^/]+)/delete\$')
            .firstMatch(path);
    if (method == 'POST' && deleteLogMatch != null) {
      final equipmentId = deleteLogMatch.group(1)!;
      final logId = deleteLogMatch.group(2)!;
      logs[equipmentId]?.removeWhere((l) => l['id'] == logId);
      return _okResponse({'data': true});
    }

    final logsMatch =
        RegExp('^${RegExp.escape(basePath)}/([^/]+)/logs\$').firstMatch(path);
    if (logsMatch != null) {
      final equipmentId = logsMatch.group(1)!;
      if (method == 'GET') {
        return _okResponse({'data': logs[equipmentId] ?? []});
      }
      if (method == 'POST') {
        final id = 'log-${_logSeq++}';
        final body = Map<String, dynamic>.from(options.data as Map? ?? {});
        final row = {...body, 'id': id};
        logs.putIfAbsent(equipmentId, () => []).insert(0, row);
        return _okResponse({
          'data': {'id': id}
        }, statusCode: 201);
      }
    }

    if (method == 'POST' && path.endsWith('/delete')) {
      final id = path.substring(basePath.length + 1, path.length - '/delete'.length);
      rows.remove(id);
      return _okResponse({'data': true});
    }
    if (method == 'GET' && path.startsWith('$basePath/')) {
      final id = path.substring(basePath.length + 1);
      final row = rows[id];
      if (row == null) return _notFoundResponse();
      return _okResponse({'data': row});
    }
    if (method == 'PUT' && path.startsWith('$basePath/')) {
      final id = path.substring(basePath.length + 1);
      final existing = rows[id];
      if (existing == null) return _notFoundResponse();
      final body = Map<String, dynamic>.from(options.data as Map? ?? {});
      final row = {...existing, ...body};
      rows[id] = row;
      return _okResponse({'data': row});
    }

    throw StateError('FakeEquipmentResource($basePath): unhandled request $method $path');
  }
}

/// The two fakes needed to cover `/api/mobile/livestock/...` in tests:
/// a plain types collection and the bespoke animals+events+sell fake.
List<FakeApiResource> fakeLivestockResources() => [
      FakeRestResource('/api/mobile/livestock/types'),
      FakeLivestockAnimalsResource('/api/mobile/livestock/animals'),
    ];

/// A [Dio] whose requests are answered by [resources] (keyed by exact
/// `basePath`) instead of hitting the network — pass to a repository under
/// test in place of the real `apiClientProvider`-sourced client.
Dio fakeApiDio(List<FakeApiResource> resources) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    try {
      final resource = resources.firstWhere(
        (r) => options.path == r.basePath || options.path.startsWith('${r.basePath}/'),
      );
      handler.resolve(resource.handle(options));
    } on DioException catch (e) {
      handler.reject(e);
    } catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }));
  return dio;
}
