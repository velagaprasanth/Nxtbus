import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the nested 'price' object within the bus document.
class Price {
  final double amount;
  final String currency;

  const Price({
    required this.amount,
    required this.currency,
  });

  /// Factory constructor to create a Price object from a map (like from Firestore).
  factory Price.fromMap(Map<String, dynamic> map) {
    return Price(
      // Safely handle both int and double from Firestore by converting to double.
      amount: (map['amount'] ?? 0).toDouble(), 
      currency: map['currency'] ?? 'INR',
    );
  }

  /// Method to convert a Price object back to a map. Useful for writing data.
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency,
    };
  }
}

/// Represents a single bus document from your Firestore collection.
class BusModel {
  // It's crucial to store the document ID for future reference (updates, etc.)
  final String id;
  final String name;
  final String fromLocation;
  final String toLocation;
  final String departureTime;
  final String arrivalTime;
  final String busType;
  final String berthInfo;
  final int seatsAvailable;
  final List<String> tags;
  final DateTime createdAt;
  final Price price;

  const BusModel({
    required this.id,
    required this.name,
    required this.fromLocation,
    required this.toLocation,
    required this.departureTime,
    required this.arrivalTime,
    required this.busType,
    required this.berthInfo,
    required this.seatsAvailable,
    required this.tags,
    required this.createdAt,
    required this.price,
  });

  /// A factory constructor to create a BusModel instance from a Firestore document.
  /// This is the primary way you will convert Firestore data into a usable Dart object.
  factory BusModel.fromFirestore(DocumentSnapshot doc) {
    // Get the data map from the document, handling the case where it might be null.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return BusModel(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Bus',
      // The .trim() is useful for cleaning up potential whitespace from the database.
      fromLocation: (data['from_location'] as String? ?? '').trim(),
      toLocation: (data['to_location'] as String? ?? '').trim(),
      departureTime: data['departure_time'] ?? 'N/A',
      arrivalTime: data['arrival_time'] ?? 'N/A',
      busType: data['bus_type'] ?? 'N/A',
      berthInfo: data['berth_info'] ?? 'N/A',
      seatsAvailable: data['seats_available'] ?? 0,
      // Safely convert the list from Firestore's 'List<dynamic>' to a 'List<String>'.
      tags: List<String>.from(data['tags'] ?? []),
      // Convert the Firestore Timestamp object to a standard Dart DateTime object.
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      // Use the Price model's factory constructor for the nested price map.
      // This is a clean way to handle nested data.
      price: Price.fromMap(data['price'] ?? {}),
    );
  }
}