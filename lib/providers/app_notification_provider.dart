import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/app_notification_service.dart';


class NotificationProvider extends ChangeNotifier {
  final AppNotificationService _service =
      AppNotificationService();

  StreamSubscription? _subscription;

  List<Map<String, dynamic>> _notifications = [];

  bool _loading = false;

  List<Map<String, dynamic>> get notifications =>
      _notifications;

  bool get loading => _loading;

  String? _lastNotificationId;

  String? _currentAlertId;

  String? get currentAlertId => _currentAlertId;

  bool get hasPendingSOS => _currentAlertId != null;

  void listenNotifications(String uid) {

  _subscription?.cancel();
  debugPrint("Escuchando notificaciones para: $uid");

_subscription = FirebaseFirestore.instance
    .collection("notifications")
    .where("receiverUid", isEqualTo: uid)
    .snapshots()
    .listen((snapshot) {

  final pending = snapshot.docs.where(
    (doc) => doc["status"] == "pending",
  );
        debugPrint("Snapshot recibido");
        debugPrint("Cantidad: ${snapshot.docs.length}");
        

        for (final doc in snapshot.docs) {
          debugPrint(doc.data().toString());
        }
  

  if (pending.isEmpty) return;

  final doc = pending.first;

  _lastNotificationId = doc.id;
  _currentAlertId = doc["alertId"];

  notifyListeners();
});
}

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
  }

  Future<void> deleteNotification(String id) async {
    await _service.deleteNotification(id);
  }

  Future<void> rejectNotification(String id) async {
  await _service.rejectNotification(id);
}

  String? get lastNotificationId => _lastNotificationId;

  
bool _dialogShown = false;

bool get dialogShown => _dialogShown;

void markDialogShown() {
  _dialogShown = true;
}

void clearDialog() {
  _dialogShown = false;
  _currentAlertId = null;
  notifyListeners();
}
 
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}