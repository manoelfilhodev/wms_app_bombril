import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline }

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  NetworkStatus _currentStatus = NetworkStatus.offline;

  NetworkStatus get currentStatus => _currentStatus;
  bool get isOnline => _currentStatus == NetworkStatus.online;
  Stream<NetworkStatus> get statusStream => _controller.stream;

  Future<void> startMonitoring() async {
    await _updateFromConnectivityResults(await _connectivity.checkConnectivity());
    _subscription ??= _connectivity.onConnectivityChanged.listen(
      _updateFromConnectivityResults,
    );
  }

  Future<void> _updateFromConnectivityResults(
    List<ConnectivityResult> results,
  ) async {
    final next = results.any((r) => r != ConnectivityResult.none)
        ? NetworkStatus.online
        : NetworkStatus.offline;
    if (next == _currentStatus) return;
    _currentStatus = next;
    _controller.add(next);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}

