import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection("notifications");

  Future<void> createNotification({
    required String receiverUid,
    required String senderUid,
    required String title,
    required String body,
    required String type,
    String? alertId,
  }) async {
    await _notifications.add({
      "receiverUid": receiverUid,
      "senderUid": senderUid,
      "title": title,
      "body": body,
      "type": type,
      "alertId": alertId,
      "read": false,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getNotifications(String uid) {
    return _notifications
        .where("receiverUid", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<void> markAsRead(String id) async {

    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(id)
        .update({

          "status": "accepted",

          "readAt": FieldValue.serverTimestamp(),

        });
  }

  Future<void> deleteNotification(
      String notificationId) async {
    await _notifications
        .doc(notificationId)
        .delete();
  }

  Future<void> rejectNotification(String id) async {
  await FirebaseFirestore.instance
      .collection("notifications")
      .doc(id)
      .update({
    "status": "rejected",
    "updatedAt": FieldValue.serverTimestamp(),
  });
}
}