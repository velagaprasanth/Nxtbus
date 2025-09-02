import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/seats_service.dart';

class SeatsPage extends StatefulWidget {
  final String busId; // pass busId when navigating

  const SeatsPage({super.key, required this.busId});

  @override
  State<SeatsPage> createState() => _SeatsPageState();
}

class _SeatsPageState extends State<SeatsPage> {
  final SeatsService seatsService = SeatsService();
  Map<String, dynamic> seats = {};
  final int rows = 5; // adjust as needed
  final int columns = 4; // adjust as needed

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    final existingSeats = await seatsService.getSeats(widget.busId);

    if (existingSeats.isEmpty) {
      // if no seats exist → create seats
      await seatsService.createSeats(widget.busId, rows, columns);
      seats = await seatsService.getSeats(widget.busId);
    } else {
      seats = existingSeats;
    }

    setState(() {});
  }

  Future<void> _bookSeat(String seatId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "guest";

    final success =
        await seatsService.bookSeat(widget.busId, seatId, userId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "Seat $seatId booked!"
            : "Seat $seatId already booked!"),
      ),
    );

    _loadSeats(); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    if (seats.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final seatIds = seats.keys.toList();
    seatIds.sort();

    return Scaffold(
      appBar: AppBar(title: const Text("Bus Seats")),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: seatIds.length,
        itemBuilder: (context, index) {
          final seatId = seatIds[index];
          final booked = seats[seatId]["booked"] == true;

          return GestureDetector(
            onTap: booked ? null : () => _bookSeat(seatId),
            child: Container(
              decoration: BoxDecoration(
                color: booked ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  seatId,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
