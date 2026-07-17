import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String receiverUid;
  final String senderUid;
  final String alertId;
  final String title;
  final String body;
  final String status;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.receiverUid,
    required this.senderUid,
    required this.alertId,
    required this.title,
    required this.body,
    required this.status,
    this.createdAt,
  });

  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      id: doc.id,
      receiverUid: data["receiverUid"] ?? "",
      senderUid: data["senderUid"] ?? "",
      alertId: data["alertId"] ?? "",
      title: data["title"] ?? "",
      body: data["body"] ?? "",
      status: data["status"] ?? "pending",
      createdAt: (data["createdAt"] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "receiverUid": receiverUid,
      "senderUid": senderUid,
      "alertId": alertId,
      "title": title,
      "body": body,
      "status": status,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }
}