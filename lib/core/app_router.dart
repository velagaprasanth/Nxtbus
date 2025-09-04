// lib/core/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:nxtbus/Screens/Home_Screen.dart';
import 'package:nxtbus/Screens/More_Screen.dart';
import 'package:nxtbus/Screens/Routes_Screen.dart';
import 'package:nxtbus/Screens/Trips_Screen.dart';
import 'package:nxtbus/auth/Login_Screen.dart';
import 'package:nxtbus/auth/Register_Screen.dart';
import 'package:nxtbus/core/Bottom_bar.dart';
import 'package:nxtbus/core/Splash_screen.dart';
import 'package:nxtbus/auth_wrapper.dart';
import 'package:nxtbus/core/owner_bottom_bar.dart'; // Import the owner's screen

final approuter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(path: "/", builder: (context, state) => SplashScreen()),
    GoRoute(path: "/auth", builder: (context, state) => AuthWrapper()),
    GoRoute(path: "/login", builder: (context, state) => LoginScreen()),
    GoRoute(path: "/register", builder: (context, state) => RegisterScreen()),

    // --- NEW: Add a dedicated top-level route for the owner ---
    GoRoute(path: "/owner", builder: (context, state) => OwnerBottomNav()),

    // This ShellRoute is now ONLY for users/guests
    ShellRoute(
      builder: (context, state, child) => BottomBar(child: child),
      routes: [
        GoRoute(path: "/home", builder: (context, state) => YoloBusScreen()),
        GoRoute(path: "/trip", builder: (context, state) => TripsScreen()), // Assuming TripsScreen is AddBusDetailsPage
        GoRoute(path: "/routes", builder: (context, state) => NxtBusScreen()), // Assuming RoutesScreen is NxtBusScreen
        GoRoute(path: "/more", builder: (context, state) => ProfileMoreScreen()),
      ],
    ),
  ],
);