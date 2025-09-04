import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nxtbus/models/bus_model.dart'; // We'll use your BusModel
import 'package:nxtbus/Screens/Trips_Screen.dart';
import 'package:nxtbus/owner_screens.dart/add_bus_details_page.dart'; // This is your AddBusDetailsPage

class ManageBusesScreen extends StatefulWidget {
  const ManageBusesScreen({super.key});

  @override
  State<ManageBusesScreen> createState() => _ManageBusesScreenState();
}

class _ManageBusesScreenState extends State<ManageBusesScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // This stream queries the 'buses' collection in real-time for documents
        // where the 'ownerId' matches the currently logged-in user's ID.
        stream: FirebaseFirestore.instance
            .collection('buses')
            .where('ownerId', isEqualTo: currentUser?.uid ?? 'null')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'You have not added any buses yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // If we have data, map the documents to a list of BusModel objects
          final buses = snapshot.data!.docs
              .map((doc) => BusModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.directions_bus, color: Color(0xFF1E88E5)),
                  title: Text(bus.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${bus.fromLocation.toUpperCase()} to ${bus.toLocation.toUpperCase()}'),
                  trailing: Text(
                    '₹${bus.price.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddBusDetailsPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBusDetailsPage()),
          );
        },
        backgroundColor: const Color(0xFF1E88E5), // nxtbusPrimaryBlue
        child: const Icon(Icons.add, color: Colors.white,),
        tooltip: 'Add New Bus',
      ),
    );
  }
}