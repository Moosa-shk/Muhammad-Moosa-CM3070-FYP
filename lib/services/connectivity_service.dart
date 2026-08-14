import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:disaster_app_ui/services/firestore_sync.dart';

/// Service responsible for monitoring internet connectivity.
/// When the device reconnects to the internet, it triggers
/// synchronization of locally stored data with Firestore.
class ConnectivityService {

  /// Stream subscription used to listen for connectivity changes
  static StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Starts monitoring network connectivity changes.
  /// If internet becomes available, Firestore sync will begin.
  static void startMonitoring() {

    /// Cancel any previous subscription to avoid duplicate listeners
    _sub?.cancel();

    /// Listen for connectivity updates from the device
    _sub = Connectivity().onConnectivityChanged.listen((results) async {

      /// Ensure the connectivity result list is not empty
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;

      /// Determine whether the device is online
      final online = result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi;

      /// If internet is available, start syncing local data to Firestore
      if (online) {
        await FirestoreSyncService.startLiveSync();
      }
    });
  }

  /// Stops connectivity monitoring and releases the subscription
  static Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}