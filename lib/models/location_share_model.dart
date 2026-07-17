import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Estado de una sesión de "compartir ubicación en tiempo real".
enum LocationShareStatus { pending, active, rejected, stopped, expired }

LocationShareStatus locationShareStatusFromString(String value) {
  return LocationShareStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => LocationShareStatus.pending,
  );
}

/// Representa un documento de la colección raíz `location_shares/{shareId}`.
///
/// `fromUid` es quien comparte su ubicación, `toUid` es quien la recibe.
/// El ciclo de vida es: pending -> active -> (stopped | expired)
///                                 \-> rejected
class LocationShareModel {
  final String id;
  final String fromUid;
  final String fromName;
  final String toUid;
  final LocationShareStatus status;
  final int durationMinutes;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;
  // Última posición conocida, duplicada aquí (además de la subcolección
  // `positions`) para poder pintar un marcador o una lista de sesiones
  // activas sin tener que abrir la subcolección.
  final double? lastLat;
  final double? lastLng;

  LocationShareModel({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.status,
    required this.durationMinutes,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
    this.lastLat,
    this.lastLng,
  });

  LatLng? get lastPosition =>
      (lastLat != null && lastLng != null) ? LatLng(lastLat!, lastLng!) : null;

  bool get isPending => status == LocationShareStatus.pending;
  bool get isActive => status == LocationShareStatus.active;

  factory LocationShareModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LocationShareModel(
      id: doc.id,
      fromUid: data['fromUid'] ?? '',
      fromName: data['fromName'] ?? 'Un contacto',
      toUid: data['toUid'] ?? '',
      status: locationShareStatusFromString(data['status'] ?? 'pending'),
      durationMinutes: (data['durationMinutes'] ?? 30) as int,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(minutes: 30)),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
      lastLat: (data['lastLat'] as num?)?.toDouble(),
      lastLng: (data['lastLng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    final now = DateTime.now();
    return {
      'fromUid': fromUid,
      'fromName': fromName,
      'toUid': toUid,
      'status': LocationShareStatus.pending.name,
      'durationMinutes': durationMinutes,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(now.add(Duration(minutes: durationMinutes))),
      'respondedAt': null,
      'lastLat': null,
      'lastLng': null,
    };
  }
}
