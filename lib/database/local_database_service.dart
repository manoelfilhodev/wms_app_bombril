import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/sync_queue_item.dart';
import '../models/sync_status.dart';

class LocalDatabaseService {
  LocalDatabaseService._();
  static final LocalDatabaseService instance = LocalDatabaseService._();

  static const _databaseName = 'wms_offline_first.db';
  static const _databaseVersion = 3;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    await init();
    return _database!;
  }

  Future<void> init() async {
    if (_database != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, _databaseName);
    _database = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        id_server INTEGER,
        username TEXT NOT NULL UNIQUE,
        nome TEXT NOT NULL,
        nivel TEXT,
        tipo TEXT,
        unidade INTEGER,
        password_hash TEXT NOT NULL,
        token TEXT,
        token_needs_revalidation INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE funcionarios (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        id_server INTEGER,
        nome TEXT NOT NULL,
        matricula TEXT NOT NULL,
        cargo TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE apontamentos_kits (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        id_server INTEGER,
        palete_uid TEXT NOT NULL,
        codigo_material TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        status TEXT NOT NULL,
        apontado_por INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE recebimentos (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        id_server INTEGER,
        data_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE estoque (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        id_server INTEGER,
        data_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE movimentacoes (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        id_server INTEGER,
        data_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE contagem_livre (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        id_server INTEGER,
        contado_por INTEGER NOT NULL,
        sku TEXT NOT NULL,
        ficha TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        data_hora TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ean_cache (
        ean TEXT PRIMARY KEY,
        sku TEXT NOT NULL,
        descricao TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id_local INTEGER NOT NULL,
        action TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        error_message TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_conflicts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id_local INTEGER,
        entity_id_server INTEGER,
        local_payload_json TEXT NOT NULL,
        server_payload_json TEXT NOT NULL,
        reason TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_funcionarios_sync_status ON funcionarios(sync_status)',
    );
    await db.execute('CREATE INDEX idx_funcionarios_deleted_at ON funcionarios(deleted_at)');
    await db.execute('CREATE INDEX idx_sync_queue_status ON sync_queue(status)');
    await db.execute('CREATE INDEX idx_sync_queue_entity ON sync_queue(entity_type, entity_id_local)');
    await db.execute('CREATE INDEX idx_contagem_livre_sync_status ON contagem_livre(sync_status)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS contagem_livre (
          id_local INTEGER PRIMARY KEY AUTOINCREMENT,
          id_server INTEGER,
          contado_por INTEGER NOT NULL,
          sku TEXT NOT NULL,
          ficha TEXT NOT NULL,
          quantidade INTEGER NOT NULL,
          data_hora TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          sync_status TEXT NOT NULL DEFAULT 'pending',
          deleted_at TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS ean_cache (
          ean TEXT PRIMARY KEY,
          sku TEXT NOT NULL,
          descricao TEXT,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_contagem_livre_sync_status ON contagem_livre(sync_status)',
      );
    }

    if (oldVersion < 3) {
      // Adiciona coluna error_message às tabelas que precisam
      await db.execute('ALTER TABLE apontamentos_kits ADD COLUMN error_message TEXT');
      await db.execute('ALTER TABLE contagem_livre ADD COLUMN error_message TEXT');
      await db.execute('ALTER TABLE funcionarios ADD COLUMN error_message TEXT');
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data);
  }

  Future<int> updateByLocalId(
    String table,
    int idLocal,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    return db.update(table, data, where: 'id_local = ?', whereArgs: [idLocal]);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<Map<String, dynamic>?> findByLocalId(String table, int idLocal) async {
    final rows = await query(table, where: 'id_local = ?', whereArgs: [idLocal], orderBy: 'id_local DESC');
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> softDeleteByLocalId(String table, int idLocal) async {
    final now = DateTime.now().toIso8601String();
    await updateByLocalId(table, idLocal, {
      'deleted_at': now,
      'updated_at': now,
      'sync_status': SyncStatus.pending.value,
    });
  }

  Future<int> enqueueSync({
    required String entityType,
    required int entityIdLocal,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now().toIso8601String();
    return insert('sync_queue', {
      'entity_type': entityType,
      'entity_id_local': entityIdLocal,
      'action': action,
      'payload_json': jsonEncode(payload),
      'status': SyncStatus.pending.value,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<List<SyncQueueItem>> getPendingQueue() async {
    final rows = await query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: [SyncStatus.pending.value],
      orderBy: 'created_at ASC',
    );
    return rows.map(SyncQueueItem.fromMap).toList();
  }

  Future<void> updateQueueStatus({
    required int id,
    required SyncStatus status,
    String? errorMessage,
  }) async {
    final db = await database;
    await db.update(
      'sync_queue',
      {
        'status': status.value,
        'error_message': errorMessage,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markEntitySynced({
    required String table,
    required int idLocal,
    int? idServer,
  }) async {
    final payload = <String, Object?>{
      'sync_status': SyncStatus.synced.value,
      'updated_at': DateTime.now().toIso8601String(),
      if (idServer != null) 'id_server': idServer,
    };
    await updateByLocalId(table, idLocal, payload);
  }

  Future<void> markEntityError({
    required String table,
    required int idLocal,
  }) async {
    await updateByLocalId(table, idLocal, {
      'sync_status': SyncStatus.error.value,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> upsertUser({
    required int idServer,
    required String username,
    required String nome,
    required String passwordHash,
    required String token,
    String? nivel,
    String? tipo,
    int? unidade,
    bool tokenNeedsRevalidation = false,
  }) async {
    final now = DateTime.now().toIso8601String();
    final existing = await query('users', where: 'username = ?', whereArgs: [username]);
    final payload = {
      'id_server': idServer,
      'username': username,
      'nome': nome,
      'password_hash': passwordHash,
      'token': token,
      'nivel': nivel,
      'tipo': tipo,
      'unidade': unidade,
      'token_needs_revalidation': tokenNeedsRevalidation ? 1 : 0,
      'updated_at': now,
      'sync_status': SyncStatus.synced.value,
      'deleted_at': null,
    };

    if (existing.isEmpty) {
      await insert('users', {
        ...payload,
        'created_at': now,
      });
      return;
    }

    final idLocal = (existing.first['id_local'] as num).toInt();
    await updateByLocalId('users', idLocal, payload);
  }

  Future<Map<String, dynamic>?> findUserByUsernameAndPassword({
    required String username,
    required String passwordHash,
  }) async {
    final rows = await query(
      'users',
      where:
          'username = ? AND password_hash = ? AND deleted_at IS NULL',
      whereArgs: [username, passwordHash],
      orderBy: 'updated_at DESC',
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> setTokenNeedsRevalidation({
    required String username,
    required bool value,
  }) async {
    final rows = await query('users', where: 'username = ?', whereArgs: [username]);
    if (rows.isEmpty) return;
    final idLocal = (rows.first['id_local'] as num).toInt();
    await updateByLocalId('users', idLocal, {
      'token_needs_revalidation': value ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> insertConflictLog({
    required String entityType,
    required int? entityIdLocal,
    required int? entityIdServer,
    required Map<String, dynamic> localPayload,
    required Map<String, dynamic> serverPayload,
    required String reason,
  }) async {
    await insert('sync_conflicts', {
      'entity_type': entityType,
      'entity_id_local': entityIdLocal,
      'entity_id_server': entityIdServer,
      'local_payload_json': jsonEncode(localPayload),
      'server_payload_json': jsonEncode(serverPayload),
      'reason': reason,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> clearQueueItem(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getPendingSyncCount({String? entityType}) async {
    final db = await database;
    final where = entityType == null
        ? 'status = ?'
        : 'status = ? AND entity_type = ?';
    final whereArgs = entityType == null
        ? <Object?>[SyncStatus.pending.value]
        : <Object?>[SyncStatus.pending.value, entityType];

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM sync_queue WHERE $where',
      whereArgs,
    );
    final total = result.first['total'];
    if (total is int) return total;
    if (total is num) return total.toInt();
    return int.tryParse(total?.toString() ?? '') ?? 0;
  }

  Future<void> cacheEan({
    required String ean,
    required String sku,
    String? descricao,
  }) async {
    final db = await database;
    await db.insert(
      'ean_cache',
      {
        'ean': ean.trim(),
        'sku': sku.trim(),
        'descricao': descricao ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> findCachedEan(String ean) async {
    final db = await database;
    final rows = await db.query(
      'ean_cache',
      where: 'ean = ?',
      whereArgs: [ean.trim()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<int> saveContagemLivrePending({
    required int contadoPor,
    required String? sku,
    required String ean,
    required String ficha,
    required int quantidade,
    required String dataHoraIso,
  }) async {
    final resolvedSku = (sku != null && sku.trim().isNotEmpty)
        ? sku.trim()
        : '__EAN_PENDING__:$ean';
    final now = DateTime.now().toIso8601String();
    final idLocal = await insert('contagem_livre', {
      'contado_por': contadoPor,
      'sku': resolvedSku,
      'ficha': ficha,
      'quantidade': quantidade,
      'data_hora': dataHoraIso,
      'created_at': now,
      'updated_at': now,
      'sync_status': SyncStatus.pending.value,
    });

    await enqueueSync(
      entityType: 'contagem_livre',
      entityIdLocal: idLocal,
      action: 'create',
      payload: {
        'contado_por': contadoPor,
        'sku': resolvedSku,
        'ean': ean,
        'ficha': ficha,
        'quantidade': quantidade,
        'data_hora': dataHoraIso,
      },
    );

    return idLocal;
  }
}
