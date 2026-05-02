import 'sync_status.dart';

class Funcionario {
  final int? idLocal;
  final int? idServer;
  final String nome;
  final String matricula;
  final String cargo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;
  final DateTime? deletedAt;

  const Funcionario({
    this.idLocal,
    this.idServer,
    required this.nome,
    required this.matricula,
    required this.cargo,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.deletedAt,
  });

  Funcionario copyWith({
    int? idLocal,
    int? idServer,
    String? nome,
    String? matricula,
    String? cargo,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Funcionario(
      idLocal: idLocal ?? this.idLocal,
      idServer: idServer ?? this.idServer,
      nome: nome ?? this.nome,
      matricula: matricula ?? this.matricula,
      cargo: cargo ?? this.cargo,
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
      'nome': nome,
      'matricula': matricula,
      'cargo': cargo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus.value,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiPayload() {
    return {
      if (idServer != null) 'id': idServer,
      'nome': nome,
      'matricula': matricula,
      'cargo': cargo,
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory Funcionario.fromMap(Map<String, dynamic> map) {
    return Funcionario(
      idLocal: (map['id_local'] as num?)?.toInt(),
      idServer: (map['id_server'] as num?)?.toInt(),
      nome: map['nome']?.toString() ?? '',
      matricula: map['matricula']?.toString() ?? '',
      cargo: map['cargo']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      syncStatus: SyncStatusMapper.fromValue(map['sync_status']?.toString()),
      deletedAt: DateTime.tryParse(map['deleted_at']?.toString() ?? ''),
    );
  }

  factory Funcionario.fromServer(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Funcionario(
      idServer: (json['id'] as num?)?.toInt(),
      nome: json['nome']?.toString() ?? '',
      matricula: json['matricula']?.toString() ?? '',
      cargo: json['cargo']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? now,
      syncStatus: SyncStatus.synced,
      deletedAt: DateTime.tryParse(json['deleted_at']?.toString() ?? ''),
    );
  }
}

