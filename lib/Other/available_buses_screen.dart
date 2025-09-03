import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nxtbus/Other/Seat_Screen.dart';

// Color Palette matching your NXTBus design
const Color nxtbusPrimaryBlue = Color(0xFF1E88E5);
const Color nxtbusDarkText = Color(0xFF212121);
const Color nxtbusLightText = Color(0xFF757575);
const Color white = Colors.white;

class AvailableBusesScreen extends StatefulWidget {
  final String from;
  final String to;
  final String date;

  const AvailableBusesScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
  });

  @override
  State<AvailableBusesScreen> createState() => _AvailableBusesScreenState();
}

class _AvailableBusesScreenState extends State<AvailableBusesScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> _busResults = [];
  String _selectedSortOption = 'departure';

  @override
  void initState() {
    super.initState();
    _fetchBuses();
  }

  Future<void> _fetchBuses() async {
    setState(() => _isLoading = true);
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('buses')
          .where('from_location', isEqualTo: widget.from.toLowerCase())
          .where('to_location', isEqualTo: widget.to.toLowerCase())
          .get();

      setState(() {
        _busResults = querySnapshot.docs;
        _sortBuses();
      });
    } catch (e) {
      debugPrint("Error fetching buses: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading buses: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sortBuses() {
    _busResults.sort((a, b) {
      final busA = a.data() as Map<String, dynamic>;
      final busB = b.data() as Map<String, dynamic>;

      switch (_selectedSortOption) {
        case 'price':
          final priceA = busA['price']?['amount'] ?? 0;
          final priceB = busB['price']?['amount'] ?? 0;
          return priceA.compareTo(priceB);
        case 'departure':
          final depA = busA['departure_time'] ?? '';
          final depB = busB['departure_time'] ?? '';
          return depA.compareTo(depB);
        case 'seats':
          final seatsA = busA['seats_available'] ?? 0;
          final seatsB = busB['seats_available'] ?? 0;
          return seatsB.compareTo(seatsA);
        default:
          return 0;
      }
    });
  }

  void _navigateToSeatSelection(Map<String, dynamic> busData, String busId) {
    // Navigate to seat selection page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>SeatsPage(
          busData: busData,
          busId: busId, from: '', to: '', date: '',
          
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${widget.from} → ${widget.to}',
          style: const TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: nxtbusPrimaryBlue,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Date and Filter Header
          Container(
            color: nxtbusPrimaryBlue,
            child: Container(
              margin: const EdgeInsets.only(top: 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Trip Info
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: nxtbusPrimaryBlue, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('EEE, MMM dd').format(DateTime.parse(widget.date)),
                                style: TextStyle(
                                  color: nxtbusDarkText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_busResults.length} buses found',
                                style: TextStyle(
                                  color: nxtbusLightText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Sort Options
                  Row(
                    children: [
                      Text(
                        'Sort by:',
                        style: TextStyle(
                          color: nxtbusLightText,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            _buildSortChip('Departure', 'departure'),
                            const SizedBox(width: 8),
                            _buildSortChip('Price', 'price'),
                            const SizedBox(width: 8),
                            _buildSortChip('Seats', 'seats'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Bus List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: nxtbusPrimaryBlue),
                        SizedBox(height: 16),
                        Text('Finding buses for you...'),
                      ],
                    ),
                  )
                : _busResults.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchBuses,
                        color: nxtbusPrimaryBlue,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _busResults.length,
                          itemBuilder: (context, index) {
                            final bus = _busResults[index].data() as Map<String, dynamic>;
                            final busId = _busResults[index].id;
                            return _buildBusCard(bus, busId);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _selectedSortOption == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSortOption = value;
          _sortBuses();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? nxtbusPrimaryBlue : white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? nxtbusPrimaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? white : nxtbusLightText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No buses found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: nxtbusDarkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for a different route or date',
            style: TextStyle(
              color: nxtbusLightText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.search, color: white),
            label: const Text('Search Again', style: TextStyle(color: white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: nxtbusPrimaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusCard(Map<String, dynamic> bus, String busId) {
    final price = bus['price']?['amount']?.toString() ?? 'N/A';
    final seatsAvailable = bus['seats_available']?.toString() ?? '0';
    final tags = bus['tags'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToSeatSelection(bus, busId),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bus Name and Type
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bus['name'] ?? 'Bus Service',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: nxtbusDarkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bus['bus_type'] ?? 'Standard Bus',
                            style: TextStyle(
                              color: nxtbusLightText,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$seatsAvailable seats',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Time and Route
                Row(
                  children: [
                    // Departure
                    Column(
                      children: [
                        Text(
                          bus['departure_time'] ?? '--:--',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: nxtbusDarkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.from,
                          style: TextStyle(
                            color: nxtbusLightText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Route Line
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: nxtbusPrimaryBlue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: nxtbusPrimaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color: nxtbusPrimaryBlue.withOpacity(0.3),
                                  ),
                                ),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: nxtbusPrimaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _calculateDuration(
                              bus['departure_time'] ?? '',
                              bus['arrival_time'] ?? '',
                            ),
                            style: TextStyle(
                              color: nxtbusLightText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Arrival
                    Column(
                      children: [
                        Text(
                          bus['arrival_time'] ?? '--:--',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: nxtbusDarkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.to,
                          style: TextStyle(
                            color: nxtbusLightText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Tags and Price
                Row(
                  children: [
                    Expanded(
                      child: tags.isNotEmpty
                          ? Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: tags.take(3).map((tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: nxtbusPrimaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag.toString(),
                                  style: TextStyle(
                                    color: nxtbusPrimaryBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )).toList(),
                            )
                          : const SizedBox(),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹$price',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: nxtbusPrimaryBlue,
                          ),
                        ),
                        Text(
                          'per seat',
                          style: TextStyle(
                            color: nxtbusLightText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Action Button
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SELECT SEATS',
                      style: TextStyle(
                        color: nxtbusPrimaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: nxtbusPrimaryBlue,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _calculateDuration(String departure, String arrival) {
    try {
      if (departure.isEmpty || arrival.isEmpty) return '--h --m';
      
      final depTime = TimeOfDay.fromDateTime(DateFormat.jm().parse(departure));
      final arrTime = TimeOfDay.fromDateTime(DateFormat.jm().parse(arrival));
      
      int depMinutes = depTime.hour * 60 + depTime.minute;
      int arrMinutes = arrTime.hour * 60 + arrTime.minute;
      
      // Handle next day arrival
      if (arrMinutes < depMinutes) {
        arrMinutes += 24 * 60;
      }
      
      final duration = arrMinutes - depMinutes;
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      
      return '${hours}h ${minutes}m';
    } catch (e) {
      return '--h --m';
    }
  }
}

// Placeholder for Seat Selection Page
class SeatSelectionPage extends StatelessWidget {
  final Map<String, dynamic> busData;
  final String busId;
  final String from;
  final String to;
  final String date;

  const SeatSelectionPage({
    super.key,
    required this.busData,
    required this.busId,
    required this.from,
    required this.to,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seats', style: TextStyle(color: white)),
        backgroundColor: nxtbusPrimaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_seat, size: 64, color: nxtbusPrimaryBlue),
            const SizedBox(height: 16),
            Text(
              'Seat Selection Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: nxtbusDarkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bus: ${busData['name']}',
              style: TextStyle(color: nxtbusLightText),
            ),
            Text(
              'Route: $from → $to',
              style: TextStyle(color: nxtbusLightText),
            ),
            Text(
              'Date: $date',
              style: TextStyle(color: nxtbusLightText),
            ),
            const SizedBox(height: 24),
            Text(
              'Implement your seat selection UI here',
              style: TextStyle(color: nxtbusLightText, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}