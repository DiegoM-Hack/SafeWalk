import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../models/user_model.dart';

class UserService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final String collection = "users";

  Future<void> createUser(UserModel user) async {

    await _firestore
        .collection(collection)
        .doc(user.uid)
        .set(user.toMap());

  }

  Future<bool> exists(String uid) async {

    final doc = await _firestore
        .collection(collection)
        .doc(uid)
        .get();

    return doc.exists;

  }

  Future<UserModel?> getUser(String uid) async {

    final doc = await _firestore
        .collection(collection)
        .doc(uid)
        .get();

    if(!doc.exists){
      return null;
    }

    return UserModel.fromMap(doc.data()!);

  }

  Future<void> updateFCMToken({
  required String uid,
  required String? token,
  }) async {
    if (token == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'fcmToken': token,
    });
  }

  Future<void> getFCMToken(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('fcmToken')) {
        final token = data['fcmToken'] as String?;
        debugPrint('FCM Token for user $uid: $token');
      } else {
        debugPrint('No FCM token found for user $uid.');
      }
    } else {
      debugPrint('User document does not exist for uid: $uid');
    }
    
  }

}