import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContactModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String relationship;
  final String? linkedUid;
  final DateTime? createdAt;
<<<<<<< HEAD
  // NUEVO: uid del usuario de SafeWalk al que corresponde este contacto,
  // si es que este contacto también tiene cuenta en la app (se resuelve
  // buscando su teléfono en el índice de usuarios). Si es null, el
  // contacto es solo información de agenda y no se le puede enviar una
  // solicitud de "compartir ubicación en tiempo real".
  final String? linkedUid;
=======
  bool get isLinkedToSafeWalk => linkedUid != null;
>>>>>>> main

  EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.relationship,
    this.linkedUid,
    this.createdAt,
    this.linkedUid,
  });

  /// Si el contacto ya está vinculado a una cuenta de SafeWalk.
  bool get isSafeWalkUser => linkedUid != null && linkedUid!.isNotEmpty;

  /// Crea el modelo a partir de un DocumentSnapshot de Firestore.
  factory EmergencyContactModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return EmergencyContactModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      relationship: data['relationship'] ?? '',
      linkedUid: data['linkedUid'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      linkedUid: data['linkedUid'] as String?,
    );
  }

  factory EmergencyContactModel.fromMap(Map<String, dynamic> map) {
    return EmergencyContactModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      relationship: map['relationship'] ?? '',
      linkedUid: map['linkedUid'] as String?,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      linkedUid: map['linkedUid'] as String?,
    );
  }

  /// Para guardar/actualizar en Firestore (no incluye el id,
  /// ya que ese lo maneja el documento mismo).
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
      'linkedUid': linkedUid,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'linkedUid': linkedUid,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
      'linkedUid': linkedUid,
      'createdAt': createdAt,
      'linkedUid': linkedUid,
    };
  }

  EmergencyContactModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? relationship,
    String? linkedUid,
  }) {
    return EmergencyContactModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      linkedUid: linkedUid ?? this.linkedUid,
      createdAt: createdAt,
      linkedUid: linkedUid ?? this.linkedUid,
    );
  }
}
