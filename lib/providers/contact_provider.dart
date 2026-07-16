import 'dart:async';

import 'package:flutter/material.dart';

import '../models/emergency_contact_model.dart';
import '../services/contact_service.dart';
import '../services/user_service.dart';

class ContactProvider extends ChangeNotifier {
  final ContactService _contactService = ContactService();
  // NUEVO: para resolver si el teléfono de un contacto corresponde a un
  // usuario real de SafeWalk (y así poder compartirle la ubicación).
  final UserService _userService = UserService();

  StreamSubscription<List<EmergencyContactModel>>? _subscription;

  List<EmergencyContactModel> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // uid de contacto -> true/false mientras se resuelve la búsqueda, para
  // poder mostrar un pequeño loading por fila en la UI si se desea.
  final Set<String> _linkingContactIds = {};

  List<EmergencyContactModel> get contacts => _contacts;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool isLinking(String contactId) => _linkingContactIds.contains(contactId);

  /// Se llama una vez el usuario está autenticado (por ejemplo, desde
  /// el HomeScreen o justo después del login) para empezar a escuchar
  /// los contactos en tiempo real.
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
    required String email,
    required String relationship,
  }) async {
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

  /// NUEVO: busca si el teléfono del contacto corresponde a un usuario de
  /// SafeWalk y, si lo encuentra, guarda su uid en el contacto. Devuelve
  /// true si se encontró y vinculó, false si no hay una cuenta con ese
  /// teléfono.
  Future<bool> linkContactToSafeWalkUser(EmergencyContactModel contact) async {
    _linkingContactIds.add(contact.id);
    notifyListeners();

    try {
      final uid = await _userService.findUidByPhone(contact.phone);
      await _contactService.setLinkedUid(contact.id, uid);
      _errorMessage = uid == null
          ? 'Ese contacto todavía no tiene cuenta en SafeWalk.'
          : null;
      return uid != null;
    } catch (_) {
      _errorMessage = 'No se pudo verificar el contacto.';
      return false;
    } finally {
      _linkingContactIds.remove(contact.id);
      notifyListeners();
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
