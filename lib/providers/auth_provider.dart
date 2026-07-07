import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;

  bool get isLoading => _isLoading;

  bool get isLoggedIn => _user != null;

  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _firebaseError(e);
      return false;
    } catch (_) {
      _errorMessage = "Ha ocurrido un error inesperado.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      await _authService.register(
        email: email,
        password: password,
      );

      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _firebaseError(e);
      return false;
    } catch (_) {
      _errorMessage = "Ha ocurrido un error inesperado.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-email":
        return "Correo electrónico inválido.";

      case "user-not-found":
        return "No existe una cuenta con ese correo.";

      case "wrong-password":
      case "invalid-credential":
        return "Correo o contraseña incorrectos.";

      case "email-already-in-use":
        return "El correo ya está registrado.";

      case "weak-password":
        return "La contraseña es demasiado débil.";

      case "too-many-requests":
        return "Demasiados intentos. Intenta más tarde.";

      default:
        return e.message ?? "Error de autenticación.";
    }
  }
}