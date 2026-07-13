import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Verifica que el GPS esté activo y que la app tenga permiso de
  /// ubicación. Lanza una excepción con un mensaje claro si algo falla.
  Future<void> ensurePermission() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      throw Exception('El GPS está desactivado. Actívalo para continuar.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Se necesita permiso de ubicación para usar el mapa.');
    }
  }

  Future<Position> getCurrentLocation() async {
    await ensurePermission();

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Emite la posición del usuario cada vez que se mueve al menos
  /// [distanceFilter] metros. Se usa para el seguimiento en vivo.
  Stream<Position> getPositionStream({int distanceFilter = 5}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Distancia en metros entre dos coordenadas (fórmula de Haversine).
  double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
