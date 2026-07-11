import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripModel {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double distance; // en kilómetros
  final double duration; // en minutos
  final String originAddress;
  final String destinationAddress;
  final List<LatLng> route;
  final String status; // 'activo' | 'finalizado'

  TripModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.distance,
    required this.duration,
    required this.originAddress,
    required this.destinationAddress,
    required this.route,
    required this.status,
  });

  /// Crea el modelo a partir de un DocumentSnapshot de Firestore.
  factory TripModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TripModel(
      id: doc.id,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      distance: (data['distance'] ?? 0).toDouble(),
      duration: (data['duration'] ?? 0).toDouble(),
      originAddress: data['originAddress'] ?? '',
      destinationAddress: data['destinationAddress'] ?? '',
      route: (data['route'] as List<dynamic>? ?? [])
          .map(
            (p) => LatLng(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            ),
          )
          .toList(),
      status: data['status'] ?? 'finalizado',
    );
  }

  /// Para guardar/actualizar en Firestore (no incluye el id,
  /// ya que ese lo maneja el documento mismo).
  Map<String, dynamic> toFirestore() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'distance': distance,
      'duration': duration,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'route':
          route.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'status': status,
    };
  }
}
