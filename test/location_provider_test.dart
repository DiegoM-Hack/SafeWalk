import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safewalk/providers/location_provider.dart';
import 'package:safewalk/services/location_service.dart';

class FakeLocationService extends LocationService {
  @override
  Future<Position> getCurrentLocation() async {
    return Position(
      latitude: 20.6597,
      longitude: -103.3496,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }

  @override
  Stream<Position> getPositionStream({int distanceFilter = 5}) {
    return Stream.periodic(
      const Duration(milliseconds: 100),
      (_) => Position(
        latitude: 20.6597,
        longitude: -103.3496,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ),
    );
  }
}

void main() {
  test('startTracking adds a route point and enables tracking', () async {
    final provider = LocationProvider(service: FakeLocationService());

    await provider.loadCurrentLocation();
    provider.startTracking();

    expect(provider.isTracking, isTrue);
    expect(provider.routePoints, isNotEmpty);
    expect(provider.currentPosition, isNotNull);

    provider.stopTracking();
  });
}
