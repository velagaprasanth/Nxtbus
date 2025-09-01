import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomBar extends StatefulWidget {
  final Widget child;
  const BottomBar({super.key, required this.child});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int calculateCurrentIndex(String location) {
    if (location.startsWith("/home")) return 0;
    if (location.startsWith("/trip")) return 1;
    if (location.startsWith("/routes")) return 2;
    if (location.startsWith("/more")) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    int currentIndex = calculateCurrentIndex(location);
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go("/home");
              break;
            case 1:
              context.go("/trip");
              break;
            case 2:
              context.go("/routes");
              break;
            case 3:
              context.go("/more");
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.trip_origin), label: "Trip"),
          BottomNavigationBarItem(
            icon: Icon(Icons.route_sharp),
            label: "Routes",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more), label: "More"),
        ],
      ),
    );
  }
}