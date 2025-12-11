import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/trip_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  DatabaseService(this.userId);

  // --- Image Handling (Local Storage) ---
  // Saves the XFile to the app's document directory so it persists
  Future<String> saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  // --- Trip Handling ---
  
  // Get Trips Stream
  Stream<List<Trip>> get tripsStream {
    return _db
        .collection('users')
        .doc(userId)
        .collection('trips')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Trip.fromJson(doc.data())).toList();
    });
  }

  // Add or Update Trip
  Future<void> updateTrip(Trip trip) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('trips')
        .doc(trip.id)
        .set(trip.toJson());
  }

  // Delete Trip
  Future<void> deleteTrip(String tripId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('trips')
        .doc(tripId)
        .delete();
  }
}