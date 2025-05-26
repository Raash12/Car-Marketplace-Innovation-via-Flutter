import 'package:carmarketplace/services/pdf_rental_invoice_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Replace with your actual backend URL
const String _backendInitiatePaymentUrl = 'http://10.0.2.2:3000/api/payment';

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
  final _paymentNumberController = TextEditingController();
  final _paymentAmountController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  double? _totalPrice;
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _paymentNumberController.dispose();
    _paymentAmountController.dispose();
    super.dispose();
  }

  double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    return price is double ? price : double.tryParse(price.toString()) ?? 0.0;
  }

  void _updateTotalPrice() {
    if (_startDate != null && _endDate != null && !_endDate!.isBefore(_startDate!)) {
      final rentalDays = _endDate!.difference(_startDate!).inDays + 1;
      final pricePerDay = _parsePrice(widget.carData['rentalPrice']);
      setState(() {
        _totalPrice = pricePerDay * rentalDays;
        _paymentAmountController.text = _totalPrice!.toStringAsFixed(2);
      });
    } else {
      setState(() {
        _totalPrice = null;
        _paymentAmountController.clear();
      });
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both start and end dates.')));
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date cannot be before start date.')));
      return;
    }

    final pin = await _showPinDialog();
    if (pin == null || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment cancelled: PIN not entered.')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final rentalDays = _endDate!.difference(_startDate!).inDays + 1;
      final pricePerDay = _parsePrice(widget.carData['rentalPrice']);
      final totalPrice = pricePerDay * rentalDays;

      _paymentAmountController.text = totalPrice.toStringAsFixed(2);

      final paymentData = {
        "accountNo": _paymentNumberController.text.trim(),
        "pin": pin,
        "referenceId": "CAR-${DateTime.now().millisecondsSinceEpoch}",
        "amount": totalPrice,
        "currency": "USD",
        "description": "Rental: ${widget.carData['name']}",
      };

      final paymentResult = await _processPayment(paymentData);
      if (!paymentResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: ${paymentResult['message']}')));
        return;
      }

      final rentalData = {
        'carId': widget.carData['id'],
        'carName': widget.carData['name'],
        'rentPrice': pricePerDay,
        'totalPrice': totalPrice,
        'days': rentalDays,
        'customerName': _nameController.text.trim(),
        'customerContact': _contactController.text.trim(),
        'paymentNumber': _paymentNumberController.text.trim(),
        'paymentAmount': totalPrice,
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'createdAt': Timestamp.now(),
        'paymentReference': paymentResult['transactionId'],
        'status': 'confirmed',
      };

      await FirebaseFirestore.instance.collection('rentals').add(rentalData);
      final pdfBytes = await PdfRentalInvoiceService().generateRentalInvoicePdf(rentalData);
      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment successful! Rental booked for \$${totalPrice.toStringAsFixed(2)}. Invoice generated.')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<Map<String, dynamic>> _processPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await http.post(
        Uri.parse(_backendInitiatePaymentUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'] ?? 'Payment processing failed',
          'transactionId': responseData['transactionId'],
        };
      } else {
        return {
          'success': false,
          'message': 'Server responded with status ${response.statusCode}: ${response.body}',
          'transactionId': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred during payment processing: ${e.toString()}',
        'transactionId': null,
      };
    }
  }

  Future<String?> _showPinDialog() async {
    final pinController = TextEditingController();
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('EVC Plus Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your EVC Plus PIN to confirm payment'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'EVC Plus PIN', border: OutlineInputBorder()),
              maxLength: 5,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (pinController.text.length >= 4) {
                Navigator.pop(context, pinController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid PIN (4-5 digits)')));
              }
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pricePerDay = _parsePrice(widget.carData['rentalPrice']);

    return Scaffold(
      appBar: AppBar(title: const Text("Book Rental"), backgroundColor: Colors.deepPurple),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.carData['name']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('\$${pricePerDay.toStringAsFixed(2)} per day', style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 24),
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()), validator: (value) => value?.isEmpty ?? true ? 'Required' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _contactController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()), validator: (value) => value?.isEmpty ?? true ? 'Required' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _paymentNumberController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'EVC Plus Number', hintText: 'e.g., 615123456', border: OutlineInputBorder()), validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (!RegExp(r'^[0-9]{9}$').hasMatch(value!)) {
                      return 'Enter a valid 9-digit number';
                    }
                    return null;
                  }),
                  const SizedBox(height: 16),
                  TextFormField(controller: _paymentAmountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (USD)', border: OutlineInputBorder()), readOnly: true),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.calendar_today), label: Text(_startDate == null ? 'Start Date' : DateFormat('MMM d, yyyy').format(_startDate!)), onPressed: () => _pickDate(context, true))),
                      const SizedBox(width: 16),
                      Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.calendar_today), label: Text(_endDate == null ? 'End Date' : DateFormat('MMM d, yyyy').format(_endDate!)), onPressed: _startDate == null ? null : () => _pickDate(context, false))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_totalPrice != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Price:', style: TextStyle(fontSize: 18)),
                          Text('\$${_totalPrice!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _submitBooking,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                      child: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Text('PAY WITH EVC PLUS', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}