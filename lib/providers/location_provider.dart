import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  LocationProvider({LocationService? service}) : _service = service ?? LocationService();

  final LocationService _service;
  Position? _currentPosition;
  final List<Position> _routePoints = [];
  StreamSubscription<Position>? _positionSubscription;
  bool _isTracking = false;

  Position? get currentPosition => _currentPosition;
  List<Position> get routePoints => List.unmodifiable(_routePoints);
  bool get isTracking => _isTracking;

  Future<void> startTracking() async {
    try {
      final initialPosition = await _service.getCurrentLocation();
      _currentPosition = initialPosition;
      _routePoints.add(initialPosition);
      _isTracking = true;
      notifyListeners();

      _positionSubscription?.cancel();
      _positionSubscription = _service.getPositionStream().listen((position) {
        _currentPosition = position;
        _routePoints.add(position);
        notifyListeners();
      });
    } catch (_) {
      _isTracking = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
