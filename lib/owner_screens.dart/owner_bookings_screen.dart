// lib/owner_screens/owner_bookings_screen.dart

import 'package:flutter/material.dart';

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 60, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Manage Bookings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('View and manage all your bus bookings here.'),
          ],
        ),
      ),
    );
  }
}