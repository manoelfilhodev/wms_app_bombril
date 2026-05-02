enum SyncStatus { pending, synced, error }

extension SyncStatusMapper on SyncStatus {
  String get value {
    switch (this) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.error:
        return 'error';
    }
  }

  static SyncStatus fromValue(String? value) {
    switch (value) {
      case 'synced':
        return SyncStatus.synced;
      case 'error':
        return SyncStatus.error;
      case 'pending':
      default:
        return SyncStatus.pending;
    }
  }
}

