enum SyncIndicatorStatus { online, offline, syncing, error }

class SyncIndicatorSnapshot {
  final SyncIndicatorStatus status;
  final String message;
  final DateTime? lastSyncAt;

  const SyncIndicatorSnapshot({
    required this.status,
    required this.message,
    this.lastSyncAt,
  });

  const SyncIndicatorSnapshot.offline()
      : status = SyncIndicatorStatus.offline,
        message = 'Offline',
        lastSyncAt = null;

  const SyncIndicatorSnapshot.online({DateTime? at})
      : status = SyncIndicatorStatus.online,
        message = 'Online',
        lastSyncAt = at;

  const SyncIndicatorSnapshot.syncing({DateTime? at})
      : status = SyncIndicatorStatus.syncing,
        message = 'Sincronizando',
        lastSyncAt = at;

  const SyncIndicatorSnapshot.error(this.message, {DateTime? at})
      : status = SyncIndicatorStatus.error,
        lastSyncAt = at;
}
