import 'package:cloud_firestore/cloud_firestore.dart';

class SOSService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendEmergencyAlert({
    required String userId,
    required double latitude,
    required double longitude,
    required String message,
  }) async {
    await _firestore.collection('emergency_alerts').add({
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'message': message,
      'status': 'sent',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}