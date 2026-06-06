import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

@riverpod
ConnectivityService connectivityService(Ref ref) => ConnectivityService();

@riverpod
Stream<bool> connectivityStream(Ref ref) {
  return ref.watch(connectivityServiceProvider).onConnectivityChanged;
}

@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  @override
  bool build() {
    ref.listen(connectivityStreamProvider, (_, next) {
      next.whenData((isOnline) => state = isOnline);
    });
    return true;
  }
}

class ConnectivityService {
  final _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => !results.contains(ConnectivityResult.none),
    );
  }

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
