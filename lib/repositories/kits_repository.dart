import '../database/local_database_service.dart';
import '../models/apontamento_kit.dart';
import '../models/sync_status.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../sync/sync_service.dart';
import '../utils/user_service.dart';

class KitsRepository {
  KitsRepository({
    LocalDatabaseService? database,
    ConnectivityService? connectivityService,
    SyncService? syncService,
    ApiService? apiService,
  }) : _database = database ?? LocalDatabaseService.instance,
       _connectivity = connectivityService ?? ConnectivityService.instance,
       _syncService = syncService ?? SyncService.instance,
       _apiService = apiService ?? ApiService.instance;

  final LocalDatabaseService _database;
  final ConnectivityService _connectivity;
  final SyncService _syncService;
  final ApiService _apiService;

  Future<List<ApontamentoKit>> listarUltimos({int limit = 10}) async {
    final rows = await _database.query(
      'apontamentos_kits',
      orderBy: 'updated_at DESC',
    );
    return rows.take(limit).map(ApontamentoKit.fromMap).toList();
  }

  Future<ApontamentoKit> apontar({
    required String paleteUid,
  }) async {
    final userId = await UserService.getUserId();
    if (userId == null) {
      throw Exception('Usuário não autenticado');
    }

    final now = DateTime.now();
    final entity = ApontamentoKit(
      paleteUid: paleteUid.trim(),
      codigoMaterial: '',
      quantidade: 0,
      status: 'PENDENTE',
      apontadoPor: userId,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    final idLocal = await _database.insert('apontamentos_kits', entity.toMap());
    final saved = entity.copyWith(idLocal: idLocal);
    final payload = {'palete_uid': paleteUid.trim()};

    if (_connectivity.isOnline) {
      final response = await _apiService.apontarKit(payload);
      if (response['status'] == 'ok') {
        await _database.updateByLocalId(
          'apontamentos_kits',
          idLocal,
          {
            'sync_status': SyncStatus.synced.value,
            'updated_at': DateTime.now().toIso8601String(),
            'status': 'APONTADO',
          },
        );
        await _syncService.runAutoSync();
      } else {
        await _database.updateByLocalId(
          'apontamentos_kits',
          idLocal,
          {
            'sync_status': SyncStatus.error.value,
            'updated_at': DateTime.now().toIso8601String(),
            'error_message': response['mensagem']?.toString(),
          },
        );
        throw Exception(response['mensagem']?.toString() ?? 'Erro na API');
      }
    } else {
      await _database.enqueueSync(
        entityType: 'apontamentos_kits',
        entityIdLocal: idLocal,
        action: 'apontar',
        payload: payload,
      );
    }

    return saved;
  }

  Future<void> syncApontamento(int idLocal, Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.apontarKit(payload);
      if (response['status'] == 'ok') {
        await _database.updateByLocalId(
          'apontamentos_kits',
          idLocal,
          {
            'sync_status': SyncStatus.synced.value,
            'updated_at': DateTime.now().toIso8601String(),
            'status': 'APONTADO',
          },
        );
      } else {
        throw Exception(response['mensagem']?.toString() ?? 'Erro na API');
      }
    } catch (e) {
      await _database.updateByLocalId(
        'apontamentos_kits',
        idLocal,
        {
          'sync_status': SyncStatus.error.value,
          'error_message': e.toString(),
        },
      );
      rethrow;
    }
  }
}