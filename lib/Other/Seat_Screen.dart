import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/seats_service.dart';
import 'payment_screen.dart'; // Razorpay checkout page

class SeatsPage extends StatefulWidget {
  final String busId;

  const SeatsPage({super.key, required this.busId, required Map<String, dynamic> busData, required String from, required String to, required String date});

  @override
  State<SeatsPage> createState() => _SeatsPageState();
}

class _SeatsPageState extends State<SeatsPage> with TickerProviderStateMixin {
  final SeatsService seatsService = SeatsService();
  Map<String, dynamic> seats = {};
  List<String> selectedSeats = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadSeats();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadSeats() async {
    final existingSeats = await seatsService.getSeats(widget.busId);
    if (existingSeats.isEmpty) {
      await seatsService.createSeats(widget.busId, 6, 4);
      seats = await seatsService.getSeats(widget.busId);
    } else {
      seats = existingSeats;
    }
    setState(() {});
    _slideController.forward();
  }

  Color _getSeatColor(String id, bool booked, bool isSelected) {
    if (isSelected) return Color(0xFF0EA5E9); // Sky blue from image
    if (booked) return Color(0xFFCBD5E1);
    return Color(0xFFF8FAFC);
  }

  Color _getSeatAccentColor(String id, bool booked, bool isSelected) {
    if (isSelected) return Color(0xFF0284C7); // Darker blue
    if (booked) return Color(0xFF94A3B8);
    return Color(0xFF38BDF8); // Light blue accent
  }

  int _getSeatPrice(String id) {
    final num = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return (num % 3 == 1) ? 649 : (num % 3 == 2 ? 699 : 799);
  }

  bool _isWindowSeat(String id) {
    final row = int.tryParse(id.substring(0, 1)) ?? 0;
    final col = id.substring(1);
    return col == 'A' || col == 'D';
  }

