import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'pdf_rental_invoice_service.dart';

class RentalPage extends StatefulWidget {
  final Map<String, dynamic> carData;

  const RentalPage({super.key, required this.carData});

  @override
  State<RentalPage> createState() => _RentalPageState();
}

class _RentalPageState extends State<RentalPage> {
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
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  void _updateTotalPrice() {
    if (_startDate != null && _endDate != null && !_endDate!.isBefore(_startDate!)) {
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

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
      _updateTotalPrice();
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates.')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date.')),
      );
      return;
    }

    final rentalDays = _endDate!.difference(_startDate!).inDays + 1;
    final pricePerDay = _parsePrice(widget.carData['rentPrice']);
    final totalPrice = pricePerDay * rentalDays;

    final rentalData = {
      'carName': widget.carData['name'],
      'rentPrice': pricePerDay,
      'totalPrice': totalPrice,
      'days': rentalDays,
      'name': _nameController.text.trim(),
      'contact': _contactController.text.trim(),
      'startDate': _startDate!,
      'endDate': _endDate!,
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('rental').add({
        ...rentalData,
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
      });

      final pdfBytes = await PdfRentalInvoiceService().generateRentalInvoicePdf(rentalData);
      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);

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

  @override
  Widget build(BuildContext context) {
    final pricePerDay = _parsePrice(widget.carData['rentPrice']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Rental", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Car: ${widget.carData['name']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Price per day: \$${pricePerDay.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter your contact' : null,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_startDate == null
                    ? 'Select Start Date'
                    : 'Start: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'),
                onPressed: () => _pickDate(context, true),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_endDate == null
                    ? 'Select End Date'
                    : 'End: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'),
                onPressed: _startDate == null ? null : () => _pickDate(context, false),
              ),
              const SizedBox(height: 24),
              if (_totalPrice != null)
                Text('Total Price: \$${_totalPrice!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Book Rental & Generate Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
