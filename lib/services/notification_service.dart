import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  Future<void> initialize() async {
    final settings =
        await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      "Permiso FCM: ${settings.authorizationStatus}",
    );

    final token = await getToken();

    debugPrint("FCM Token:");
    debugPrint(token);

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

         "status":"accepted",

      });

}

Future<void> reject(String id) async {

   await FirebaseFirestore.instance
      .collection("notifications")
      .doc(id)
      .update({

         "status":"rejected",

      });

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