import 'package:flutter/foundation.dart';

import '../database/local_database_service.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../services/token_storage_service.dart';
import '../sync/sync_service.dart';
import '../sync/sync_state.dart';

class AppBootstrap {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    await TokenStorageService.instance.migrateFromLegacyPrefs();
    await ConnectivityService.instance.startMonitoring();

    if (kIsWeb) {
      final online = ConnectivityService.instance.isOnline;
      SyncService.instance.statusNotifier.value = online
          ? const SyncIndicatorSnapshot.online()
          : const SyncIndicatorSnapshot.offline();
    } else {
      await LocalDatabaseService.instance.init();
      await SyncService.instance.initialize(
        database: LocalDatabaseService.instance,
        apiService: ApiService.instance,
        connectivityService: ConnectivityService.instance,
      );
    }

    _initialized = true;
  }
}
