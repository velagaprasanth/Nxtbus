
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class YoloBusScreen extends StatefulWidget {
  @override
  _YoloBusScreenState createState() => _YoloBusScreenState();
}

class _YoloBusScreenState extends State<YoloBusScreen> {
  // State variable to hold the selected date.
  // Using a fixed date for consistent demonstration.
  DateTime selectedDate = DateTime(2025, 8, 27);

  // State variables for the TextFields
  late TextEditingController _fromController;
  late TextEditingController _toController;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController();
    _toController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  // A method that modifies the state
  void _swapLocations() {
    final String fromText = _fromController.text;
    // setState notifies Flutter to rebuild the UI with the new state
    setState(() {
      _fromController.text = _toController.text;
      _toController.text = fromText;
    });
  }

  // An async method that modifies the state
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != selectedDate) {
      // setState notifies Flutter to rebuild the UI with the new date
      setState(() {
        selectedDate = picked;
      });
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
                SizedBox(height: 24),
                _buildHeader(),
                SizedBox(height: 32),
                _buildOffersSection(),
                SizedBox(height: 32),
                _buildFeaturesSection(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('NXT', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
            Text('Bus', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
        SizedBox(height: 24),
        Text('Book your Journey', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 24),
        _buildRouteSelector(),
        SizedBox(height: 24),
        _buildDateSelector(),
        SizedBox(height: 24),
        _buildSearchButton(),
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
          _buildLocationRow(hintText: 'Hyderabad', controller: _fromController),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], height: 1)),
              GestureDetector(
                onTap: _swapLocations,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4)),
                  child: Icon(Icons.swap_vert, color: Colors.white, size: 20),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], height: 1)),
            ],
          ),
          _buildLocationRow(hintText: 'Chebrolu', controller: _toController),
        ],
      ),
    );
  }

  Widget _buildLocationRow({required String hintText, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
            child: Icon(Icons.location_on, size: 14, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              cursorColor: Colors.blue,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[400]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final List<DateTime> datesToShow = List.generate(5, (index) => selectedDate.add(Duration(days: index)));

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: datesToShow.map((date) {
                    final bool isSelected = date.day == selectedDate.day && date.month == selectedDate.month && date.year == selectedDate.year;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('d MMM').format(date),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Text(
              '${DateFormat('MMM').format(selectedDate)} ▼',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    // This SizedBox wrapper ensures the ElevatedButton takes the full available width.
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final from = _fromController.text;
          final to = _toController.text;
          final date = DateFormat('yyyy-MM-dd').format(selectedDate);
          print('Searching buses from: $from, to: $to on $date');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.4),
        ),
        child: Text(
          'Search Buses',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Discounts & Offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 16),
        Container(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            children: [
              _buildDiscountCard1(),
              _buildDiscountCard2(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountCard1() {
    return Container(
      width: 300,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text('Yolo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text('Bus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                SizedBox(height: 4),
                Text('Flat 25%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                Text('Discount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue[700])),
                SizedBox(height: 4),
                Text('on all bookings', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade300, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text('Coupon Code', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    Text('RAIN25', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDiscountCard2() {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[50]!, Colors.red[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text('Spree', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
          ),
          SizedBox(height: 8),
          Text('Enjoy 10% Off', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          Text('on your stay', maxLines: 2, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
            child: Text('Use Code YOLOBUS', style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      children: [
        Text('Safe, Hygienic & Luxurious Travel!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87), textAlign: TextAlign.center),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFeatureItem(icon: Icons.cleaning_services, label: 'Sanitized', color: Colors.blue),
            _buildFeatureItem(icon: Icons.support_agent, label: '24/7 Help', color: Colors.green),
            _buildFeatureItem(icon: Icons.verified_user, label: 'Verified', color: Colors.blue),
            _buildFeatureItem(icon: Icons.chair, label: 'Comfort', color: Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}