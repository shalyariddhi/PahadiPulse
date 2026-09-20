import 'dart:async';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _statusController = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _statusController.stream;

  bool _isOnline = true;
  bool _simulatedOffline = false;
  Timer? _pollTimer;

  bool get isOnline => _simulatedOffline ? false : _isOnline;
  bool get isSimulatedOffline => _simulatedOffline;

  void startMonitoring({Duration interval = const Duration(seconds: 15)}) {
    _pollTimer?.cancel();
    _checkStatus();
    _pollTimer = Timer.periodic(interval, (_) => _checkStatus());
  }

  void stopMonitoring() {
    _pollTimer?.cancel();
  }

  void setSimulatedOffline(bool simulated) {
    _simulatedOffline = simulated;
    _statusController.add(isOnline);
  }

  Future<bool> checkConnection() async {
    return _checkStatus();
  }

  Future<bool> _checkStatus() async {
    if (_simulatedOffline) {
      _statusController.add(false);
      return false;
    }

    try {
      final baseUrl = ApiService().baseUrl;
      final uri = Uri.parse('$baseUrl/health');
      final res = await http.get(uri).timeout(const Duration(seconds: 3));
      final online = res.statusCode == 200;
      if (_isOnline != online) {
        _isOnline = online;
        _statusController.add(_isOnline);
      }
      return online;
    } catch (_) {
      if (_isOnline) {
        _isOnline = false;
        _statusController.add(false);
      }
      return false;
    }
  }

  void dispose() {
    _pollTimer?.cancel();
    _statusController.close();
  }
}
