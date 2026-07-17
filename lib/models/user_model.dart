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
  // NUEVO: token FCM del dispositivo actual del usuario. Se usa para poder
  // enviarle una notificación push (por ejemplo, una solicitud de
  // "compartir ubicación en tiempo real"). Puede ser null si el usuario
  // nunca dio permiso de notificaciones o aún no se ha sincronizado.


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
      "fcmToken": fcmToken,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    bool? isActive,
    Timestamp? updatedAt,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
