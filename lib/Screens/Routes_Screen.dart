import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTANT ---
// For this to work, you need to have a file named 'seat_selection_page.dart'
// with the code I'm providing below this section.



// --- Color Palette inspired by NXTBus image ---
const Color nxtbusPrimaryBlue = Color(0xFF1E88E5); // A vibrant blue
const Color nxtbusDarkBlue = Color(0xFF1565C0);   // A darker shade for gradients
const Color nxtbusAccentBlue = Color(0xFF42A5F5); // Lighter blue for accents
const Color nxtbusDarkText = Color(0xFF212121);
const Color nxtbusLightText = Color(0xFF757575);
const Color whiteColor = Colors.white;
const Color nxtbusBackgroundGrey = Color(0xFFF0F2F5); // Soft background grey
const Color nxtbusCardShadow = Color(0x20000000); // Subtle shadow

// ######################################################################
// # 1. BUS SEARCH PAGE (UPDATED WITH NAVIGATION)                       #
// ######################################################################

class BusSearchPage extends StatefulWidget {
  const BusSearchPage({super.key});

  @override
  State<BusSearchPage> createState() => _BusSearchPageState();
}

class _BusSearchPageState extends State<BusSearchPage> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  bool _isLoading = false;
  List<DocumentSnapshot> _busResults = [];
  bool _searchPerformed = false;

  Future<void> _searchBuses() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both "From" and "To" locations.'),
          backgroundColor: nxtbusAccentBlue,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _searchPerformed = true;
      _busResults = [];
    });

    final String fromLocation = _fromController.text.trim().toLowerCase();
    final String toLocation = _toController.text.trim().toLowerCase();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('buses')
          .where('from_location', isEqualTo: fromLocation)
          .where('to_location', isEqualTo: toLocation)
          .get();

      setState(() {
        _busResults = querySnapshot.docs;
      });
    } catch (e) {
      print("Firebase Query Error: $e"); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: nxtbusBackgroundGrey,
      appBar: AppBar(
        title: const Text('Find Your Ride',
            style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold)),
        backgroundColor: nxtbusPrimaryBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: whiteColor), // For back button if any
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [nxtbusPrimaryBlue, nxtbusAccentBlue],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              _buildSearchCard(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: nxtbusPrimaryBlue))
                    : _buildResultsList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
      child: Card(
        elevation: 8,
        shadowColor: nxtbusCardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildLocationTextField(
                  controller: _fromController,
                  label: 'From',
                  hint: 'Starting point',
                  icon: Icons.my_location),
              const SizedBox(height: 15),
              _buildLocationTextField(
                  controller: _toController,
                  label: 'To',
                  hint: 'Destination',
                  icon: Icons.location_on),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [nxtbusPrimaryBlue, nxtbusAccentBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: nxtbusCardShadow.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _searchBuses,
                  icon: const Icon(Icons.search, color: whiteColor),
                  label: const Text(
                    'Search Buses',
                    style: TextStyle(
                        fontSize: 18,
                        color: whiteColor,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationTextField(
      {required TextEditingController controller,
      required String label,
      required String hint,
      required IconData icon}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: nxtbusDarkText, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: nxtbusLightText),
        hintStyle: TextStyle(color: nxtbusLightText.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: nxtbusPrimaryBlue),
        filled: true,
        fillColor: nxtbusBackgroundGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: nxtbusPrimaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      ),
    );
  }

  Widget _buildResultsList() {
    if (!_searchPerformed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bus_filled, size: 80, color: nxtbusAccentBlue.withOpacity(0.6)),
            const SizedBox(height: 16),
            const Text(
              'Enter your route to find available buses',
              style: TextStyle(fontSize: 18, color: nxtbusLightText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (_busResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 80, color: nxtbusLightText.withOpacity(0.6)),
            const SizedBox(height: 16),
            const Text(
              'No buses found for this route.\nPlease try a different search.',
              style: TextStyle(fontSize: 18, color: nxtbusLightText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _busResults.length,
      itemBuilder: (context, index) {
        // --- MODIFICATION FOR NAVIGATION ---
        final busDoc = _busResults[index];
        final busData = busDoc.data() as Map<String, dynamic>;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeatSelectionPage(
                  busId: busDoc.id,
                  busData: busData,
                ),
              ),
            );
          },
          child: BusResultCard(busData: busData),
        );
        // --- END OF MODIFICATION ---
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.8);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 3 / 4, size.height * 0.6);
    var secondEndPoint = Offset(size.width, size.height * 0.9);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BusResultCard extends StatelessWidget {
  final Map<String, dynamic> busData;

  const BusResultCard({super.key, required this.busData});

  @override
  Widget build(BuildContext context) {
    final priceMap = busData['price'] as Map<String, dynamic>? ?? {};
    final priceAmount = priceMap['amount']?.toString() ?? 'N/A';
    final busType = busData['bus_type'] ?? 'Not Specified';
    final seatsAvailable = busData['seats_available'] ?? 0;
    final departureTime = busData['departure_time'] ?? '--:--';
    final arrivalTime = busData['arrival_time'] ?? '--:--';


    IconData busTypeIcon;
    if (busType.toLowerCase().contains('sleeper')) {
      busTypeIcon = Icons.king_bed;
    } else if (busType.toLowerCase().contains('ac')) {
      busTypeIcon = Icons.ac_unit;
    } else {
      busTypeIcon = Icons.event_seat;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 6,
      shadowColor: nxtbusCardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    busData['name'] ?? 'Unknown Bus',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: nxtbusDarkText),
                    overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(busTypeIcon, size: 18, color: nxtbusLightText),
                const SizedBox(width: 8),
                Text(busType,
                    style:
                        const TextStyle(fontSize: 14, color: nxtbusLightText)),
              ],
            ),
            const Divider(height: 28, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeInfo('Departure', departureTime,
                    icon: Icons.timer),
                const Icon(Icons.arrow_right_alt,
                    color: nxtbusLightText, size: 30),
                _buildTimeInfo('Arrival', arrivalTime,
                    alignRight: true, icon: Icons.access_time),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.airline_seat_recline_extra, size: 18, color: nxtbusDarkText),
                const SizedBox(width: 8),
                Text('Seats Available: $seatsAvailable',
                    style: const TextStyle(
                        fontSize: 14,
                        color: nxtbusDarkText,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time,
      {bool alignRight = false, required IconData icon}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: nxtbusLightText)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (!alignRight) ...[
              Icon(icon, size: 16, color: nxtbusDarkText),
              const SizedBox(width: 4),
            ],
            Text(time,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: nxtbusDarkText)),
            if (alignRight) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: nxtbusDarkText),
            ],
          ],
        ),
      ],
    );
  }
}


