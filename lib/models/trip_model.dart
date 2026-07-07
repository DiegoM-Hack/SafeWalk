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
}