  Widget _buildSeat(String id) {
    final booked = seats[id]['booked'] == true;
    final selected = selectedSeats.contains(id);
    final isWindow = _isWindowSeat(id);
    final price = _getSeatPrice(id);

    return GestureDetector(
      onTap: booked ? null : () {
        setState(() {
          if (selected) {
            selectedSeats.remove(id);
          } else {
            selectedSeats.add(id);
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.all(4),
        child: Container(
          width: 58,
          height: 65,
          child: Stack(
            children: [
              // Seat shadow/base
              Positioned(
                bottom: 0,
                left: 2,
                right: 2,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              
              // Main seat body
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: selected 
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
                        )
                      : booked
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                          )
                        : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Color(0xFFF8FAFC)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected 
                        ? Color(0xFF0284C7)
                        : booked 
                          ? Color(0xFF94A3B8)
                          : Color(0xFF38BDF8).withOpacity(0.3),
                      width: selected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      if (selected) ...[
                        BoxShadow(
                          color: Color(0xFF0EA5E9).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: Offset(0, 4),
                        ),
                      ] else ...[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Seat cushion details
                      Positioned(
                        bottom: 6,
                        left: 6,
                        right: 6,
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: selected 
                              ? Colors.white.withOpacity(0.15)
                              : booked 
                                ? Colors.black.withOpacity(0.05)
                                : Color(0xFF38BDF8).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected 
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
                      
                      // Seat headrest
                      Positioned(
                        top: 4,
                        left: 8,
                        right: 8,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: selected 
                              ? Colors.white.withOpacity(0.2)
                              : booked 
                                ? Colors.black.withOpacity(0.1)
                                : Color(0xFF38BDF8).withOpacity(0.1),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                          ),
                        ),
                      ),
                      
                      // Seat content
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                id,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: selected 
                                    ? Colors.white
                                    : booked 
                                      ? Color(0xFF64748B)
                                      : Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 2),
                              if (!booked) ...[
                                Text(
                                  '₹$price',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: selected 
                                      ? Colors.white.withOpacity(0.9)
                                      : Color(0xFF0EA5E9),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      // Window indicator
                      if (isWindow)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Icon(
                              Icons.wb_sunny_outlined,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      
                      // Selection indicator
                      if (selected)
                        Positioned(
                          top: 2,
                          left: 2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Color(0xFF0EA5E9),
                            ),
                          ),
                        ),
                      
                      // Booked overlay
                      if (booked)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusLayout() {
    final keys = seats.keys.toList()..sort();
    final rows = <String, List<String>>{};
    
    // Group seats by row
    for (String key in keys) {
      final row = key.substring(0, 1);
      if (!rows.containsKey(row)) rows[row] = [];
      rows[row]!.add(key);
    }

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE2E8F0), width: 2),
      ),
      child: Column(
        children: [
          // Bus front
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.airline_seat_recline_normal, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'DRIVER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.white.withOpacity(0.5), Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Seats area
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Aisle label
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            'Window',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Aisle',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            'Window',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Seats rows
                ...rows.entries.map((entry) {
                  final rowSeats = entry.value..sort();
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        // Left side (A, B)
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              if (rowSeats.length > 0) Expanded(child: _buildSeat(rowSeats[0])),
                              if (rowSeats.length > 1) Expanded(child: _buildSeat(rowSeats[1])),
                            ],
                          ),
                        ),
                        // Aisle
                        Expanded(
                          child: Container(
                            height: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 2,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFE2E8F0),
                                        Color(0xFFCBD5E1),
                                        Color(0xFFE2E8F0),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right side (C, D)
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              if (rowSeats.length > 2) Expanded(child: _buildSeat(rowSeats[2])),
                              if (rowSeats.length > 3) Expanded(child: _buildSeat(rowSeats[3])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seat Guide',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLegendItem('Available', Color(0xFFE2E8F0), Color(0xFF64748B), Icons.event_seat_outlined)),
              Expanded(child: _buildLegendItem('Your Choice', Color(0xFF4F46E5), Colors.white, Icons.check_circle)),
              Expanded(child: _buildLegendItem('Taken', Color(0xFF94A3B8), Colors.white, Icons.block)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.window, size: 14, color: Color(0xFF0EA5E9)),
              SizedBox(width: 6),
              Text(
                'Window seats marked with blue icon',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color bgColor, Color textColor, IconData icon) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 36,
          decoration: BoxDecoration(
            gradient: label == 'Your Choice' 
              ? LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
                )
              : null,
            color: label == 'Your Choice' ? null : bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: label == 'Your Choice' 
                ? Color(0xFF0284C7)
                : Color(0xFFCBD5E1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Seat back simulation
              Positioned(
                top: 2,
                left: 2,
                right: 2,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: label == 'Your Choice' 
                      ? Colors.white.withOpacity(0.3)
                      : label == 'Taken'
                        ? Color(0xFF94A3B8)
                        : Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ),
              // Seat cushion
              Positioned(
                bottom: 2,
                left: 2,
                right: 2,
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: label == 'Your Choice' 
                      ? Colors.white.withOpacity(0.9)
                      : label == 'Taken'
                        ? Colors.white.withOpacity(0.7)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 12,
                      color: label == 'Your Choice' 
                        ? Color(0xFF0EA5E9)
                        : label == 'Taken'
                          ? Color(0xFF64748B)
                          : Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSelectionSummary() {
    if (selectedSeats.isEmpty) return SizedBox.shrink();
    
    final total = selectedSeats.fold(0, (sum, id) => sum + _getSeatPrice(id));
    final windowSeats = selectedSeats.where(_isWindowSeat).length;
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.confirmation_number, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Your Selection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: selectedSeats.map((seat) => Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isWindowSeat(seat)) ...[
                    Icon(Icons.window, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                  ],
                  Text(
                    seat,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              if (windowSeats > 0) ...[
                Icon(Icons.window, color: Colors.white.withOpacity(0.8), size: 16),
                SizedBox(width: 4),
                Text(
                  '$windowSeats window seat${windowSeats > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 16),
              ],
              Icon(Icons.currency_rupee, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                '$total total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Your Seats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              'Tap to choose your preferred seats',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1E293B)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: seats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading your bus...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          : SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildBusLayout(),
                          _buildLegend(),
                          _buildSelectionSummary(),
                          SizedBox(height: 100), // Space for bottom bar
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: selectedSeats.isNotEmpty ? _buildBottomActionBar() : null,
    );
  }

  Widget _buildBottomActionBar() {
    final total = selectedSeats.fold(0, (sum, id) => sum + _getSeatPrice(id));
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''} selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '₹$total',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          amount: total,
                          selectedSeats: selectedSeats,
                          busId: widget.busId,
                        ),
                      ),
                    );

                    if (success == true) {
                      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
                      for (var id in selectedSeats) {
                        await seatsService.bookSeat(widget.busId, id, uid);
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Container(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.check, color: Colors.white, size: 16),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Booking Confirmed!',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Your ${selectedSeats.length} seat${selectedSeats.length > 1 ? 's have' : ' has'} been reserved',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          backgroundColor: Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.all(16),
                        ),
                      );
                      
                      selectedSeats.clear();
                      await _loadSeats();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0EA5E9),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: Color(0xFF0EA5E9).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.payment, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}