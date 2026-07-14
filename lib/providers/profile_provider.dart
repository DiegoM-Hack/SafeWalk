import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
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
        provider: _currentUser!.provider,
        isActive: _currentUser!.isActive,
        createdAt: _currentUser!.createdAt,
        updatedAt: Timestamp.now(),
      );

      // Se guarda en Firebase Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(_currentUser!.toMap());

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

  // Tomar o elegir foto de perfil y subirla a Firebase Storage
  Future<bool> updateProfilePhoto(ImageSource source) async {
    final user = _auth.currentUser;
    if (user == null || _currentUser == null) return false;

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (pickedFile == null) return false; // el usuario canceló

    _isLoading = true;
    notifyListeners();

    try {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      _currentUser = UserModel(
        uid: _currentUser!.uid,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        photoUrl: downloadUrl,
        provider: _currentUser!.provider,
        isActive: _currentUser!.isActive,
        createdAt: _currentUser!.createdAt,
        updatedAt: Timestamp.now(),
      );

      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': downloadUrl,
        'updatedAt': Timestamp.now(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error al subir foto de perfil: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
