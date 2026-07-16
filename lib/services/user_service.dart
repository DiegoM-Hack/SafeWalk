import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final String collection = "users";

  // NUEVO: colección raíz `phone_index/{telefonoNormalizado}` -> { uid }.
  // Permite resolver "¿este número de teléfono pertenece a un usuario de
  // SafeWalk?" sin tener que abrir lectura de todo `users` a cualquiera.
  // Cada usuario solo puede escribir su propia entrada (ver firestore.rules).
  final String _phoneIndexCollection = "phone_index";

  Future<void> createUser(UserModel user) async {

    await _firestore
        .collection(collection)
        .doc(user.uid)
        .set(user.toMap());

    await setPhoneIndex(phone: user.phone, uid: user.uid);

  }

  Future<bool> exists(String uid) async {

    final doc = await _firestore
        .collection(collection)
        .doc(uid)
        .get();

    return doc.exists;

  }

  Future<UserModel?> getUser(String uid) async {

    final doc = await _firestore
        .collection(collection)
        .doc(uid)
        .get();

    if(!doc.exists){
      return null;
    }

    return UserModel.fromMap(doc.data()!);

  }

  /// Normaliza un teléfono para usarlo como llave del índice (quita
  /// espacios, guiones y paréntesis). No hace validación de formato E.164
  /// completa a propósito, para no bloquear números ya guardados con
  /// formatos distintos.
  String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-()]'), '');
  }

  /// Registra/actualiza la relación teléfono -> uid del usuario autenticado.
  /// Se llama al registrarse y cada vez que el usuario actualiza su teléfono
  /// desde el perfil.
  Future<void> setPhoneIndex({required String phone, required String uid}) async {
    final normalized = normalizePhone(phone);
    if (normalized.isEmpty) return;

    await _firestore.collection(_phoneIndexCollection).doc(normalized).set({
      'uid': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Busca si un teléfono (de un contacto de emergencia, por ejemplo)
  /// corresponde a un usuario registrado en SafeWalk. Devuelve el uid o
  /// null si no se encuentra.
  Future<String?> findUidByPhone(String phone) async {
    final normalized = normalizePhone(phone);
    if (normalized.isEmpty) return null;

    final doc = await _firestore
        .collection(_phoneIndexCollection)
        .doc(normalized)
        .get();

    if (!doc.exists) return null;

    return doc.data()?['uid'] as String?;
  }

  /// Guarda/actualiza el token FCM del dispositivo actual, para poder
  /// enviarle notificaciones push (ej. solicitudes de ubicación compartida).
  Future<void> updateFcmToken({required String uid, required String token}) async {
    await _firestore.collection(collection).doc(uid).update({
      'fcmToken': token,
    });
  }

}
