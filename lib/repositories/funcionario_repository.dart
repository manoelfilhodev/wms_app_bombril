import '../database/local_database_service.dart';
import '../models/funcionario.dart';
import '../models/sync_status.dart';
import '../services/connectivity_service.dart';
import '../sync/sync_service.dart';

class FuncionarioRepository {
  FuncionarioRepository({
    LocalDatabaseService? database,
    ConnectivityService? connectivityService,
    SyncService? syncService,
  }) : _database = database ?? LocalDatabaseService.instance,
       _connectivity = connectivityService ?? ConnectivityService.instance,
       _syncService = syncService ?? SyncService.instance;

  final LocalDatabaseService _database;
  final ConnectivityService _connectivity;
  final SyncService _syncService;

  Future<List<Funcionario>> listarAtivos() async {
    final rows = await _database.query(
      'funcionarios',
      where: 'deleted_at IS NULL',
      orderBy: 'updated_at DESC',
    );
    return rows.map(Funcionario.fromMap).toList();
  }

  Future<Funcionario> criar({
    required String nome,
    required String matricula,
    required String cargo,
  }) async {
    final now = DateTime.now();
    final entity = Funcionario(
      nome: nome.trim(),
      matricula: matricula.trim(),
      cargo: cargo.trim(),
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    final idLocal = await _database.insert('funcionarios', entity.toMap());
    final saved = entity.copyWith(idLocal: idLocal);

    await _database.enqueueSync(
      entityType: 'funcionarios',
      entityIdLocal: idLocal,
      action: 'create',
      payload: saved.toApiPayload(),
    );

    if (_connectivity.isOnline) {
      await _syncService.runAutoSync();
    }
    return saved;
  }

  Future<Funcionario> atualizar(Funcionario entity) async {
    final updated = entity.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    await _database.updateByLocalId('funcionarios', entity.idLocal!, updated.toMap());
    await _database.enqueueSync(
      entityType: 'funcionarios',
      entityIdLocal: entity.idLocal!,
      action: 'update',
      payload: updated.toApiPayload(),
    );

    if (_connectivity.isOnline) {
      await _syncService.runAutoSync();
    }
    return updated;
  }

  Future<void> excluir(Funcionario entity) async {
    await _database.softDeleteByLocalId('funcionarios', entity.idLocal!);
    final deleted = entity.copyWith(
      deletedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
    await _database.enqueueSync(
      entityType: 'funcionarios',
      entityIdLocal: entity.idLocal!,
      action: 'delete',
      payload: deleted.toApiPayload(),
    );

    if (_connectivity.isOnline) {
      await _syncService.runAutoSync();
    }
  }
}

