import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nxtbus/models/bus_model.dart';

// A simple model for a route to handle uniqueness
class BusRoute {
  final String from;
  final String to;
  BusRoute(this.from, this.to);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusRoute &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => from.hashCode ^ to.hashCode;
}

class AllRoutesScreen extends StatefulWidget {
  const AllRoutesScreen({super.key});

  @override
  State<AllRoutesScreen> createState() => _AllRoutesScreenState();
}

class _AllRoutesScreenState extends State<AllRoutesScreen> {
  late Future<List<BusRoute>> _routesFuture;

  @override
  void initState() {
    super.initState();
    _routesFuture = _fetchUniqueRoutes();
  }

  /// Fetches all buses and compiles a list of unique routes.
  Future<List<BusRoute>> _fetchUniqueRoutes() async {
    final busesSnapshot = await FirebaseFirestore.instance.collection('buses').get();

    // Use a Set to automatically handle uniqueness.
    final Set<BusRoute> uniqueRoutes = {};

    for (var doc in busesSnapshot.docs) {
      try {
        final bus = BusModel.fromFirestore(doc);
        // Important Check: Only add the route if both locations are present.
        // This prevents routes with missing data from being processed.
        if (bus.fromLocation.isNotEmpty && bus.toLocation.isNotEmpty) {
          uniqueRoutes.add(BusRoute(bus.fromLocation, bus.toLocation));
        }
      } catch (e) {
        // This will catch any errors if a bus document has badly formatted data.
        print('Could not parse bus document ${doc.id}: $e');
      }
    }

    // Convert the Set to a List and sort it alphabetically by the 'from' location.
    final sortedRoutes = uniqueRoutes.toList()
      ..sort((a, b) => a.from.compareTo(b.from));
    return sortedRoutes;
  }

  // Helper function to capitalize the first letter of a string.
  String _capitalize(String s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Available Routes', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF1E88E5), // nxtbusPrimaryBlue
      ),
      body: FutureBuilder<List<BusRoute>>(
        future: _routesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No routes have been added yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final routes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              
              // This is the new, improved UI for each route card
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadowColor: const Color(0xFF1E88E5).withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Icon on the left
                      const CircleAvatar(
                        backgroundColor: Color(0xFF1E88E5),
                        child: Icon(Icons.route, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      // Column for 'From' and 'To'
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _capitalize(route.from),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF212121),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Icon(
                                Icons.arrow_downward,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              _capitalize(route.to),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Decorative bus icon on the right
                      const Icon(
                        Icons.directions_bus_filled,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}