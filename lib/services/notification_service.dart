import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_service.dart';

/// Tipos de notificación que la app sabe interpretar en el payload `data`
/// de un mensaje FCM. Hoy solo se usa para la solicitud de ubicación
/// compartida, pero deja espacio para otros tipos (ej. alertas SOS).
class NotificationTypes {
  static const String locationShareRequest = 'location_share_request';
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final UserService _userService = UserService();

  /// Inicializa FCM y guarda el token del usuario.
  Future<void> initialize({String? uid}) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("Permiso FCM: ${settings.authorizationStatus}");

    final token = await getToken();

    debugPrint("FCM Token:");
    debugPrint(token);

    if (uid != null && token != null) {
      await _userService.updateFcmToken(
        uid: uid,
        token: token,
      );

      _messaging.onTokenRefresh.listen((newToken) {
        _userService.updateFcmToken(
          uid: uid,
          token: newToken,
        );
      });
    }

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(
      _onNotificationOpened,
    );
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> sendNotification({
    required String receiverUid,
    required String senderUid,
    required String alertId,
  }) async {
    await FirebaseFirestore.instance
        .collection("notifications")
        .add({
      "receiverUid": receiverUid,
      "senderUid": senderUid,
      "alertId": alertId,
      "type": "sos",
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> accept(String id) async {
    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(id)
        .update({
      "status": "accepted",
    });
  }

  Future<void> reject(String id) async {
    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(id)
        .update({
      "status": "rejected",
    });
  }

  /// Para la funcionalidad de compartir ubicación
  void listenForegroundMessages({
    required void Function(String shareId) onLocationShareRequest,
  }) {
    FirebaseMessaging.onMessage.listen((message) {
      _handleMessageData(message.data, onLocationShareRequest);
    });
  }

  void listenNotificationTaps({
    required void Function(String shareId) onLocationShareRequest,
  }) {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessageData(message.data, onLocationShareRequest);
    });
  }

  void _handleMessageData(
    Map<String, dynamic> data,
    void Function(String shareId) onLocationShareRequest,
  ) {
    if (data['type'] == NotificationTypes.locationShareRequest) {
      final shareId = data['shareId'] as String?;

      if (shareId != null && shareId.isNotEmpty) {
        onLocationShareRequest(shareId);
      }
    }
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