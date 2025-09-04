import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// A simple model to hold booking details
class BookingDetails {
  final String userName;
  final String userEmail;
  final String busName;
  final String seatNumber;

  BookingDetails({
    required this.userName,
    required this.userEmail,
    required this.busName,
    required this.seatNumber,
  });
}

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late Future<List<BookingDetails>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _fetchBookingsForOwner();
  }

  Future<List<BookingDetails>> _fetchBookingsForOwner() async {
    final ownerId = FirebaseAuth.instance.currentUser?.uid;
    if (ownerId == null) {
      // Not logged in as an owner, return empty list
      return [];
    }

    List<BookingDetails> allBookings = [];

    // 1. Find all buses created by the current owner
    final busesSnapshot = await FirebaseFirestore.instance
        .collection('buses')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    for (var busDoc in busesSnapshot.docs) {
      final busData = busDoc.data();
      final busName = busData['name'] as String? ?? 'Unnamed Bus';
      final seats = busData['seats'] as Map<String, dynamic>? ?? {};

      // 2. Find all booked seats in each bus
      for (var seatEntry in seats.entries) {
        final seatData = seatEntry.value as Map<String, dynamic>;
        final isBooked = seatData['booked'] as bool? ?? false;
        final userId = seatData['userId'] as String?;

        if (isBooked && userId != null) {
          // 3. Fetch the user's details for each booking
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            allBookings.add(
              BookingDetails(
                userName: userData['name'] ?? 'No Name',
                userEmail: userData['email'] ?? 'No Email',
                busName: busName,
                seatNumber: seatEntry.key, // The seat ID like "1A", "2B"
              ),
            );
          }
        }
      }
    }

    return allBookings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<BookingDetails>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bookings = snapshot.data;

          // Handle no data or empty list state
          if (bookings == null || bookings.isEmpty) {
            return const Center(
              child: Text(
                'No bookings found for your buses.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Display the list of bookings
          return RefreshIndicator(
            onRefresh: () async {
               setState(() {
                 _bookingsFuture = _fetchBookingsForOwner();
               });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blueAccent),
                    title: Text(
                      booking.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${booking.userEmail}\nBus: ${booking.busName}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Seat', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          booking.seatNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}