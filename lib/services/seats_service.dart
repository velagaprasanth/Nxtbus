import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔹 Utility: convert column index to letters (0 -> A, 25 -> Z, 26 -> AA...)
String _columnLetter(int index) {
  var i = index;
  var s = '';
  while (i >= 0) {
    s = String.fromCharCode(65 + (i % 26)) + s;
    i = (i ~/ 26) - 1;
  }
  return s;
}

/// 🔹 Generate seats for given rows × columns
Map<String, dynamic> generateSeats(int rows, int columns) {
  final seats = <String, dynamic>{};
  for (int r = 1; r <= rows; r++) {
    for (int c = 0; c < columns; c++) {
      final col = _columnLetter(c);
      final seatId = "$r$col";
      seats[seatId] = {"booked": false, "userId": null};
    }
  }
  return seats;
}

class SeatsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = "buses"; // change if your collection name differs

  /// 🔹 Create seats for a bus
  Future<void> createSeats(String busId, int rows, int columns) async {
    final seats = generateSeats(rows, columns);
    await _db.collection(collection).doc(busId).set(
      {"seats": seats},
      SetOptions(merge: true),
    );
  }

  /// 🔹 Get seats for a bus
  Future<Map<String, dynamic>> getSeats(String busId) async {
    final snap = await _db.collection(collection).doc(busId).get();
    if (!snap.exists) return {};
    return Map<String, dynamic>.from(snap.data()?['seats'] ?? {});
  }

  /// 🔹 Book a seat (transaction = prevents double booking)
  Future<bool> bookSeat(String busId, String seatId, String userId) async {
    final docRef = _db.collection(collection).doc(busId);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final seats = Map<String, dynamic>.from(snap.data()?['seats'] ?? {});
      if (seats[seatId]['booked'] == true) {
        return false; // already booked
      }
      tx.update(docRef, {
        "seats.$seatId.booked": true,
        "seats.$seatId.userId": userId,
      });
      return true;
    });
  }
}