// ######################################################################
// # 2. SEAT SELECTION PAGE (NEW FILE: seat_selection_page.dart)        #
// ######################################################################

class SeatModel {
  final String seatNumber;
  final double price;
  final String type;
  final bool isAvailable;
  bool isSelected;

  SeatModel({
    required this.seatNumber,
    required this.price,
    this.type = 'seater',
    this.isAvailable = true,
    this.isSelected = false,
  });
}

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
  List<SeatModel> _seats = [];
  List<SeatModel> _selectedSeats = [];
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    // TODO: In a real app, you MUST replace this with a Firestore call.
    // Fetch the specific seat layout for the bus using `widget.busId`.
    // For example: FirebaseFirestore.instance.collection('buses').doc(widget.busId).collection('seats').get()
    _seats = _generateMockSeats();
  }

  List<SeatModel> _generateMockSeats() {
     return List.generate(35, (index) {
      int col = index % 5;
      int row = index ~/ 5;

      if (col == 2) return SeatModel(seatNumber: '', price: 0, type: 'aisle', isAvailable: false);
      if (index == 4) return SeatModel(seatNumber: '', price: 0, type: 'driver', isAvailable: false);

      String seatNum = '';
      String type = 'seater';
      double price = 949.0;
      bool isAvailable = true;

      if (col == 0 || col == 1) {
        type = 'sleeper';
        seatNum = 'SL${row * 2 + col + 1}';
        price = 1149.0;
      } else if (col == 3) {
        seatNum = 'DL${row + 1}';
      } else if (col == 4) {
        seatNum = 'DL${row + 8}'; // Just an example for layout
      }
      
      if (index == 5 || index == 17 || index == 2) isAvailable = false;

      return SeatModel(seatNumber: seatNum, price: price, type: type, isAvailable: isAvailable);
    });
  }

  void _onSeatTapped(SeatModel seat) {
    if (!seat.isAvailable) return;

    setState(() {
      seat.isSelected = !seat.isSelected;
      if (seat.isSelected) {
        _selectedSeats.add(seat);
        _totalPrice += seat.price;
      } else {
        _selectedSeats.remove(seat);
        _totalPrice -= seat.price;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildSeatLayout()),
          _buildBottomBar(),
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

  Widget _buildSeatLayout() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        itemCount: _seats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final seat = _seats[index];

          if (seat.type == 'aisle') return const SizedBox.shrink();
          if (seat.type == 'driver') return const Icon(Icons.bus_alert, size: 36, color: Colors.grey);
          
          return SeatWidget(
            seat: seat,
            onTap: () => _onSeatTapped(seat),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedSeats.map((s) => s.seatNumber).join(', '),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _selectedSeats.isNotEmpty ? () { /* TODO: Handle booking confirmation */ } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('CONTINUE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class SeatWidget extends StatelessWidget {
  final SeatModel seat;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.seat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = seat.isSelected ? Colors.green : Colors.grey.shade400;
    Color backgroundColor = Colors.white;

    if (seat.isSelected) {
      backgroundColor = Colors.green;
    } else if (!seat.isAvailable) {
      backgroundColor = Colors.grey.shade300;
      borderColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: seat.type == 'sleeper' ? 60 : 40, // Sleeper seats are taller
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(seat.type == 'sleeper' ? 8 : 6),
        ),
        child: Center(
          child: Text(
            seat.seatNumber,
            style: TextStyle(
              color: seat.isSelected ? Colors.white : seat.isAvailable ? Colors.black : Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
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
    return Row(
      children: [
        if (color == Colors.white)
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4)
            ),
          )
        else
          Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}