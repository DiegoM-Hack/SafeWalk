import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  static const String text = "text";
  static const String location = "location";
  static const String system = "system";

  final String id;
  final String alertId;
  final String senderUid;
  final String? message;
  final String type; // 'text', 'location', 'system'
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  ChatMessageModel({
    required this.id,
    required this.alertId,
    required this.senderUid,
    this.message,
    required this.type,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory ChatMessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ChatMessageModel(
      id: doc.id,
      alertId: doc.id,
      senderUid: data['senderUid'] ?? '',
      message: data['message'] as String?,
      type: data['type'] ?? 'text',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory ChatMessageModel.fromMap(String alertId, Map<String, dynamic> data) {
    return ChatMessageModel(
      id: data['id'] ?? '',
      alertId: alertId,
      senderUid: data['senderUid'] ?? '',
      message: data['message'] as String?,
      type: data['type'] ?? 'text',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'message': message,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  ChatMessageModel copyWith({
  String? message,
  String? type,
  double? latitude,
  double? longitude,
}) {
  return ChatMessageModel(
    id: id,
    alertId: alertId,
    senderUid: senderUid,
    message: message ?? this.message,
    type: type ?? this.type,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    createdAt: createdAt,
  );
}
}

