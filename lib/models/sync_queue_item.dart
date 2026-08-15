import 'dart:convert';

enum SyncQueueStatus { queued, syncing, synced, failed }

class SyncQueueItem {
  final String id;
  final String clientId;
  final String type;
  final String method;
  final String path;
  final Map<String, dynamic> payload;
  final SyncQueueStatus status;
  final String? error;
  final DateTime createdAt;
  final DateTime? syncedAt;

  const SyncQueueItem({
    required this.id,
    required this.clientId,
    required this.type,
    required this.method,
    required this.path,
    required this.payload,
    required this.status,
    this.error,
    required this.createdAt,
    this.syncedAt,
  });

  SyncQueueItem copyWith({
    SyncQueueStatus? status,
    String? error,
    DateTime? syncedAt,
  }) =>
      SyncQueueItem(
        id: id,
        clientId: clientId,
        type: type,
        method: method,
        path: path,
        payload: payload,
        status: status ?? this.status,
        error: error,
        createdAt: createdAt,
        syncedAt: syncedAt ?? this.syncedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'type': type,
        'method': method,
        'path': path,
        'payload': payload,
        'status': status.name,
        'error': error,
        'createdAt': createdAt.toIso8601String(),
        'syncedAt': syncedAt?.toIso8601String(),
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
        id: json['id'] as String,
        clientId: json['clientId'] as String,
        type: json['type'] as String,
        method: json['method'] as String,
        path: json['path'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        status: SyncQueueStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => SyncQueueStatus.queued,
        ),
        error: json['error'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        syncedAt: json['syncedAt'] != null
            ? DateTime.parse(json['syncedAt'] as String)
            : null,
      );

  static String encodeList(List<SyncQueueItem> items) =>
      jsonEncode(items.map((item) => item.toJson()).toList());

  static List<SyncQueueItem> decodeList(String? value) {
    if (value == null || value.isEmpty) return const [];
    final decoded = jsonDecode(value) as List;
    return decoded
        .map((e) => SyncQueueItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
