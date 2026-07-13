import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip_model.dart';

class TripService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Referencia a la subcolección de recorridos del usuario autenticado.
  /// users/{uid}/trips
  CollectionReference<Map<String, dynamic>> get _tripsRef {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    return _db.collection('users').doc(uid).collection('trips');
  }

  /// Stream en tiempo real del historial de recorridos, más recientes primero.
  Stream<List<TripModel>> getTrips() {
    return _tripsRef
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TripModel.fromDocument(doc)).toList());
  }

  Future<String> saveTrip(TripModel trip) async {
    final doc = await _tripsRef.add(trip.toFirestore());
    return doc.id;
  }

  Future<void> deleteTrip(String tripId) async {
    await _tripsRef.doc(tripId).delete();
  }
}
