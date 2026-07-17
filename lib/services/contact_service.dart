import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/emergency_contact_model.dart';

class ContactService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// users/{uid}/contacts
  CollectionReference<Map<String, dynamic>> get _contactsRef {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    return _db
        .collection('users')
        .doc(uid)
        .collection('contacts');
  }

  /// Obtiene todos los contactos del usuario en tiempo real.
  Stream<List<EmergencyContactModel>> getContacts() {
    return _contactsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => EmergencyContactModel.fromDocument(doc),
              )
              .toList(),
        );
  }

  Future<void> addContact(EmergencyContactModel contact) async {
    await _contactsRef.add(contact.toFirestore());
  }

  Future<void> updateContact(EmergencyContactModel contact) async {
    await _contactsRef.doc(contact.id).update(contact.toFirestore());
  }

  Future<void> setLinkedUid(String contactId, String? linkedUid) async {
    await _contactsRef.doc(contactId).update({'linkedUid': linkedUid});
  }

  /// Elimina un contacto.
  Future<void> deleteContact(String contactId) async {
    await _contactsRef.doc(contactId).delete();
  }
}
