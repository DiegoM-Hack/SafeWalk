import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _firebaseUser;
  UserModel? _userModel;

  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;

  UserModel? get user => _userModel;

  bool get isLoading => _isLoading;

  bool get isLoggedIn => _firebaseUser != null;

  bool _isInitialLoading = true;

  bool get isInitialLoading => _isInitialLoading;

  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authService.authStateChanges.listen(_handleAuthStateChanged);
  }

  Future<void> _handleAuthStateChanged(User? firebaseUser) async {
  _firebaseUser = firebaseUser;

  if (firebaseUser != null) {
    _userModel = await _userService.getUser(firebaseUser.uid);
  } else {
    _userModel = null;
  }

  _isInitialLoading = false;
  notifyListeners();
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

      final uid = _authService.currentUser!.uid;

      final token = await NotificationService.instance.getToken();

      await _userService.updateFCMToken(
        uid: uid,
        token: token,
      );

      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _firebaseError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final credential = await _authService.register(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user!;

      final user = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email.trim().toLowerCase(),
        phone: phone,
        photoUrl: null,
        provider: "email",
        isActive: true,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await _userService.createUser(user);

      final token = await NotificationService.instance.getToken();

      await _userService.updateFCMToken(
        uid: firebaseUser.uid,
        token: token,
      );

      _userModel = user;

      _errorMessage = null;

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _firebaseError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginGoogle() async {
    _setLoading(true);

    try {
      final credential = await _authService.signInWithGoogle();

      final firebaseUser = credential.user!;

      final exists =
          await _userService.exists(firebaseUser.uid);

      final uid = _authService.currentUser!.uid;

      

      if (!exists) {
        final user = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? "",
          email: firebaseUser.email ?? "".trim().toLowerCase(),
          phone: firebaseUser.phoneNumber ?? "",
          photoUrl: firebaseUser.photoURL,
          provider: "google",
          isActive: true,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );

        await _userService.createUser(user);

        _userModel = user;
      } else {
        _userModel =
            await _userService.getUser(firebaseUser.uid);
      }

      final token = await NotificationService.instance.getToken();

      await _userService.updateFCMToken(
        uid: uid,
        token: token,
      );

      _errorMessage = null;

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _firebaseError(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    // Si el proveedor externo (ej. Google en web sin Client ID) falla,
    // igual limpiamos el estado local para que la UI navegue a login.
    try {
      await _authService.logout();
    } catch (_) {
      // Ya se maneja/loguea dentro de AuthService; no bloqueamos el logout local.
    } finally {
      _firebaseUser = null;
      _userModel = null;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
  _setLoading(true);

  try {
    await _authService.resetPassword(email);
    _errorMessage = null;
    return true;
  } on FirebaseAuthException catch (e) {
    _errorMessage = _firebaseError(e);
    return false;
  } catch (e) {
    _errorMessage = e.toString();
    return false;
  } finally {
    _setLoading(false);
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
        return "Demasiados intentos. Inténtelo más tarde.";

      default:
        return e.message ?? "Error de autenticación.";
    }
  }
}