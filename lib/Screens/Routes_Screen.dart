import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nxtbus/Other/Seat_Screen.dart';

/// ---------- COLORS ----------
const Color nxtbusPrimaryBlue = Color(0xFF1E88E5);
const Color nxtbusAccentBlue = Color(0xFF42A5F5);
const Color nxtbusDarkText = Color(0xFF212121);
const Color nxtbusLightText = Color(0xFF757575);

/// ---------- MAIN SCREEN ----------
class NxtBusScreen extends StatefulWidget {
  @override
  _NxtBusScreenState createState() => _NxtBusScreenState();
}

class _NxtBusScreenState extends State<NxtBusScreen> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  bool _isLoading = false;
  bool _searchPerformed = false;
  List<DocumentSnapshot> _busResults = [];

  /// Swap locations
  void _swapLocations() {
    final tmp = _fromController.text;
    setState(() {
      _fromController.text = _toController.text;
      _toController.text = tmp;
    });
  }

  /// Pick journey date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  /// Firestore bus search
  Future<void> _searchBuses() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter both From and To')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _searchPerformed = true;
      _busResults = [];
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('buses')
          .where('from_location',
              isEqualTo: _fromController.text.trim().toLowerCase())
          .where('to_location',
              isEqualTo: _toController.text.trim().toLowerCase())
          .get();

      setState(() => _busResults = querySnapshot.docs);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildRouteSelector(),
                const SizedBox(height: 16),
                _buildDateSelector(),
                const SizedBox(height: 24),
                _buildSearchButton(),
                const SizedBox(height: 24),
                _buildResultsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: const [
        Text("NXT", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        Text("Bus",
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: nxtbusPrimaryBlue)),
      ],
    );
  }

  Widget _buildRouteSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildLocationRow("From", _fromController),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], height: 1)),
              GestureDetector(
                onTap: _swapLocations,
                child: CircleAvatar(
                  backgroundColor: nxtbusPrimaryBlue,
                  child: const Icon(Icons.swap_vert, color: Colors.white),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], height: 1)),
            ],
          ),
          _buildLocationRow("To", _toController),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final datesToShow =
        List.generate(5, (i) => selectedDate.add(Duration(days: i)));

    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: datesToShow.map((date) {
                  final isSelected =
                      date.day == selectedDate.day &&
                          date.month == selectedDate.month;
                  return GestureDetector(
                    onTap: () => setState(() => selectedDate = date),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? nxtbusPrimaryBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(DateFormat("d MMM").format(date),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
            ),
            Text(DateFormat("MMM").format(selectedDate),
                style: const TextStyle(color: nxtbusAccentBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _searchBuses,
      style: ElevatedButton.styleFrom(
        backgroundColor: nxtbusPrimaryBlue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("Search Buses",
          style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  Widget _buildResultsList() {
    if (!_searchPerformed) return const SizedBox.shrink();
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_busResults.isEmpty) {
      return const Text("No buses found.",
          textAlign: TextAlign.center, style: TextStyle(color: nxtbusLightText));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _busResults.length,
      itemBuilder: (context, i) {
        final busDoc = _busResults[i];
        final busData = busDoc.data() as Map<String, dynamic>;
        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeatsPage(busId: busDoc.id, busData: busData, from: '', to: '', date: ''),
            ),
          ),
          child: BusResultCard(busData: busData),
        );
      },
    );
  }
}

/// ---------- BUS RESULT CARD ----------
class BusResultCard extends StatelessWidget {
  final Map<String, dynamic> busData;
  const BusResultCard({super.key, required this.busData});

  @override
  Widget build(BuildContext context) {
    final price = busData['price']?['amount'] ?? "N/A";
    final type = busData['bus_type'] ?? "Unknown";
    final departure = busData['departure_time'] ?? "--:--";
    final arrival = busData['arrival_time'] ?? "--:--";
    final seats = busData['seats_available'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(busData['name'] ?? "Bus"),
        subtitle: Text("$type  |  Seats: $seats\n$departure → $arrival"),
        trailing: Text("₹$price",
            style: const TextStyle(
                color: nxtbusPrimaryBlue, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// ---------- SEAT SELECTION PAGE (shortened for demo) ----------
class SeatSelectionPage extends StatelessWidget {
  final String busId;
  final Map<String, dynamic> busData;

  const SeatSelectionPage({super.key, required this.busId, required this.busData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(busData['name'] ?? "Seats")),
      body: const Center(child: Text("Seat layout goes here...")),
    );
  }
}
