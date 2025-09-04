import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seats_model_screen.dart';

class SeatSelectionProvider extends ChangeNotifier {
  final Map<String, List<SeatModel>> _cachedBusSeats = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- ADD THIS NEW METHOD ---
  /// Clears all cached seat data and selections.
  void clear() {
    _cachedBusSeats.clear();
    notifyListeners();
    print("SeatSelectionProvider cleared!"); // For debugging
  }
  // -------------------------

  List<SeatModel> getSeatsForBus(String busId) {
    return _cachedBusSeats[busId] ?? [];
  }

  List<SeatModel> getSelectedSeatsForBus(String busId) {
    final seats = _cachedBusSeats[busId] ?? [];
    return seats.where((seat) => seat.isSelectedByCurrentUser).toList();
  }

  double getTotalPriceForBus(String busId) {
    final selectedSeats = getSelectedSeatsForBus(busId);
    return selectedSeats.fold(0.0, (sum, seat) => sum + seat.price);
  }

  Future<void> fetchSeatsForBus(String busId) async {
    if (_cachedBusSeats.containsKey(busId)) {
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('buses')
          .doc(busId)
          .collection('seats')
          .get();

      final seats = snapshot.docs.map((doc) => SeatModel.fromFirestore(doc)).toList();
      _cachedBusSeats[busId] = seats;
    } catch (e) {
      print("❌ Error fetching seats for $busId: $e");
      _cachedBusSeats[busId] = [];
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
      notifyListeners();
    }
  }
}