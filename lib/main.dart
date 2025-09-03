import 'package:flutter/material.dart';
import 'package:nxtbus/core/app_router.dart'; // your router
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/seat_selection_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // sign in anonymously so Firestore can be accessed
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    print("❌ ERROR: Failed to sign in anonymously: $e");
  }
 Stripe.publishableKey = "pk_test_51S2q3k0Wgr5knu96mgEPwcVSIdAWutDOwgpbyTF7Zfu4ClXe6H1Vl4jEX5inZIeztdM75kJGlD0BXMB7IuJKeeri00HonUF0rk";
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SeatSelectionProvider(),
      child: MaterialApp.router(
        routerConfig: approuter,
        title: 'NXTBus',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}