import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Color Palette based on the NXTBus image ---
const Color nxtbusPrimaryBlue = Color(0xFF1E88E5);
const Color nxtbusDarkText = Color(0xFF212121);
const Color nxtbusLightText = Color(0xFF757575);
const Color white = Colors.white;

class AddBusDetailsPage extends StatefulWidget {
  const AddBusDetailsPage({super.key});

  @override
  State<AddBusDetailsPage> createState() => _AddBusDetailsPageState();
}

class _AddBusDetailsPageState extends State<AddBusDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _fromLocationController = TextEditingController();
  final _toLocationController = TextEditingController();
  final _nameController = TextEditingController();
  final _busTypeController = TextEditingController();
  final _departureTimeController = TextEditingController();
  final _arrivalTimeController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsAvailableController = TextEditingController();
  final _berthInfoController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _fromLocationController.dispose();
    _toLocationController.dispose();
    _nameController.dispose();
    _busTypeController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    _priceController.dispose();
    _seatsAvailableController.dispose();
    _berthInfoController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Helper function to show Time Picker
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: nxtbusPrimaryBlue),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  // --- Submit form logic for FIREBASE (UPDATED WITH FIX) ---
  // In lib/add_bus_details_page.dart

void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving bus details...')),
    );

    try {
      final collection = FirebaseFirestore.instance.collection('buses');

      // --- THE FIX YOU SUGGESTED ---
      // We now convert the location data to lowercase before saving.
      final fromLocationFormatted = _fromLocationController.text.trim().toLowerCase();
      final toLocationFormatted = _toLocationController.text.trim().toLowerCase();
      // -----------------------------------------------------------

      final tagsList = _tagsController.text.isEmpty
          ? []
          : _tagsController.text.split(',').map((tag) => tag.trim()).toList();

      final busData = {
        "from_location": fromLocationFormatted, // <-- Use lowercase data
        "to_location": toLocationFormatted,   // <-- Use lowercase data
        "name": _nameController.text.trim(),
        "bus_type": _busTypeController.text.trim(),
        "departure_time": _departureTimeController.text.trim(),
        "arrival_time": _arrivalTimeController.text.trim(),
        "price": {
          "amount": double.tryParse(_priceController.text) ?? 0,
          "currency": "INR"
        },
        "seats_available": int.tryParse(_seatsAvailableController.text) ?? 0,
        "berth_info": _berthInfoController.text.trim(),
        "tags": tagsList,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await collection.add(busData);

      // (The rest of the function for success message and clearing fields stays the same)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bus details saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _formKey.currentState!.reset();
      _fromLocationController.clear();
      _toLocationController.clear();
      _nameController.clear();
      _busTypeController.clear();
      _departureTimeController.clear();
      _arrivalTimeController.clear();
      _priceController.clear();
      _seatsAvailableController.clear();
      _berthInfoController.clear();
      _tagsController.clear();

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving details: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: const Text('Add New Bus Route', style: TextStyle(color: white, fontWeight: FontWeight.bold)),
        backgroundColor: nxtbusPrimaryBlue,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    'https://res.cloudinary.com/dyv6tyill/image/upload/v1756305115/WhatsApp_Image_2025-08-27_at_19.59.01_f218938f_plrdwk.jpg',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Route Details'),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _fromLocationController, label: 'From', icon: Icons.trip_origin, hint: 'e.g., Hyderabad')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controller: _toLocationController, label: 'To', icon: Icons.location_on, hint: 'e.g., Bangalore')),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(controller: _nameController, label: 'Bus Operator Name', icon: Icons.directions_bus, hint: 'e.g., Orange Travels'),
                const SizedBox(height: 24),
                _buildSectionTitle('Trip & Booking Details'),
                _buildTextField(controller: _busTypeController, label: 'Bus Type', icon: Icons.category, hint: 'e.g., Volvo AC Sleeper'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTimeField(controller: _departureTimeController, label: 'Departure Time', icon: Icons.schedule)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimeField(controller: _arrivalTimeController, label: 'Arrival Time', icon: Icons.hourglass_empty)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _priceController, label: 'Price (INR)', icon: Icons.currency_rupee, keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controller: _seatsAvailableController, label: 'Seats Available', icon: Icons.event_seat_outlined, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(controller: _berthInfoController, label: 'Berth Information (Optional)', icon: Icons.bed_outlined, isRequired: false),
                const SizedBox(height: 16),
                _buildTextField(controller: _tagsController, label: 'Tags (Optional, comma separated)', icon: Icons.local_offer_outlined, isRequired: false),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: [nxtbusPrimaryBlue, Colors.blue.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(color: nxtbusPrimaryBlue.withOpacity(0.4), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add Bus to Database', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: nxtbusDarkText)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isRequired = true, TextInputType keyboardType = TextInputType.text, String? hint}) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: nxtbusDarkText),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: nxtbusLightText),
          hintStyle: TextStyle(color: nxtbusLightText.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: nxtbusPrimaryBlue),
          filled: true,
          fillColor: white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: nxtbusPrimaryBlue.withOpacity(0.6), width: 2)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.grey.shade200, width: 1)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.red, width: 1)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.red, width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTimeField({required TextEditingController controller, required String label, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectTime(context, controller),
        style: TextStyle(color: nxtbusDarkText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: nxtbusLightText),
          prefixIcon: Icon(icon, color: nxtbusPrimaryBlue),
          filled: true,
          fillColor: white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: nxtbusPrimaryBlue.withOpacity(0.6), width: 2)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.grey.shade200, width: 1)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.red, width: 1)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.red, width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a time';
          }
          return null;
        },
      ),
    );
  }
}