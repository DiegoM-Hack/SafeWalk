import 'package:flutter/foundation.dart';

import '../services/sos_service.dart';

class SOSProvider extends ChangeNotifier {
  final SOSService _sosService = SOSService();

  bool _isLoading = false;
  String? _errorMessage;

  String? _currentAlertId;
  bool _isEmergencyActive = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isEmergencyActive => _isEmergencyActive;
  String? get currentAlertId => _currentAlertId;

  Future<bool> sendSOS({
    required String userId,
    required double latitude,
    required double longitude,
    required String message,
  }) async {
    _setLoading(true);

    try {
      _currentAlertId = await _sosService.sendEmergencyAlert(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        message: message,
      );

      _isEmergencyActive = true;
      _errorMessage = null;

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint("========== ERROR SOS ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);
      debugPrint("================================");

      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    if (_currentAlertId == null) return;

    await _sosService.updateLocation(
      alertId: _currentAlertId!,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> finishSOS() async {
    if (_currentAlertId == null) return;

    await _sosService.finishAlert(_currentAlertId!);

    _currentAlertId = null;
    _isEmergencyActive = false;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
