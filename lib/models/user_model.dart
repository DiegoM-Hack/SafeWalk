import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String provider;
  final bool isActive;
  final String? fcmToken;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.fcmToken,
    required this.provider,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"],
      name: map["name"],
      email: map["email"],
      phone: map["phone"],
      photoUrl: map["photoUrl"],
      fcmToken: map["fcmToken"],
      provider: map["provider"],
      isActive: map["isActive"],
      createdAt: map["createdAt"],
      updatedAt: map["updatedAt"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "phone": phone,
      "photoUrl": photoUrl,
      "fcmToken": fcmToken,
      "provider": provider,
      "isActive": isActive,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}