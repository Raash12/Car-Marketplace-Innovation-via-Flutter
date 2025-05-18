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
    // Safely parse rentPrice whether it's int, double or string
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _endDate = null; // reset end date if start date changes
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
      appBar: AppBar(title: const Text("Book Rental")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Car: ${widget.carData['name']} (\$${pricePerDay.toStringAsFixed(2)}/day)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter contact number' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _startDate == null
                      ? 'Select Start Date'
                      : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context, true),
              ),
              ListTile(
                title: Text(
                  _endDate == null
                      ? 'Select End Date'
                      : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context, false),
              ),
              if (_totalPrice != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Price Per Day: \$${pricePerDay.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                if (_startDate != null && _endDate != null) ...[
                  Text(
                    'Total Days: ${_endDate!.difference(_startDate!).inDays + 1}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Total Price: \$${_totalPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitBooking,
                icon: const Icon(Icons.send),
                label: const Text('Submit Rental'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
