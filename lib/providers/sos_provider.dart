import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/sos_service.dart';

class SOSProvider extends ChangeNotifier {
  final SOSService _sosService = SOSService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<bool> sendSOS({
    required String userId,
    required double latitude,
    required double longitude,
    required String message,
  }) async {
    _setLoading(true);

    try {
      await _sosService.sendEmergencyAlert(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        message: message,
      );

      _errorMessage = null;
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}