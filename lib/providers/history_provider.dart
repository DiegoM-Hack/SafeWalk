import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_model.dart';

class HistoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TripModel> _trips = [];
  bool _isLoading = false;

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;

  Future<void> loadTripHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trips')
          .orderBy('startTime', descending: true)
          .get();

      _trips = querySnapshot.docs.map((doc) {
        return TripModel.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      debugPrint("Error crítico al cargar el historial de viajes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
