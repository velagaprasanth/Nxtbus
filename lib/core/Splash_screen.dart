import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("This is initstate");
    Future.delayed(Duration(seconds: 3), () {
      context.go("/auth");
    });
  }

  @override
  Widget build(BuildContext context) {
    print("This is out of initstate");
    return Scaffold(
      body: Center(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('NXT', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('Bus', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}