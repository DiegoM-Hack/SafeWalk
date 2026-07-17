import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_service.dart'; // ajusta el path si tu UserService está en otra carpeta

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final UserService _userService = UserService();

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("Permiso FCM: ${settings.authorizationStatus}");

    final token = await getToken();

    debugPrint("FCM Token:");
    debugPrint(token);

    // Guardamos el token apenas lo obtenemos
    await _saveToken(token);

    // El token puede cambiar (reinstalación, nuevo dispositivo, etc.)
    _messaging.onTokenRefresh.listen(_saveToken);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpened);
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Guarda el token FCM del usuario actual usando UserService.
  /// Sin esto, la Cloud Function nunca encuentra a quién enviarle el push.
  Future<void> _saveToken(String? token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      debugPrint("No se guardó el token: no hay usuario autenticado.");
      return;
    }

    if (token == null) {
      debugPrint("Token nulo, no se guarda.");
      return;
    }

    try {
      await _userService.updateFCMToken(uid: uid, token: token);
      debugPrint("Token FCM guardado para $uid");
    } catch (e) {
      debugPrint("Error guardando token FCM: $e");
    }
  }

  Future<void> sendNotification({
    required String receiverUid,
    required String senderUid,
    required String alertId,
  }) async {
    await FirebaseFirestore.instance.collection("notifications").add({
      "receiverUid": receiverUid,
      "senderUid": senderUid,
      "alertId": alertId,
      "type": "sos",
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> accept(String id) async {
    await FirebaseFirestore.instance.collection("notifications").doc(id).update(
      {"status": "accepted"},
    );
  }

  Future<void> reject(String id) async {
    await FirebaseFirestore.instance.collection("notifications").doc(id).update(
      {"status": "rejected"},
    );
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint("Notificación recibida");
    debugPrint(message.notification?.title);
    debugPrint(message.notification?.body);
  }

  void _onNotificationOpened(RemoteMessage message) {
    debugPrint("El usuario abrió una notificación");
  }
}
