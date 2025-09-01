import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nxtbus/Screens/Routes_Screen.dart';

// --- IMPORTANT: ADD THIS IMPORT ---
// Make sure the path to your seat selection page is correct


// --- Color Palette based on the NXTBus image ---
const Color nxtbusPrimaryBlue = Color(0xFF1E88E5);
const Color nxtbusDarkText = Color(0xFF212121);
const Color nxtbusLightText = Color(0xFF757575);
const Color white = Colors.white;
const Color nxtbusAccentGrey = Color(0xFFF5F5F5);

class SearchBusesPage extends StatefulWidget {
  const SearchBusesPage({super.key});

  @override
  State<SearchBusesPage> createState() => _SearchBusesPageState();
}

class _SearchBusesPageState extends State<SearchBusesPage> {
  bool _isLoading = true; // Start in loading state
  List<QueryDocumentSnapshot> _busResults = [];

  @override
  void initState() {
    super.initState();
    _fetchAllBuses();
  }

  Future<void> _fetchAllBuses() async {
    try {
      // NOTE: For this query to work, you may need to create a Firestore index
      // on the 'buses' collection for the 'createdAt' field. The error message
      // in your Debug Console will provide a link to create it if needed.
      final querySnapshot = await FirebaseFirestore.instance
          .collection('buses')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _busResults = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Check the Debug Console.'),
          backgroundColor: Colors.red,
        ),
      );
      print("Firebase Fetch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: nxtbusAccentGrey,
      appBar: AppBar(
        title: const Text('All Available Buses',
            style: TextStyle(color: white, fontWeight: FontWeight.bold)),
        backgroundColor: nxtbusPrimaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildResultsList(),
    );
  }

  Widget _buildResultsList() {
    if (_busResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No buses found in the database.',
                style: TextStyle(fontSize: 18, color: nxtbusLightText)),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'This could be due to Firestore Security Rules blocking access.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _busResults.length,
      itemBuilder: (context, index) {
        final busDoc = _busResults[index];
        final busData = busDoc.data() as Map<String, dynamic>;
        
        // --- THIS IS THE ONLY CHANGE ---
        // Wrap the card in an InkWell to make it tappable.
        return InkWell(
          onTap: () {
            // When tapped, navigate to the SeatSelectionPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeatSelectionPage(
                  busId: busDoc.id,       // Pass the unique document ID
                  busData: busData,       // Pass the rest of the bus data
                ),
              ),
            );
          },
          // Add a splash color for visual feedback on tap
          splashColor: nxtbusPrimaryBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          child: BusResultCard(busData: busData),
        );
        // --- END OF CHANGE ---
      },
    );
  }
}

// --- BusResultCard Widget (No Changes Needed) ---
class BusResultCard extends StatelessWidget {
  final Map<String, dynamic> busData;
  const BusResultCard({super.key, required this.busData});

  @override
  Widget build(BuildContext context) {
    final priceMap = busData['price'] as Map<String, dynamic>? ?? {};
    final priceAmount = priceMap['amount']?.toString() ?? 'N/A';
    final from = (busData['from_location'] as String?)?.toUpperCase() ?? 'N/A';
    final to = (busData['to_location'] as String?)?.toUpperCase() ?? 'N/A';


    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$from → $to',
                    style: const TextStyle(fontSize: 12, color: nxtbusLightText, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  '₹$priceAmount',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: nxtbusPrimaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              busData['name'] ?? 'Unknown Bus',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: nxtbusDarkText),
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeInfo(
                    'Departure', busData['departure_time'] ?? '--:--'),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                _buildTimeInfo('Arrival', busData['arrival_time'] ?? '--:--',
                    alignRight: true),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Seats Available: ${busData['seats_available'] ?? 0}',
              style: const TextStyle(
                  fontSize: 14,
                  color: nxtbusDarkText,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: nxtbusLightText)),
        const SizedBox(height: 2),
        Text(time,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: nxtbusDarkText)),
      ],
    );
  }
}