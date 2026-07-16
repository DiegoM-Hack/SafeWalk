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

  /// Busca un usuario registrado en SafeWalk mediante su teléfono.
  /// Devuelve el UID si existe, caso contrario null.
  /// Esta búsqueda se realiza contra el índice de teléfonos en Firestore.
  Future<String?> findUidByPhone(String phone) async {
    // Normaliza el teléfono (elimina espacios, guiones, paréntesis)
    final normalized = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (normalized.isEmpty) return null;

    try {
      final doc = await _db
          .collection('phone_index')
          .doc(normalized)
          .get();

      if (!doc.exists) return null;

      return doc.data()?['uid'] as String?;
    } catch (e) {
      // Si falla la búsqueda, simplemente retorna null
      return null;
    }
  }

  /// Agrega un contacto.
  /// La vinculación con un usuario de SafeWalk (linkedUid) se realiza
  /// manualmente mediante linkContactToSafeWalkUser en el provider.
  Future<void> addContact(EmergencyContactModel contact) async {
    await _contactsRef.add(contact.toFirestore());
  }

  /// Actualiza un contacto.
  /// La vinculación con un usuario de SafeWalk (linkedUid) se realiza
  /// manualmente mediante linkContactToSafeWalkUser en el provider.
  Future<void> updateContact(EmergencyContactModel contact) async {
    await _contactsRef
        .doc(contact.id)
        .update(contact.toFirestore());
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

  /// Actualiza el linkedUid de un contacto específico.
  /// Se utiliza cuando se vincula manualmente un contacto a un usuario de SafeWalk.
  Future<void> setLinkedUid(String contactId, String? uid) async {
    await _contactsRef.doc(contactId).update({
      'linkedUid': uid,
    });
  }
}