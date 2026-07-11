import 'dart:async';

import 'package:flutter/material.dart';

import '../models/emergency_contact_model.dart';
import '../services/contact_service.dart';

class ContactProvider extends ChangeNotifier {
  final ContactService _contactService = ContactService();

  StreamSubscription<List<EmergencyContactModel>>? _subscription;

  List<EmergencyContactModel> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EmergencyContactModel> get contacts => _contacts;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void listenToContacts() {
    _setLoading(true);

    _subscription?.cancel();
    _subscription = _contactService.getContacts().listen(
      (contacts) {
        _contacts = contacts;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = "No se pudieron cargar los contactos.";
        _setLoading(false);
      },
    );
  }

  Future<bool> addContact({
    required String name,
    required String phone,
    required String relationship,
  }) async {
    try {
      final newContact = EmergencyContactModel(
        id: '',
        name: name,
        phone: phone,
        relationship: relationship,
      );

      await _contactService.addContact(newContact);
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = "No se pudo agregar el contacto.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateContact(EmergencyContactModel contact) async {
    try {
      await _contactService.updateContact(contact);
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = "No se pudo actualizar el contacto.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteContact(String contactId) async {
    try {
      await _contactService.deleteContact(contactId);
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = "No se pudo eliminar el contacto.";
      notifyListeners();
      return false;
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