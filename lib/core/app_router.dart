// lib/core/app_router.dart

import 'package:go_router/go_router.dart';

import 'package:nxtbus/Screens/Home_Screen.dart';
import 'package:nxtbus/Screens/More_Screen.dart';
import 'package:nxtbus/Screens/Routes_Screen.dart';
import 'package:nxtbus/Screens/Trips_Screen.dart';

import 'package:nxtbus/auth/Register_Screen.dart';
import 'package:nxtbus/core/Bottom_bar.dart';
import 'package:nxtbus/core/Splash_screen.dart';



final approuter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(path: "/", builder: (context, state) => SplashScreen()),
    GoRoute(path: "/login", builder: (context, state) => YoloBusScreen()),
    GoRoute(path: "/register", builder: (context, state) => RegisterScreen()),
    ShellRoute(
      builder: (context, state, child) => BottomBar(child: child),
      routes: [
        GoRoute(path: "/home", builder: (context, state) => YoloBusScreen()),
        GoRoute(path: "/trip", builder: (context, state) => AddBusDetailsPage()),
        GoRoute(path: "/routes", builder: (context, state) => NxtBusScreen()),
        GoRoute(path: "/more", builder: (context, state) => ProfileMoreScreen()),
        
      ],
    ),
    
    
  ],
);