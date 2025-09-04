import 'package:flutter/material.dart';
import 'package:nxtbus/owner_screens.dart/add_bus_details_page.dart';
import '../owner_screens.dart/owner_bookings_screen.dart';

import '../owner_screens.dart/owner_dashboard_screen.dart';
// 1. Import your new ManageBusesScreen
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
    const AddBusDetailsPage(),
    // 2. Replace the AddBusDetailsPage with your new ManageBusesScreen
    const ManageBusesScreen(),
    const ProfileMoreScreen(),
  ];
  
  // A list of titles for the AppBar
  final List<String> _appBarTitles = [
    "Owner Dashboard",
    "All Bookings",
    "Manage My Buses",
    "Profile"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title now changes based on the selected tab
        title: Text(_appBarTitles[_selectedIndex]),
        backgroundColor: const Color(0xFF1565C0),
        automaticallyImplyLeading: false,
      ),
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
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: "Bookings"),
          // 3. Update the label to be more descriptive
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus), label: "My Buses"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}