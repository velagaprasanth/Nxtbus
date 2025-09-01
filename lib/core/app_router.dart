import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nxtbus/Screens/Home_Screen.dart';
import 'package:nxtbus/Screens/More_Screen.dart';
import 'package:nxtbus/Screens/Trips_Screen.dart';
import 'package:nxtbus/auth/Login_Screen.dart';
import 'package:nxtbus/auth/Register_Screen.dart';
import 'package:nxtbus/core/Bottom_bar.dart';


// --- UPDATED IMPORT PATHS ---
// Make sure these paths are correct for your project
import 'package:nxtbus/Other/Seat_Screen.dart'; // Correct path to your file
import 'package:nxtbus/Other/booking_screen.dart';
import 'package:nxtbus/core/Splash_screen.dart';      // Assuming this path is correct

final approuter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(path: "/", builder: (context, state) => SplashScreen()),
    GoRoute(path: "/login", builder: (context, state) => YoloBusScreen()),
    GoRoute(path: "/register", builder: (context, state) => RegisterPage()),
    ShellRoute(
      builder: (context, state, child) => BottomBar(child: child),
      routes: [
        GoRoute(path: "/home", builder: (context, state) => LoginPage()),
        GoRoute(path: "/trip", builder: (context, state) => AddBusDetailsPage()),
        GoRoute(path: "/more", builder: (context, state) => SearchBusesPage()),
      ],
    ),
    GoRoute(
      path: '/seat-selection',
      builder: (BuildContext context, GoRouterState state) {
        if (state.extra is Map<String, dynamic>) {
          final data = state.extra as Map<String, dynamic>;
          final busId = data['busId'] as String;
          final busData = data['busData'] as Map<String, dynamic>;

          // --- THE FIX IS HERE ---
          // Changed to match your actual class name: SeatSelectionPage
          return SeatSelectionPage(busId: busId, busData: busData);

        } else {
          return const Scaffold(body: Center(child: Text("Error: Missing bus data.")));
        }
      },
    ),
    
  ],
);