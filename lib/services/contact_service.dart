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

  /// Busca un usuario registrado en SafeWalk mediante su correo.
  /// Devuelve el UID si existe, caso contrario null.
  Future<String?> findUserByEmail(String email) async {
    final query = await _db
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return query.docs.first.id;
  }

  /// Agrega un contacto.
  /// Si el correo pertenece a un usuario registrado,
  /// se guarda automáticamente el linkedUid.
  Future<void> addContact(EmergencyContactModel contact) async {
    final linkedUid = await findUserByEmail(contact.email);

    final newContact = contact.copyWith(
      linkedUid: linkedUid,
    );

    await _contactsRef.add(newContact.toFirestore());
  }

  /// Actualiza un contacto.
  /// Si cambia el correo también se vuelve a verificar
  /// si pertenece a un usuario registrado.
  Future<void> updateContact(EmergencyContactModel contact) async {
    final linkedUid = await findUserByEmail(contact.email);

    final updatedContact = contact.copyWith(
      linkedUid: linkedUid,
    );

    await _contactsRef
        .doc(contact.id)
        .update(updatedContact.toFirestore());
  }

  /// Elimina un contacto.
  Future<void> deleteContact(String contactId) async {
    await _contactsRef.doc(contactId).delete();
  }

  /// Devuelve únicamente los contactos que tienen cuenta
  /// en SafeWalk (linkedUid != null).
  Future<List<EmergencyContactModel>> getLinkedContacts() async {
    final snapshot = await _contactsRef.get();

    return snapshot.docs
        .map((doc) => EmergencyContactModel.fromDocument(doc))
        .where((contact) => contact.linkedUid != null)
        .toList();
  }
}