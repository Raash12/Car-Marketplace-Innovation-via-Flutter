import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RentalBookingPage extends StatefulWidget {
  final Map<String, dynamic> carData;

  const RentalBookingPage({super.key, required this.carData});

  @override
  State<RentalBookingPage> createState() => _RentalBookingPageState();
}

class _RentalBookingPageState extends State<RentalBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  double? _totalPrice;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  void _updateTotalPrice() {
    if (_startDate != null && _endDate != null && !(_endDate!.isBefore(_startDate!))) {
      final rentalDays = _endDate!.difference(_startDate!).inDays + 1;
      final pricePerDay = _parsePrice(widget.carData['rentPrice']);
      setState(() {
        _totalPrice = pricePerDay * rentalDays;
      });
    } else {
      setState(() {
        _totalPrice = null;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both start and end dates')),
        );
        return;
      }

      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End date cannot be before start date')),
        );
        return;
      }

      final int rentalDays = _endDate!.difference(_startDate!).inDays + 1;
      final double pricePerDay = _parsePrice(widget.carData['rentPrice']);
      final double totalPrice = pricePerDay * rentalDays;

      try {
        await FirebaseFirestore.instance.collection('rentalBookings').add({
          'carName': widget.carData['name'],
          'rentPrice': pricePerDay,
          'totalPrice': totalPrice,
          'days': rentalDays,
          'name': _nameController.text.trim(),
          'contact': _contactController.text.trim(),
          'startDate': _startDate,
          'endDate': _endDate,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rental booked for \$${totalPrice.toStringAsFixed(2)}')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? (_startDate ?? DateTime.now())),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null; // reset end date if invalid
          }
        } else {
          _endDate = picked;
        }
      });
      _updateTotalPrice();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pricePerDay = _parsePrice(widget.carData['rentPrice']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Rental"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Car: ${widget.carData['name']}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Price per day: \$${pricePerDay.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Contact field
                      TextFormField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Contact Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter contact number' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Date pickers inside card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _startDate == null
                              ? 'Select Start Date'
                              : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () => _pickDate(context, true),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _endDate == null
                              ? 'Select End Date'
                              : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _startDate == null ? null : () => _pickDate(context, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_totalPrice != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.green[50],
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price Per Day: \$${pricePerDay.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (_startDate != null && _endDate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Total Days: ${_endDate!.difference(_startDate!).inDays + 1}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Total Price: \$${_totalPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitBooking,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Submit Rental',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
