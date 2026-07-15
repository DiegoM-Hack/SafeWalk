import 'package:cloud_firestore/cloud_firestore.dart';

class SOSService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> sendEmergencyAlert({
    required String userId,
    required double latitude,
    required double longitude,
    required String message,
  }) async {
    final doc = await _firestore.collection('emergency_alerts').add({
      'uid': userId,
      'latitude': latitude,
      'longitude': longitude,
      'message': message,
      'status': 'active',
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
    await _firestore.collection('emergency_alerts').doc(alertId).update({
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> finishAlert(String alertId) async {
    await _firestore.collection('emergency_alerts').doc(alertId).update({
      'status': 'finished',
      'finishedAt': FieldValue.serverTimestamp(),
    });
  }
}
