import 'package:cloud_firestore/cloud_firestore.dart';

class SeatModel {
  final String docId;
  final String seatNumber;
  final String type;   // seater | sleeper | aisle | driver
  final String status; // available | booked
  final double price;
  bool isSelectedByCurrentUser;

  SeatModel({
    required this.docId,
    required this.seatNumber,
    required this.type,
    required this.status,
    required this.price,
    this.isSelectedByCurrentUser = false,
  });

  factory SeatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SeatModel(
      docId: doc.id,
      seatNumber: (data['seatNumber'] ?? '').toString(),
      type: (data['type'] ?? 'seater').toString(),
      status: (data['status'] ?? 'available').toString(),
      price: (data['price'] ?? 300).toDouble(),
    );
  }
}
