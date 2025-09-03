import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nxtbus/Screens/Home_Screen.dart';
import 'package:nxtbus/core/Bottom_bar.dart';
import 'package:nxtbus/core/owner_bottom_bar.dart';

// --- IMPORTANT: Make sure these import paths are correct for your project ---
// --- You might need to adjust the path based on your folder structure ---
 // We need UserHomeScreen from here

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // This stream listens for authentication changes (login, logout)
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While the app is checking, show a loading circle
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If a user IS logged in
        if (snapshot.hasData && snapshot.data != null) {
          // Now, check their role from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Handle cases where the document might not exist or there's an error
              if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                  // Default to the user screen if we can't get user data
                  return const YoloBusScreen();
              }

              // Safely get the data map
              final data = userSnapshot.data!.data() as Map<String, dynamic>?;

              // Check if the 'role' field exists and what its value is
              if (data != null && data.containsKey('role') && data['role'] == 'owner') {
                // If role is 'owner', show the OwnerBottomNav
                return const OwnerBottomNav();
              } else {
                // For any other role (e.g., 'user', or if role is missing), show the normal screen
                return const YoloBusScreen();
              }
            },
          );
        }

        // If a user IS NOT logged in (is a guest)
        // Show the normal customer interface by default.
        return const YoloBusScreen();
      },
    );
  }
}