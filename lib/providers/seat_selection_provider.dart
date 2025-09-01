import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seats_model_screen.dart'; // Make sure this path is correct

class SeatSelectionProvider extends ChangeNotifier {
  // This map is our cache. It will store seat layouts after they are fetched.
  // Key: busId, Value: List of SeatModel
  final Map<String, List<SeatModel>> _cachedBusSeats = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- NEW, SIMPLER METHODS FOR THE UI ---

  // The UI calls this to get the seats. It's fast because it reads from the cache.
  List<SeatModel> getSeatsForBus(String busId) {
    return _cachedBusSeats[busId] ?? [];
  }
  
  // Gets the list of selected seats for a specific bus from the cache.
  List<SeatModel> getSelectedSeatsForBus(String busId) {
    final seats = _cachedBusSeats[busId] ?? [];
    return seats.where((seat) => seat.isSelectedByCurrentUser).toList();
  }

  // Gets the total price for a specific bus from the cache.
  double getTotalPriceForBus(String busId) {
    final selectedSeats = getSelectedSeatsForBus(busId);
    return selectedSeats.fold(0.0, (sum, seat) => sum + seat.price);
  }

  // --- THE LOGIC ---

  // This method talks to Firebase, but ONLY if the data isn't already in our cache.
  Future<void> fetchSeatsForBus(String busId) async {
    // 1. Check the cache first. If we have the data, do nothing.
    if (_cachedBusSeats.containsKey(busId)) {
      return;
    }

    // 2. If not in the cache, fetch from Firebase.
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('buses').doc(busId).collection('seats').get();

      final seats = snapshot.docs.map((doc) => SeatModel.fromFirestore(doc)).toList();

      // 3. Store the result in our cache. It will be saved here for the future.
      _cachedBusSeats[busId] = seats;

    } catch (e) {
      print("Error fetching seats for $busId: $e");
      _cachedBusSeats[busId] = []; // Store an empty list on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSeatSelection(String busId, String seatDocId) {
    final seatList = _cachedBusSeats[busId];
    if (seatList == null) return;

    final seat = seatList.firstWhere((s) => s.docId == seatDocId);
    if (seat.status == 'available') {
      seat.isSelectedByCurrentUser = !seat.isSelectedByCurrentUser;
      notifyListeners(); // Tell the UI to update.
    }
  }
}