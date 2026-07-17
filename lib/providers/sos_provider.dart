import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/sos_service.dart';

class SOSProvider extends ChangeNotifier {
  final SOSService _sosService = SOSService();

  bool _isLoading = false;
  String? _errorMessage;

  String? _currentAlertId;
  bool _isEmergencyActive = false;

  bool get isLoading => _isLoading;

  bool get isEmergencyActive => _isEmergencyActive;

  bool get hasActiveSOS => _currentAlertId != null;

  String? get currentAlertId => _currentAlertId;

  String? get errorMessage => _errorMessage;

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
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);

      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    if (_currentAlertId == null) return false;

    try {
      await _sosService.updateLocation(
        alertId: _currentAlertId!,
        latitude: latitude,
        longitude: longitude,
      );

      return true;
    } catch (e) {
      debugPrint(e.toString());

      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<bool> finishSOS() async {
    if (_currentAlertId == null) return true;

    try {
      await _sosService.finishAlert(_currentAlertId!);

      _currentAlertId = null;
      _isEmergencyActive = false;
      _errorMessage = null;

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint("========== ERROR AL FINALIZAR SOS ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);
      debugPrint("=============================================");

      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelSOS() async {
    if (_currentAlertId == null) return false;

    try {
      await _sosService.cancelAlert(_currentAlertId!);

      _currentAlertId = null;
      _isEmergencyActive = false;
      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(e.toString());

      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenAlert(
    String alertId) {
  return _sosService.listenAlert(alertId);
}

Future<void> acceptAlert(String alertId) async {
  await _sosService.acceptAlert(alertId);
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