import 'package:cloud_firestore/cloud_firestore.dart';

/// A data model class that represents a single seat.
/// This class helps in converting Firestore documents into clean, usable Dart objects.
class SeatModel {
  final String docId; // The document ID from Firestore
  final String seatNumber;
  final double price;
  final String type; // e.g., 'sleeper', 'seater', 'driver', 'aisle'
  String status; // 'available', 'locked', 'booked'
  String? lockedBy;
  bool isSelectedByCurrentUser; // This is a local state for the UI, not from Firestore

  SeatModel({
    required this.docId,
    required this.seatNumber,
    required this.price,
    required this.type,
    required this.status,
    this.lockedBy,
    this.isSelectedByCurrentUser = false,
  });

  /// A factory constructor to create a SeatModel instance from a Firestore document.
  /// This is a common pattern for cleaner data conversion.
  factory SeatModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return SeatModel(
      docId: doc.id,
      seatNumber: data['seatNumber'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] ?? 'seater',
      status: data['status'] ?? 'available',
      lockedBy: data['lockedBy'],
    );
  }
}