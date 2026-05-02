import 'dart:convert';

import 'sync_status.dart';

class SyncQueueItem {
  final int? id;
  final String entityType;
  final int entityIdLocal;
  final String action;
  final Map<String, dynamic> payloadJson;
  final SyncStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? errorMessage;

  const SyncQueueItem({
    this.id,
    required this.entityType,
    required this.entityIdLocal,
    required this.action,
    required this.payloadJson,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id_local': entityIdLocal,
      'action': action,
      'payload_json': jsonEncode(payloadJson),
      'status': status.value,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    final payload = map['payload_json']?.toString() ?? '{}';
    return SyncQueueItem(
      id: map['id'] as int?,
      entityType: map['entity_type']?.toString() ?? '',
      entityIdLocal: (map['entity_id_local'] as num?)?.toInt() ?? 0,
      action: map['action']?.toString() ?? 'create',
      payloadJson: Map<String, dynamic>.from(jsonDecode(payload) as Map),
      status: SyncStatusMapper.fromValue(map['status']?.toString()),
      errorMessage: map['error_message']?.toString(),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

