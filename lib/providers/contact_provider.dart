import 'dart:async';

import 'package:flutter/material.dart';

import '../models/emergency_contact_model.dart';
import '../services/contact_service.dart';

class ContactProvider extends ChangeNotifier {
  final ContactService _contactService = ContactService();

  StreamSubscription<List<EmergencyContactModel>>? _subscription;

  List<EmergencyContactModel> _contacts = [];
  List<EmergencyContactModel> _allContacts = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<EmergencyContactModel> get contacts => _contacts;

  /// Contactos que tienen cuenta en SafeWalk
  List<EmergencyContactModel> get linkedContacts =>
      _allContacts.where((c) => c.isLinkedToSafeWalk).toList();

  int get totalContacts => _allContacts.length;

  int get linkedContactsCount => linkedContacts.length;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  /// Comienza a escuchar los contactos en tiempo real.
  void listenToContacts() {
    _setLoading(true);

    _subscription?.cancel();

    _subscription = _contactService.getContacts().listen(
      (contacts) {
        _allContacts = contacts;
        _contacts = contacts;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (error) {
        debugPrint(error.toString());

        _errorMessage = "No se pudieron cargar los contactos.";
        _setLoading(false);
      },
    );
  }

  Future<bool> addContact({
    required String name,
    required String phone,
    required String email,
    required String relationship,
  }) async {
    _setLoading(true);

    try {
      final newContact = EmergencyContactModel(
        id: '',
        name: name,
        phone: phone,
        email: email,
        relationship: relationship,
        createdAt: DateTime.now(),
      );

      await _contactService.addContact(newContact);

      _errorMessage = null;
      return true;
    } catch (e) {
      debugPrint(e.toString());

      _errorMessage = "No se pudo agregar el contacto.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateContact(EmergencyContactModel contact) async {
    _setLoading(true);

    try {
      await _contactService.updateContact(contact);

      _errorMessage = null;
      return true;
    } catch (e) {
      debugPrint(e.toString());

      _errorMessage = "No se pudo actualizar el contacto.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteContact(String contactId) async {
    _setLoading(true);

    try {
      await _contactService.deleteContact(contactId);

      _errorMessage = null;
      return true;
    } catch (e) {
      debugPrint(e.toString());

      _errorMessage = "No se pudo eliminar el contacto.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Busca contactos en memoria.
  void searchContacts(String query) {
    if (query.trim().isEmpty) {
      _contacts = List.from(_allContacts);
      notifyListeners();
      return;
    }

    final q = query.toLowerCase();

    _contacts = _allContacts.where((contact) {
      return contact.name.toLowerCase().contains(q) ||
          contact.phone.contains(query) ||
          contact.email.toLowerCase().contains(q) ||
          contact.relationship.toLowerCase().contains(q);
    }).toList();

    notifyListeners();
  }

  /// Obtiene un contacto mediante el UID vinculado.
  EmergencyContactModel? getContactByUid(String uid) {
    try {
      return _allContacts.firstWhere(
        (contact) => contact.linkedUid == uid,
      );
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}