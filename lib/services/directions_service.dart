import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';

class DirectionsService {
  /// Consulta la Directions API de Google para trazar una ruta a pie
  /// entre [origin] y [destination], y devuelve la lista de puntos
  /// (ya decodificados) para dibujar el polyline en el mapa.
  Future<List<LatLng>> getWalkingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=walking'
      '&key=${AppConfig.googleMapsApiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('No se pudo conectar con el servicio de rutas.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['status'] != 'OK') {
      throw Exception(
        data['error_message'] ?? 'No se encontró una ruta (${data['status']}).',
      );
    }

    final routes = data['routes'] as List<dynamic>;
    final overviewPolyline =
        routes.first['overview_polyline']['points'] as String;

    final decoded = PolylinePoints.decodePolyline(overviewPolyline);

    return decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }
}
