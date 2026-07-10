import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Cargar datos del usuario logueado desde Firestore
  Future<void> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("Error al cargar perfil: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> updateUserProfile({
    required String name, 
    required String email,
    required String phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null || _currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = UserModel(
        uid: _currentUser!.uid,
        name: name,
        email: email,
        phone: phone,
        photoUrl: _currentUser!.photoUrl,
      );

      // Guardamos en Firebase Firestore
      await _firestore.collection('users').doc(user.uid).update(_currentUser!.toMap());
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error al actualizar perfil: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}