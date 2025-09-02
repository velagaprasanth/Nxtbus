// scripts/generate_seats.dart
// RUN THIS FROM YOUR TERMINAL: dart run scripts/generate_seats.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nxtbus/firebase_options.dart';


// --- 1. DEFINE YOUR BUS LAYOUT TEMPLATES ---
// A standard 2x2 seater layout for a bus with 11 rows
final List<Map<String, dynamic>> layout2x2Seater = [
  {'p': 0, 't': 'driver'},
  {'p': 1, 'n': 'A1', 't': 'seater'}, {'p': 2, 'n': 'A2', 't': 'seater'}, {'p': 3, 't': 'aisle'}, {'p': 4, 'n': 'A3', 't': 'seater'}, {'p': 5, 'n': 'A4', 't': 'seater'},
  {'p': 6, 'n': 'B1', 't': 'seater'}, {'p': 7, 'n': 'B2', 't': 'seater'}, {'p': 8, 't': 'aisle'}, {'p': 9, 'n': 'B3', 't': 'seater'}, {'p': 10, 'n': 'B4', 't': 'seater'},
  {'p': 11, 'n': 'C1', 't': 'seater'}, {'p': 12, 'n': 'C2', 't': 'seater'}, {'p': 13, 't': 'aisle'}, {'p': 14, 'n': 'C3', 't': 'seater'}, {'p': 15, 'n': 'C4', 't': 'seater'},
  {'p': 16, 'n': 'D1', 't': 'seater'}, {'p': 17, 'n': 'D2', 't': 'seater'}, {'p': 18, 't': 'aisle'}, {'p': 19, 'n': 'D3', 't': 'seater'}, {'p': 20, 'n': 'D4', 't': 'seater'},
  {'p': 21, 'n': 'E1', 't': 'seater'}, {'p': 22, 'n': 'E2', 't': 'seater'}, {'p': 23, 't': 'aisle'}, {'p': 24, 'n': 'E3', 't': 'seater'}, {'p': 25, 'n': 'E4', 't': 'seater'},
  {'p': 26, 'n': 'F1', 't': 'seater'}, {'p': 27, 'n': 'F2', 't': 'seater'}, {'p': 28, 't': 'aisle'}, {'p': 29, 'n': 'F3', 't': 'seater'}, {'p': 30, 'n': 'F4', 't': 'seater'},
  {'p': 31, 'n': 'G1', 't': 'seater'}, {'p': 32, 'n': 'G2', 't': 'seater'}, {'p': 33, 't': 'aisle'}, {'p': 34, 'n': 'G3', 't': 'seater'}, {'p': 35, 'n': 'G4', 't': 'seater'},
  {'p': 36, 'n': 'H1', 't': 'seater'}, {'p': 37, 'n': 'H2', 't': 'seater'}, {'p': 38, 't': 'aisle'}, {'p': 39, 'n': 'H3', 't': 'seater'}, {'p': 40, 'n': 'H4', 't': 'seater'},
  {'p': 41, 'n': 'I1', 't': 'seater'}, {'p': 42, 'n': 'I2', 't': 'seater'}, {'p': 43, 't': 'aisle'}, {'p': 44, 'n': 'I3', 't': 'seater'}, {'p': 45, 'n': 'I4', 't': 'seater'},
  {'p': 46, 'n': 'J1', 't': 'seater'}, {'p': 47, 'n': 'J2', 't': 'seater'}, {'p': 48, 'n': 'J3', 't': 'seater'}, {'p': 49, 'n': 'J4', 't': 'seater'}, {'p': 50, 'n': 'J5', 't': 'seater'},
];

// --- 2. CONFIGURE YOUR FLEET ---
// THIS IS THE ONLY PART YOU NEED TO EDIT.
// Add all your bus document IDs from Firestore here.
final Map<String, dynamic> busesToProcess = {
  // 'bus-document-id': { 'layout': layoutTemplate, 'price': ticketPrice },
  '4Fyc3X7Z4EZ4bE14b23t': {'layout': layout2x2Seater, 'price': 950},
  'bus-02': {'layout': layout2x2Seater, 'price': 950.0},
  // Add more buses here
  // 'bus-03-sleeper': {'layout': yourSleeperLayout, 'price': 1400.0},
};
// --- END OF CONFIGURATION ---

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;

  print('Processing ${busesToProcess.length} buses...');

  for (var entry in busesToProcess.entries) {
    String busId = entry.key;
    List<Map<String, dynamic>> layout = entry.value['layout'];
    double price = entry.value['price'];

    print('  -> Checking Bus ID: $busId');
    final seatsCollection = firestore.collection('buses').doc(busId).collection('seats');
    
    var existingSeats = await seatsCollection.limit(1).get();
    if (existingSeats.docs.isNotEmpty) {
      print('     SKIPPING: Seats already exist for $busId.');
      continue;
    }

    final batch = firestore.batch();
    for (final seatData in layout) {
      final seatDocRef = seatsCollection.doc();
      Map<String, dynamic> data = {
        'position': seatData['p'],
        'type': seatData['t'],
        'status': 'available',
        'seatNumber': seatData['n'] ?? '',
        'price': seatData['t'] == 'aisle' || seatData['t'] == 'driver' ? 0.0 : price,
      };
      batch.set(seatDocRef, data);
    }
    
    await batch.commit();
    print('     SUCCESS: Created ${layout.length} seats for $busId.');
  }
  print('\nFleet setup complete!');
}