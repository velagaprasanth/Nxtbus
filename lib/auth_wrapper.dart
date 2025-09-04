// lib/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
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

              final role = userSnapshot.data?.get('role');

              // Use a post-frame callback to ensure the build is complete
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (role == 'owner') {
                  // --- FIX: Navigate to owner route ---
                  context.go('/owner');
                } else {
                  // --- FIX: Navigate to user home route ---
                  context.go('/home');
                }
              });

              // Return a loading indicator while navigation occurs
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }

        // If not logged in, go to the user home screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
        
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}