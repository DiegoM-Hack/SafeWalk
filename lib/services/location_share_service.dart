import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/location_share_model.dart';

/// Servicio para el flujo de "Compartir ubicación en tiempo real".
///
/// Colección raíz `location_shares/{shareId}` (ver firestore.rules):
///   fromUid, fromName, toUid, status, durationMinutes,
///   createdAt, expiresAt, respondedAt, lastLat, lastLng
///
/// Subcolección `location_shares/{shareId}/positions/{autoId}`:
///   lat, lng, timestamp
class LocationShareService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _sharesRef =>
      _db.collection('location_shares');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('No hay un usuario autenticado.');
    }
    return uid;
  }

  /// Paso 1: A envía la solicitud a B (toUid). Devuelve el id de la sesión.
  Future<String> sendRequest({
    required String toUid,
    required String fromName,
    int durationMinutes = 30,
  }) async {
    final model = LocationShareModel(
      id: '',
      fromUid: _uid,
      fromName: fromName,
      toUid: toUid,
      status: LocationShareStatus.pending,
      durationMinutes: durationMinutes,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(minutes: durationMinutes)),
    );

    final doc = await _sharesRef.add(model.toCreateMap());
    return doc.id;
  }

  /// Paso 2/3: B acepta o rechaza la solicitud.
  Future<void> respondToRequest({
    required String shareId,
    required bool accept,
  }) async {
    await _sharesRef.doc(shareId).update({
      'status': (accept ? LocationShareStatus.active : LocationShareStatus.rejected).name,
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Paso 4a: A deja de compartir manualmente.
  /// También sirve para que B "deje de seguir" (cualquiera de los dos
  /// participantes puede finalizar la sesión).
  Future<void> stopSharing(String shareId) async {
    await _sharesRef.doc(shareId).update({
      'status': LocationShareStatus.stopped.name,
    });
  }

  /// Marca la sesión como expirada. Pensado para llamarse desde el cliente
  /// al detectar que `expiresAt` ya pasó (ver [LocationShareProvider]); en
  /// producción es recomendable reforzarlo con una Cloud Function
  /// programada, ya que el cliente puede estar cerrado.
  Future<void> markExpired(String shareId) async {
    await _sharesRef.doc(shareId).update({
      'status': LocationShareStatus.expired.name,
    });
  }

  /// A publica su posición mientras la sesión está activa.
  Future<void> pushPosition(String shareId, LatLng position) async {
    final shareDoc = _sharesRef.doc(shareId);

    final batch = _db.batch();
    batch.update(shareDoc, {
      'lastLat': position.latitude,
      'lastLng': position.longitude,
    });
    batch.set(shareDoc.collection('positions').doc(), {
      'lat': position.latitude,
      'lng': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Stream en tiempo real de una sesión puntual (para quien comparte y
  /// para quien recibe: ambos necesitan reaccionar a cambios de estado).
  Stream<LocationShareModel> watchShare(String shareId) {
    return _sharesRef
        .doc(shareId)
        .snapshots()
        .map((doc) => LocationShareModel.fromDocument(doc));
  }

  /// Solicitudes pendientes que me han enviado (para mostrar el diálogo
  /// "X quiere compartir su ubicación contigo").
  Stream<List<LocationShareModel>> watchIncomingPending() {
    return _sharesRef
        .where('toUid', isEqualTo: _uid)
        .where('status', isEqualTo: LocationShareStatus.pending.name)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => LocationShareModel.fromDocument(d)).toList());
  }

  /// Sesiones activas que otras personas están compartiendo conmigo.
  Stream<List<LocationShareModel>> watchIncomingActive() {
    return _sharesRef
        .where('toUid', isEqualTo: _uid)
        .where('status', isEqualTo: LocationShareStatus.active.name)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => LocationShareModel.fromDocument(d)).toList());
  }

  /// Sesiones que yo estoy compartiendo actualmente (para reanudar el
  /// tracking si, por ejemplo, se recarga la app con una sesión activa).
  Stream<List<LocationShareModel>> watchOutgoingActive() {
    return _sharesRef
        .where('fromUid', isEqualTo: _uid)
        .where('status', isEqualTo: LocationShareStatus.active.name)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => LocationShareModel.fromDocument(d)).toList());
  }
}
