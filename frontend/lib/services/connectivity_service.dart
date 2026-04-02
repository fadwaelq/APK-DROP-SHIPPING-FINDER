import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  bool _isConnected = false;
  bool _isChecking = false;

  List<ConnectivityResult> get connectionStatus => _connectionStatus;
  bool get isConnected => _isConnected;
  bool get isOnline => _isConnected && !_isChecking;
  bool get isChecking => _isChecking;

  Future<void> initialize() async {
    await checkConnectivity();
    
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _updateConnectionStatus(result);
    });
  }

  Future<void> checkConnectivity() async {
    _isChecking = true;
    notifyListeners();
    
    try {
      final List<ConnectivityResult> result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      _connectionStatus = [ConnectivityResult.none];
      _isConnected = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    _connectionStatus = result;
    _isConnected = result.contains(ConnectivityResult.wifi) ||
                  result.contains(ConnectivityResult.ethernet) ||
                  result.contains(ConnectivityResult.mobile);
    
    debugPrint('🌐 Connectivity Status: $_connectionStatus, Connected: $_isConnected');
    notifyListeners();
  }

  String get connectionStatusText {
    if (_isChecking) return 'Vérification...';
    if (!_isConnected) return 'Hors ligne';
    if (_connectionStatus.contains(ConnectivityResult.wifi)) return 'Wi-Fi';
    if (_connectionStatus.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    if (_connectionStatus.contains(ConnectivityResult.mobile)) return 'Mobile';
    return 'Inconnu';
  }

  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isConnected) return true;

    final completer = Completer<bool>();
    late StreamSubscription<List<ConnectivityResult>> subscription;

    subscription = Connectivity().onConnectivityChanged.listen((result) {
      final isConnected = result.contains(ConnectivityResult.wifi) ||
                        result.contains(ConnectivityResult.ethernet) ||
                        result.contains(ConnectivityResult.mobile);
      
      if (isConnected) {
        subscription.cancel();
        completer.complete(true);
      }
    });

    // Set timeout
    Timer(timeout, () {
      subscription.cancel();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    return completer.future;
  }
}
