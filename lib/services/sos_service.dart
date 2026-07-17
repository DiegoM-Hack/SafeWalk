import 'package:cloud_firestore/cloud_firestore.dart';

class SOSService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collection = "emergency_alerts";

  static const String pending = "pending";
  static const String active = "active";
  static const String finished = "finished";
  static const String cancelled = "cancelled";
  static const String accepted = "accepted";

  Future<String> sendEmergencyAlert({
    required String userId,
    required double latitude,
    required double longitude,
    required String message,
    String? userName,
    String? userPhoto,
  }) async {
    final doc = await _firestore.collection(collection).add({
      'userId': userId,
      'userName': userName ?? 'Usuario en emergencia',
      'userPhoto': userPhoto ?? '',
      'latitude': latitude,
      'longitude': longitude,
      'message': message,
      'status': pending,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> updateLocation({
    required String alertId,
    required double latitude,
    required double longitude,
  }) async {
    await _firestore.collection(collection).doc(alertId).update({
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> activateAlert(String alertId) async {
    await _firestore.collection(collection).doc(alertId).update({
      'status': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> finishAlert(String alertId) async {
    await _firestore.collection(collection).doc(alertId).update({
      'status': finished,
      'finishedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelAlert(String alertId) async {
    await _firestore.collection(collection).doc(alertId).update({
      'status': cancelled,
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getAlert(
    String alertId,
  ) async {
    return await _firestore.collection(collection).doc(alertId).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenAlert(String alertId) {
    return _firestore.collection("emergency_alerts").doc(alertId).snapshots();
  }

  Future<void> acceptAlert(String alertId) async {
    await _firestore.collection("emergency_alerts").doc(alertId).update({
      "status": accepted,
      "acceptedAt": FieldValue.serverTimestamp(),
    });
  }
}
