import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripModel {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double distance;
  final double duration;
  final String originAddress;
  final String destinationAddress;
  final List<LatLng> route;
  final String status;

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

  factory TripModel.fromMap(String id, Map<String, dynamic> map) {
    return TripModel(
      id: id,
      startTime: map['startTime'] is Timestamp
          ? (map['startTime'] as Timestamp).toDate()
          : DateTime.parse(map['startTime'].toString()),
      endTime: map['endTime'] is Timestamp
          ? (map['endTime'] as Timestamp).toDate()
          : map['endTime'] != null
              ? DateTime.parse(map['endTime'].toString())
              : null,
      distance: (map['distance'] ?? 0).toDouble(),
      duration: (map['duration'] ?? 0).toDouble(),
      originAddress: map['originAddress'] ?? '',
      destinationAddress: map['destinationAddress'] ?? '',
      route: (map['route'] as List<dynamic>? ?? [])
          .map(
            (p) => LatLng(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            ),
          )
          .toList(),
      status: map['status'] ?? 'finalizado',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'distance': distance,
      'duration': duration,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'route': route.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'status': status,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'distance': distance,
      'duration': duration,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'route': route.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'status': status,
    };
  }
}
