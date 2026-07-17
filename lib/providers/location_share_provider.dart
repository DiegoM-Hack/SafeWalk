import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/location_share_model.dart';
import '../services/location_service.dart';
import '../services/location_share_service.dart';

/// Maneja todo el estado del flujo "Compartir ubicación en tiempo real":
/// - Solicitudes entrantes pendientes (para mostrar el diálogo aceptar/rechazar).
/// - Sesiones activas que otros comparten conmigo.
/// - La sesión que YO estoy compartiendo actualmente (tracking + publish).
class LocationShareProvider extends ChangeNotifier {
  LocationShareProvider({
    LocationShareService? service,
    LocationService? locationService,
  })  : _service = service ?? LocationShareService(),
        _locationService = locationService ?? LocationService() {
    // Igual que AuthProvider/ContactProvider: reacciona a login/logout
    // para (re)iniciar o cancelar los listeners de Firestore.
    FirebaseAuth.instance.authStateChanges().listen(_handleAuthChanged);
  }

  final LocationShareService _service;
  final LocationService _locationService;

  StreamSubscription<List<LocationShareModel>>? _pendingSub;
  StreamSubscription<List<LocationShareModel>>? _activeIncomingSub;
  StreamSubscription<LocationShareModel>? _outgoingShareSub;
  StreamSubscription<Position>? _positionSub;

  List<LocationShareModel> _pendingRequests = [];
  List<LocationShareModel> _incomingActive = [];

  /// Sesión que el usuario actual está compartiendo en este momento (si hay).
  LocationShareModel? _outgoingShare;
  bool _isSendingRequest = false;
  String? _errorMessage;

  List<LocationShareModel> get pendingRequests => _pendingRequests;
  List<LocationShareModel> get incomingActive => _incomingActive;
  LocationShareModel? get outgoingShare => _outgoingShare;
  bool get isSharing => _outgoingShare?.isActive ?? false;
  bool get isSendingRequest => _isSendingRequest;
  String? get errorMessage => _errorMessage;

  void _handleAuthChanged(User? user) {
    _pendingSub?.cancel();
    _activeIncomingSub?.cancel();

    if (user == null) {
      _pendingRequests = [];
      _incomingActive = [];
      _stopOwnSharing(updateRemote: false);
      notifyListeners();
      return;
    }

    _pendingSub = _service.watchIncomingPending().listen((requests) {
      _pendingRequests = requests;
      notifyListeners();
    });

    _activeIncomingSub = _service.watchIncomingActive().listen((active) {
      _incomingActive = active;
      notifyListeners();
    });
  }

  /// Paso 1: enviar la solicitud a un contacto ya vinculado a SafeWalk.
  Future<String?> sendRequest({
    required String toUid,
    required String fromName,
    required int durationMinutes,
  }) async {
    _isSendingRequest = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final shareId = await _service.sendRequest(
        toUid: toUid,
        fromName: fromName,
        durationMinutes: durationMinutes,
      );

      _watchOwnShare(shareId);
      return shareId;
    } catch (_) {
      _errorMessage = 'No se pudo enviar la solicitud de ubicación.';
      return null;
    } finally {
      _isSendingRequest = false;
      notifyListeners();
    }
  }

  /// Paso 2/3: B responde una solicitud pendiente.
  Future<void> respondToRequest({
    required String shareId,
    required bool accept,
  }) async {
    try {
      await _service.respondToRequest(shareId: shareId, accept: accept);
    } catch (_) {
      _errorMessage = 'No se pudo responder la solicitud.';
      notifyListeners();
    }
  }

  /// B (o A) finaliza el seguimiento de una sesión activa.
  Future<void> stopFollowing(String shareId) async {
    try {
      await _service.stopSharing(shareId);
    } catch (_) {
      _errorMessage = 'No se pudo detener la sesión.';
      notifyListeners();
    }
  }

  /// Empieza a escuchar la sesión que YO envié, y arranca/detiene el
  /// tracking de GPS automáticamente según su estado.
  void _watchOwnShare(String shareId) {
    _outgoingShareSub?.cancel();
    _outgoingShareSub = _service.watchShare(shareId).listen((share) {
      _outgoingShare = share;
      notifyListeners();

      switch (share.status) {
        case LocationShareStatus.active:
          _startPublishingPosition(share.id);
          break;
        case LocationShareStatus.rejected:
        case LocationShareStatus.stopped:
        case LocationShareStatus.expired:
          _stopOwnSharing(updateRemote: false);
          break;
        case LocationShareStatus.pending:
          break;
      }

      if (DateTime.now().isAfter(share.expiresAt) && share.isActive) {
        _service.markExpired(share.id);
      }
    });
  }

  void _startPublishingPosition(String shareId) {
    if (_positionSub != null) return; // ya está publicando

    _positionSub = _locationService.getPositionStream().listen((position) {
      _service.pushPosition(shareId, LatLng(position.latitude, position.longitude));
    });
  }

  /// Paso 4: el usuario A presiona "Dejar de compartir".
  Future<void> stopSharingMine() async {
    final share = _outgoingShare;
    if (share != null) {
      await _service.stopSharing(share.id);
    }
    _stopOwnSharing(updateRemote: false);
  }

  void _stopOwnSharing({required bool updateRemote}) {
    _positionSub?.cancel();
    _positionSub = null;
    _outgoingShareSub?.cancel();
    _outgoingShareSub = null;
    _outgoingShare = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pendingSub?.cancel();
    _activeIncomingSub?.cancel();
    _outgoingShareSub?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }
}
