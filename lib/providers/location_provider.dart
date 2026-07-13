import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  LocationProvider({LocationService? service})
      : _locationService = service ?? LocationService();

  final LocationService _locationService;

  StreamSubscription<Position>? _positionSubscription;

  final List<LatLng> _routePoints = [];
  LatLng? _currentPosition;
  bool _isTracking = false;
  bool _isLoading = false;
  String? _errorMessage;

  LatLng? get currentPosition => _currentPosition;

  bool get isTracking => _isTracking;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<LatLng> get routePoints => List.unmodifiable(_routePoints);

  /// Obtiene la ubicación actual una sola vez (por ejemplo, al abrir el mapa).
  Future<void> loadCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      _currentPosition = LatLng(position.latitude, position.longitude);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Empieza a escuchar la ubicación en tiempo real. [onPositionUpdate]
  /// se llama en cada actualización (útil para ir dibujando el recorrido).
  void startTracking({void Function(LatLng position)? onPositionUpdate}) {
    _isTracking = true;
    _routePoints.clear();
    if (_currentPosition != null) {
      _routePoints.add(_currentPosition!);
    }
    notifyListeners();

    _positionSubscription?.cancel();
    _positionSubscription = _locationService.getPositionStream().listen(
      (position) {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _routePoints.add(_currentPosition!);
        onPositionUpdate?.call(_currentPosition!);
        notifyListeners();
      },
      onError: (_) {
        _errorMessage = 'Se perdió la señal de ubicación.';
        notifyListeners();
      },
    );
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
