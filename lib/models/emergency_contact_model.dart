import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContactModel {
  final String id;
  final String name;
  final String phone;
  final String relationship;
  final DateTime? createdAt;

  EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    this.createdAt,
  });

  factory EmergencyContactModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EmergencyContactModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      relationship: data['relationship'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory EmergencyContactModel.fromMap(Map<String, dynamic> map) {
    return EmergencyContactModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }

  EmergencyContactModel copyWith({
    String? name,
    String? phone,
    String? relationship,
  }) {
    return EmergencyContactModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      createdAt: createdAt,
    );
  }
}