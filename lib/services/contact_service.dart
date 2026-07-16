import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/emergency_contact_model.dart';

class ContactService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Referencia a la subcolección de contactos del usuario autenticado.
  /// users/{uid}/contacts
  CollectionReference<Map<String, dynamic>> get _contactsRef {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    return _db.collection('users').doc(uid).collection('contacts');
  }

  /// Stream en tiempo real de los contactos del usuario, ordenados
  /// por fecha de creación descendente.
  Stream<List<EmergencyContactModel>> getContacts() {
    return _contactsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyContactModel.fromDocument(doc))
            .toList());
  }

  Future<void> addContact(EmergencyContactModel contact) async {
    await _contactsRef.add(contact.toFirestore());
  }

  Future<void> updateContact(EmergencyContactModel contact) async {
    await _contactsRef.doc(contact.id).update(contact.toFirestore());
  }

  Future<void> deleteContact(String contactId) async {
    await _contactsRef.doc(contactId).delete();
  }

  /// NUEVO: guarda el uid de SafeWalk encontrado para este contacto
  /// (o lo limpia si se pasa null), sin tocar el resto de sus campos.
  Future<void> setLinkedUid(String contactId, String? uid) async {
    await _contactsRef.doc(contactId).update({'linkedUid': uid});
  }
}
