import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔹 Replace with the busId you want to add seats to
  await generateSeatsForBus("49mdf6kFYECGBMEApgU0");
  print("✅ Seats generated successfully!");
}

Future<void> generateSeatsForBus(String busId, {int rows = 10}) async {
  final busRef = FirebaseFirestore.instance.collection('buses').doc(busId);

  final seats = <String, Map<String, dynamic>>{};
  const cols = ["A", "B", "C", "D"]; // adjust if bus has different layout

  for (int i = 1; i <= rows; i++) {
    for (final c in cols) {
      seats["$i$c"] = {"booked": false, "userId": null};
    }
  }

  await busRef.update({"seats": seats});
}
