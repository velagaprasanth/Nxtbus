import 'package:flutter/material.dart';
import '../owner_screens.dart/owner_dashboard_screen.dart';
import '../owner_screens.dart/owner_bookings_screen.dart';
import '../owner_screens.dart/manage_buses_screen.dart';
import 'package:nxtbus/Screens/More_Screen.dart';

class OwnerBottomNav extends StatefulWidget {
  const OwnerBottomNav({super.key});

  @override
  State<OwnerBottomNav> createState() => _OwnerBottomNavState();
}

class _OwnerBottomNavState extends State<OwnerBottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const OwnerDashboardScreen(),
    const ManageBusesScreen(),
    const ProfileMoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar has been removed from here.
      // The body will now show whichever screen is selected.
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1565C0), // nxtbusDarkBlue
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
  
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus), label: "My Buses"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}