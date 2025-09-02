import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/seats_model_screen.dart';
import '../providers/seat_selection_provider.dart';

class SeatSelectionPage extends StatefulWidget {
  final String busId;
  final Map<String, dynamic> busData;

  const SeatSelectionPage({
    super.key,
    required this.busId,
    required this.busData,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    // fetch once if not already in cache
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeatSelectionProvider>().fetchSeatsForBus(widget.busId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeatSelectionProvider>();

    final seats = provider.getSeatsForBus(widget.busId);
    final selectedSeats = provider.getSelectedSeatsForBus(widget.busId);
    final totalPrice = provider.getTotalPriceForBus(widget.busId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.busData['name'] ?? 'Select Seats',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: seats.isEmpty
                      ? const Center(child: Text("No seat layout found."))
                      : _buildSeatLayout(seats, provider),
                ),
                _buildBottomBar(selectedSeats, totalPrice),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.grey[200],
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SeatInfoLabel(icon: Icons.square_rounded, color: Colors.grey, text: 'Booked'),
          _SeatInfoLabel(icon: Icons.square_rounded, color: Colors.white, text: 'Available'),
          _SeatInfoLabel(icon: Icons.square_rounded, color: Colors.green, text: 'Selected'),
        ],
      ),
    );
  }

  Widget _buildSeatLayout(List<SeatModel> seats, SeatSelectionProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        itemCount: seats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final seat = seats[index];
          if (seat.type == 'aisle') return const SizedBox.shrink();
          if (seat.type == 'driver') {
            return const Icon(Icons.bus_alert, size: 36, color: Colors.grey);
          }

          return SeatWidget(
            seat: seat,
            onTap: () {
              provider.toggleSeatSelection(widget.busId, seat.docId);
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(List<SeatModel> selectedSeats, double totalPrice) {
    final selectedSeatNumbers = selectedSeats.map((s) => s.seatNumber).join(', ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedSeatNumbers.isEmpty ? "No seats selected" : selectedSeatNumbers,
                  style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: totalPrice > 0 && !_isBooking
                ? () {
                    context.go('/booking', extra: {
                      'busId': widget.busId,
                      'busData': widget.busData,
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: _isBooking
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : const Text('CONTINUE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class SeatWidget extends StatelessWidget {
  final SeatModel seat;
  final VoidCallback onTap;

  const SeatWidget({super.key, required this.seat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade400;
    Color textColor = Colors.black;

    if (seat.isSelectedByCurrentUser) {
      backgroundColor = Colors.green;
      borderColor = Colors.green;
      textColor = Colors.white;
    } else if (seat.status == 'booked') {
      backgroundColor = Colors.grey.shade300;
      borderColor = Colors.grey.shade300;
      textColor = Colors.grey.shade500;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: seat.type == 'sleeper' ? 60 : 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(seat.type == 'sleeper' ? 8 : 6),
        ),
        child: Center(
          child: Text(
            seat.seatNumber,
            style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _SeatInfoLabel extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _SeatInfoLabel({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (color == Colors.white)
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
        )
      else
        Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(text),
    ]);
  }
}
