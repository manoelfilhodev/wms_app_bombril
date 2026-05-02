import 'sync_status.dart';

class ApontamentoKit {
  final int? idLocal;
  final int? idServer;
  final String paleteUid;
  final String codigoMaterial;
  final int quantidade;
  final String status;
  final int? apontadoPor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;
  final DateTime? deletedAt;

  const ApontamentoKit({
    this.idLocal,
    this.idServer,
    required this.paleteUid,
    required this.codigoMaterial,
    required this.quantidade,
    required this.status,
    this.apontadoPor,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.deletedAt,
  });

  ApontamentoKit copyWith({
    int? idLocal,
    int? idServer,
    String? paleteUid,
    String? codigoMaterial,
    int? quantidade,
    String? status,
    int? apontadoPor,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return ApontamentoKit(
      idLocal: idLocal ?? this.idLocal,
      idServer: idServer ?? this.idServer,
      paleteUid: paleteUid ?? this.paleteUid,
      codigoMaterial: codigoMaterial ?? this.codigoMaterial,
      quantidade: quantidade ?? this.quantidade,
      status: status ?? this.status,
      apontadoPor: apontadoPor ?? this.apontadoPor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_local': idLocal,
      'id_server': idServer,
      'palete_uid': paleteUid,
      'codigo_material': codigoMaterial,
      'quantidade': quantidade,
      'status': status,
      'apontado_por': apontadoPor,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus.value,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiPayload() {
    return {
      if (idServer != null) 'id': idServer,
      'palete_uid': paleteUid,
      'codigo_material': codigoMaterial,
      'quantidade': quantidade,
      'status': status,
      'apontado_por': apontadoPor,
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory ApontamentoKit.fromMap(Map<String, dynamic> map) {
    return ApontamentoKit(
      idLocal: (map['id_local'] as num?)?.toInt(),
      idServer: (map['id_server'] as num?)?.toInt(),
      paleteUid: map['palete_uid']?.toString() ?? '',
      codigoMaterial: map['codigo_material']?.toString() ?? '',
      quantidade: (map['quantidade'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? 'GERADO',
      apontadoPor: (map['apontado_por'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      syncStatus: SyncStatusMapper.fromValue(map['sync_status']?.toString()),
      deletedAt: DateTime.tryParse(map['deleted_at']?.toString() ?? ''),
    );
  }

  factory ApontamentoKit.fromServer(Map<String, dynamic> json) {
    final now = DateTime.now();
    return ApontamentoKit(
      idServer: (json['id'] as num?)?.toInt(),
      paleteUid: json['palete_uid']?.toString() ?? '',
      codigoMaterial: json['codigo_material']?.toString() ?? '',
      quantidade: (json['quantidade'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'GERADO',
      apontadoPor: (json['apontado_por'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? now,
      syncStatus: SyncStatus.synced,
    );
  }
}