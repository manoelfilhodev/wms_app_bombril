import 'dart:async';

import 'package:flutter/foundation.dart';

import '../database/local_database_service.dart';
import '../models/funcionario.dart';
import '../models/sync_status.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import 'sync_state.dart';

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final ValueNotifier<SyncIndicatorSnapshot> statusNotifier =
      ValueNotifier(const SyncIndicatorSnapshot.offline());

  LocalDatabaseService? _db;
  ApiService? _api;
  ConnectivityService? _connectivity;
  StreamSubscription<NetworkStatus>? _connectivitySub;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;
  static const String _eanPendingPrefix = '__EAN_PENDING__:';

  Future<void> initialize({
    required LocalDatabaseService database,
    required ApiService apiService,
    required ConnectivityService connectivityService,
  }) async {
    _db = database;
    _api = apiService;
    _connectivity = connectivityService;

    _connectivitySub ??= connectivityService.statusStream.listen((status) async {
      if (status == NetworkStatus.offline) {
        statusNotifier.value = const SyncIndicatorSnapshot.offline();
        return;
      }
      await runAutoSync();
    });

    if (connectivityService.isOnline) {
      await runAutoSync();
    } else {
      statusNotifier.value = const SyncIndicatorSnapshot.offline();
    }
  }

  Future<void> runAutoSync() async {
    if (_isSyncing) return;
    if (_db == null || _api == null || _connectivity == null) return;
    if (!_connectivity!.isOnline) {
      statusNotifier.value = const SyncIndicatorSnapshot.offline();
      return;
    }

    _isSyncing = true;
    statusNotifier.value = SyncIndicatorSnapshot.syncing(at: _lastSyncAt);

    try {
      await _pushPendingQueue();
      await _pullFuncionarios();
      _lastSyncAt = DateTime.now();
      statusNotifier.value = SyncIndicatorSnapshot.online(at: _lastSyncAt);
    } catch (e) {
      // Só mostra erro se for erro crítico de conectividade
      if (e.toString().contains('connectivity') || e.toString().contains('network')) {
        statusNotifier.value = SyncIndicatorSnapshot.error(
          'Erro de conectividade',
          at: _lastSyncAt,
        );
      } else {
        // Para outros erros, mantém online mas registra o erro
        statusNotifier.value = SyncIndicatorSnapshot.online(at: _lastSyncAt);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushPendingQueue() async {
    final db = _db!;
    final queue = await db.getPendingQueue();

    for (final item in queue) {
      try {
        final payload = Map<String, dynamic>.from(item.payloadJson);
        if (item.entityType == 'funcionarios') {
          await _syncFuncionarioQueueItem(
            itemId: item.id!,
            action: item.action,
            localId: item.entityIdLocal,
            payload: payload,
          );
        } else if (item.entityType == 'contagem_livre') {
          await _syncContagemLivreQueueItem(
            itemId: item.id!,
            action: item.action,
            localId: item.entityIdLocal,
            payload: payload,
          );
        } else if (item.entityType == 'apontamentos_kits') {
          await _syncApontamentoKitQueueItem(
            itemId: item.id!,
            action: item.action,
            localId: item.entityIdLocal,
            payload: payload,
          );
        } else {
          // Estruturalmente pronto para outras entidades.
          await db.updateQueueStatus(id: item.id!, status: SyncStatus.synced);
          await db.clearQueueItem(item.id!);
        }
      } catch (e) {
        await db.updateQueueStatus(
          id: item.id!,
          status: SyncStatus.error,
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> _syncContagemLivreQueueItem({
    required int itemId,
    required String action,
    required int localId,
    required Map<String, dynamic> payload,
  }) async {
    final db = _db!;
    final api = _api!;
    if (action != 'create') {
      await db.updateQueueStatus(id: itemId, status: SyncStatus.synced);
      await db.clearQueueItem(itemId);
      return;
    }

    final normalizedPayload = Map<String, dynamic>.from(payload);
    final skuValue = normalizedPayload['sku']?.toString() ?? '';
    if (skuValue.startsWith(_eanPendingPrefix)) {
      final ean = normalizedPayload['ean']?.toString().trim() ??
          skuValue.replaceFirst(_eanPendingPrefix, '').trim();
      if (ean.isEmpty) {
        throw Exception('EAN pendente sem valor para resolver SKU');
      }

      final produto = await api.buscarDescricaoContagemLivrePorEan(ean);
      final resolvedSku = produto?['sku']?.toString().trim() ?? '';
      if (resolvedSku.isEmpty) {
        throw Exception('EAN $ean ainda nao resolvido no servidor');
      }
      normalizedPayload['sku'] = resolvedSku;
      await db.updateByLocalId('contagem_livre', localId, {
        'sku': resolvedSku,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    final response = await api.createContagemLivre(normalizedPayload);
    final serverId = _extractServerId(response);
    await db.markEntitySynced(
      table: 'contagem_livre',
      idLocal: localId,
      idServer: serverId,
    );
    await db.updateQueueStatus(id: itemId, status: SyncStatus.synced);
    await db.clearQueueItem(itemId);
  }

  Future<void> _syncFuncionarioQueueItem({
    required int itemId,
    required String action,
    required int localId,
    required Map<String, dynamic> payload,
  }) async {
    final db = _db!;
    final api = _api!;

    if (action == 'create') {
      final response = await api.createFuncionario(payload);
      final serverId = _extractServerId(response);
      await db.markEntitySynced(
        table: 'funcionarios',
        idLocal: localId,
        idServer: serverId,
      );
      await db.updateQueueStatus(id: itemId, status: SyncStatus.synced);
      await db.clearQueueItem(itemId);
      return;
    }

    final localRow = await db.findByLocalId('funcionarios', localId);
    final idServer = (localRow?['id_server'] as num?)?.toInt() ??
        (payload['id'] as num?)?.toInt();
    if (idServer == null) {
      await db.updateQueueStatus(
        id: itemId,
        status: SyncStatus.error,
        errorMessage: 'Registro sem id_server para sync',
      );
      await db.markEntityError(table: 'funcionarios', idLocal: localId);
      return;
    }

    if (action == 'update') {
      await api.updateFuncionario(idServer: idServer, payload: payload);
      await db.markEntitySynced(table: 'funcionarios', idLocal: localId);
      await db.updateQueueStatus(id: itemId, status: SyncStatus.synced);
      await db.clearQueueItem(itemId);
      return;
    }

    if (action == 'delete') {
      await api.deleteFuncionario(idServer);
      await db.markEntitySynced(table: 'funcionarios', idLocal: localId);
      await db.updateQueueStatus(id: itemId, status: SyncStatus.synced);
      await db.clearQueueItem(itemId);
    }
  }

  Future<void> _pullFuncionarios() async {
    final db = _db!;
    final api = _api!;
    final serverRows = await api.fetchFuncionarios();

    for (final row in serverRows) {
      final serverEntity = Funcionario.fromServer(row);
      final localRows = await db.query(
        'funcionarios',
        where: 'id_server = ?',
        whereArgs: [serverEntity.idServer],
      );

      if (localRows.isEmpty) {
        await db.insert('funcionarios', serverEntity.toMap());
        continue;
      }

      final local = Funcionario.fromMap(localRows.first);
      final localUpdated = local.updatedAt;
      final serverUpdated = serverEntity.updatedAt;

      if (localUpdated.isAfter(serverUpdated)) {
        await db.insertConflictLog(
          entityType: 'funcionarios',
          entityIdLocal: local.idLocal,
          entityIdServer: local.idServer,
          localPayload: local.toMap(),
          serverPayload: serverEntity.toMap(),
          reason: 'local_updated_at_newer_than_server',
        );

        await db.enqueueSync(
          entityType: 'funcionarios',
          entityIdLocal: local.idLocal!,
          action: 'update',
          payload: local.toApiPayload(),
        );
        continue;
      }

      await db.updateByLocalId(
        'funcionarios',
        local.idLocal!,
        serverEntity.copyWith(
          idLocal: local.idLocal,
          syncStatus: SyncStatus.synced,
        ).toMap(),
      );
    }
  }

  int? _extractServerId(Map<String, dynamic> data) {
    final candidates = [
      data['id'],
      (data['data'] is Map) ? (data['data'] as Map)['id'] : null,
      data['id_server'],
    ];
    for (final value in candidates) {
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  Future<void> _syncApontamentoKitQueueItem({
    required int itemId,
    required String action,
    required int localId,
    required Map<String, dynamic> payload,
  }) async {
    final db = _db!;
    if (action != 'apontar') {
      await db.updateQueueStatus(id: itemId, status: SyncStatus.synced);
      await db.clearQueueItem(itemId);
      return;
    }

    try {
      final response = await _api!.apontarKit(payload);

      if (response['status'] == 'ok') {
        final updatedFields = <String, dynamic>{
          'sync_status': SyncStatus.synced.value,
          'updated_at': DateTime.now().toIso8601String(),
          'status': 'APONTADO',
        };

        final rawData = response['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(response['data'] as Map)
            : <String, dynamic>{};

        final codigoMaterial = rawData['codigo_material']?.toString() ??
            rawData['codigoMaterial']?.toString() ?? '';
        final quantidade = (rawData['quantidade'] as num?)?.toInt() ??
            int.tryParse(rawData['quantidade']?.toString() ?? '') ?? 0;
        final idServer = _extractServerId(rawData) ?? _extractServerId(response);

        if (codigoMaterial.isNotEmpty) {
          updatedFields['codigo_material'] = codigoMaterial;
        }
        if (quantidade != 0) {
          updatedFields['quantidade'] = quantidade;
        }
        if (idServer != null) {
          updatedFields['id_server'] = idServer;
        }

        await db.updateByLocalId('apontamentos_kits', localId, updatedFields);
        await db.updateQueueStatus(id: itemId, status: SyncStatus.synced);
        await db.clearQueueItem(itemId);
      } else {
        throw Exception(response['mensagem']?.toString() ?? 'Erro na API');
      }
    } catch (e) {
      await db.updateQueueStatus(
        id: itemId,
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
      await db.updateByLocalId(
        'apontamentos_kits',
        localId,
        {
          'sync_status': SyncStatus.error.value,
          'error_message': e.toString(),
        },
      );
    }
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    statusNotifier.dispose();
  }
}
