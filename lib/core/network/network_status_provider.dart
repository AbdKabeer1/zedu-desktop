import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:zedu/core/core.dart';

enum NetworkStatus { online, offline }

class NetworkStatusNotifier extends Notifier<NetworkStatus> {
  final _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  NetworkStatus build() {
    _checkAndSetConnectivity();
    _startListening();
    return _isOnline ? NetworkStatus.online : NetworkStatus.offline;
  }

  Future<void> _checkAndSetConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isOnline = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.ethernet);
      if (!ref.mounted) return;
      state = isOnline ? NetworkStatus.online : NetworkStatus.offline;
    } catch (_) {
      if (!ref.mounted) return;
      state = NetworkStatus.offline;
    }
  }

  void _startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) {
        final isOnline = result.contains(ConnectivityResult.wifi) ||
            result.contains(ConnectivityResult.mobile) ||
            result.contains(ConnectivityResult.ethernet);
        if (!ref.mounted) return;
        state = isOnline ? NetworkStatus.online : NetworkStatus.offline;
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void setOffline() {
    state = NetworkStatus.offline;
  }

  void setOnline() {
    state = NetworkStatus.online;
  }

  void toggle() {
    state = state == NetworkStatus.online ? NetworkStatus.offline : NetworkStatus.online;
  }
}

final networkStatusProvider =
    NotifierProvider<NetworkStatusNotifier, NetworkStatus>(
      NetworkStatusNotifier.new,
    );