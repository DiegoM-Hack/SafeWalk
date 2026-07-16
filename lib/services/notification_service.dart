import 'package:firebase_messaging/firebase_messaging.dart';

import 'user_service.dart';

/// Tipos de notificación que la app sabe interpretar en el payload `data`
/// de un mensaje FCM. Hoy solo se usa para la solicitud de ubicación
/// compartida, pero deja espacio para otros tipos (ej. alertas SOS).
class NotificationTypes {
  static const String locationShareRequest = 'location_share_request';
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final UserService _userService = UserService();

  /// Se llama una vez el usuario inicia sesión (ver AuthProvider). Pide
  /// permisos, obtiene el token FCM, lo guarda en `users/{uid}` y deja
  /// escuchando renovaciones de token mientras la sesión siga activa.
  Future<void> initialize({required String uid}) async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    if (token != null) {
      await _userService.updateFcmToken(uid: uid, token: token);
    }

    _messaging.onTokenRefresh.listen((newToken) {
      _userService.updateFcmToken(uid: uid, token: newToken);
    });
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Escucha notificaciones que llegan con la app abierta en primer plano.
  /// [onLocationShareRequest] se invoca con el `shareId` cuando el mensaje
  /// recibido es una solicitud de ubicación compartida, para que la UI
  /// (ver `app.dart`) pueda mostrar el diálogo de aceptar/rechazar.
  void listenForegroundMessages({
    required void Function(String shareId) onLocationShareRequest,
  }) {
    FirebaseMessaging.onMessage.listen((message) {
      _handleMessageData(message.data, onLocationShareRequest);
    });
  }

  /// Escucha el caso en que el usuario tocó la notificación con la app en
  /// segundo plano (no cerrada) y la abrió desde ahí.
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
}
