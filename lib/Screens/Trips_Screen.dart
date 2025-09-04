import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:nxtbus/models/bus_model.dart';

// A new model to hold the user's specific trip details
class UserTrip {
  final BusModel bus;
  final String seatNumber;

  UserTrip({required this.bus, required this.seatNumber});
}

class ActiveTripsScreen extends StatefulWidget {
  const ActiveTripsScreen({super.key});

  @override
  State<ActiveTripsScreen> createState() => _ActiveTripsScreenState();
}

class _ActiveTripsScreenState extends State<ActiveTripsScreen> {
  // We use a Future to hold the results of our complex search
  Future<List<UserTrip>>? _userTripsFuture;

  @override
  void initState() {
    super.initState();
    // Listen for changes in authentication state (login/logout)
    FirebaseAuth.instance.authStateChanges().listen((user) {
      // When the user logs in or out, refresh the list of trips
      setState(() {
        _userTripsFuture = _fetchUserTrips();
      });
    });
    // Fetch initial trips
    _userTripsFuture = _fetchUserTrips();
  }

  // This function finds all seats booked by the current user
  Future<List<UserTrip>> _fetchUserTrips() async {
    final user = FirebaseAuth.instance.currentUser;

    // If no user is logged in, there are no trips to show.
    if (user == null) {
      return [];
    }

    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<UserTrip> myTrips = [];

    // 1. Get all buses that are active today or in the future
    final busesSnapshot = await FirebaseFirestore.instance
        .collection('buses')
        .where('travel_date', isGreaterThanOrEqualTo: today)
        .get();

    // 2. Loop through each bus to check its seats
    for (var busDoc in busesSnapshot.docs) {
      final bus = BusModel.fromFirestore(busDoc);
      final seats = busDoc.data()['seats'] as Map<String, dynamic>? ?? {};

      // 3. Loop through each seat to see if the current user booked it
      for (var seatEntry in seats.entries) {
        final seatData = seatEntry.value as Map<String, dynamic>;
        final bookedUserId = seatData['userId'] as String?;

        // If a seat is booked by the current user, add it to our list
        if (bookedUserId == user.uid) {
          myTrips.add(UserTrip(bus: bus, seatNumber: seatEntry.key));
        }
      }
    }

    return myTrips;
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user to decide what to show
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Active Trips',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5), // Blue theme
        elevation: 0,
      ),
      body: user == null
          ? _buildLoggedOutView()
          : FutureBuilder<List<UserTrip>>(
              future: _userTripsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final trips = snapshot.data;

                if (trips == null || trips.isEmpty) {
                  return const Center(
                    child: Text(
                      'You have no upcoming trips.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                // Display the list of the user's booked trips
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return _buildTicketCard(trip);
                  },
                );
              },
            ),
    );
  }

  Widget _buildTicketCard(UserTrip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          // Main ticket container
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          
          // Left blue accent bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF1E88E5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),

          // Main content area
          Positioned(
            left: 20,
            right: 100,
            top: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E88E5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.directions_bus,
                              color: Color(0xFF1E88E5),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              trip.bus.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Route with arrow
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              trip.bus.fromLocation.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF1E88E5),
                              size: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              trip.bus.toLocation.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Bottom section with date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        trip.bus.createdAt.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Right side - Seat section with perforated edge
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                // Perforated line
                Container(
                  width: 2,
                  height: 180,
                  child: Column(
                    children: List.generate(14, (index) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          decoration: BoxDecoration(
                            color: index % 2 == 0 ? Colors.transparent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                // Seat stub
                Container(
                  width: 90,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.airline_seat_recline_normal,
                          color: Color(0xFF1E88E5),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SEAT',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trip.seatNumber,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top right corner decoration
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ACTIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // A helper widget to show when the user is logged out
  Widget _buildLoggedOutView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.login, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Please log in to see your trips.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}