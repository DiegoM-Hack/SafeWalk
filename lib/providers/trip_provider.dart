import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/trip_model.dart';
import '../services/location_service.dart';
import '../services/trip_service.dart';

class TripProvider extends ChangeNotifier {
  final TripService _tripService = TripService();
  final LocationService _locationService = LocationService();

  final List<LatLng> _routePoints = [];
  DateTime? _startTime;
  double _distanceMeters = 0;
  String _originAddress = '';
  String _destinationAddress = '';
  bool _isTripActive = false;
  String? _errorMessage;

  List<LatLng> get routePoints => List.unmodifiable(_routePoints);

  bool get isTripActive => _isTripActive;

  double get distanceKm => _distanceMeters / 1000;

  String? get errorMessage => _errorMessage;

  Duration get elapsed {
    if (_startTime == null) return Duration.zero;
    return DateTime.now().difference(_startTime!);
  }

  /// Inicia un nuevo recorrido. Se debe llamar justo antes de empezar
  /// el seguimiento en vivo con LocationProvider.startTracking().
  void startTrip({
    required LatLng origin,
    required String originAddress,
    required String destinationAddress,
  }) {
    _routePoints
      ..clear()
      ..add(origin);
    _startTime = DateTime.now();
    _distanceMeters = 0;
    _originAddress = originAddress;
    _destinationAddress = destinationAddress;
    _isTripActive = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Agrega un nuevo punto al recorrido y acumula la distancia recorrida.
  /// Debe llamarse en cada actualización de posición mientras se rastrea.
  void addRoutePoint(LatLng point) {
    if (!_isTripActive) return;

    if (_routePoints.isNotEmpty) {
      final last = _routePoints.last;
      _distanceMeters += _locationService.distanceBetween(
        last.latitude,
        last.longitude,
        point.latitude,
        point.longitude,
      );
    }

    _routePoints.add(point);
    notifyListeners();
  }

  /// Finaliza el recorrido activo y lo guarda en Firestore
  /// (users/{uid}/trips).
  Future<void> finishTrip() async {
    if (!_isTripActive || _startTime == null) return;

    final trip = TripModel(
      id: '',
      startTime: _startTime!,
      endTime: DateTime.now(),
      distance: double.parse(distanceKm.toStringAsFixed(2)),
      duration: elapsed.inSeconds / 60,
      originAddress: _originAddress,
      destinationAddress: _destinationAddress,
      route: List.of(_routePoints),
      status: 'finalizado',
    );

    try {
      await _tripService.saveTrip(trip);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'No se pudo guardar el recorrido.';
    }

    _isTripActive = false;
    notifyListeners();
  }

  /// Descarta el recorrido activo sin guardarlo.
  void discardTrip() {
    _routePoints.clear();
    _startTime = null;
    _distanceMeters = 0;
    _isTripActive = false;
    notifyListeners();
  }
}
