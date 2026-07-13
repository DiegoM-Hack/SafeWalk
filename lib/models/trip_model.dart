import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double distance;
  final double duration;

  TripModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.duration,
  });

  factory TripModel.fromMap(String id, Map<String, dynamic> map) {
    return TripModel(
      id: id,
      startTime: map['startTime'] is Timestamp
          ? (map['startTime'] as Timestamp).toDate()
          : DateTime.parse(map['startTime'].toString()),
      endTime: map['endTime'] is Timestamp
          ? (map['endTime'] as Timestamp).toDate()
          : DateTime.parse(map['endTime'].toString()),
      distance: (map['distance'] as num).toDouble(),
      duration: (map['duration'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'distance': distance,
      'duration': duration,
    };
  }
}