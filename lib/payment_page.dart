import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'pdf_rental_invoice_service.dart'; // Adjust path if needed

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> car;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPrice;

  const PaymentPage({
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _isProcessing = false;

  Future<void> _submitPayment() async {
    setState(() {
      _isProcessing = true;
    });

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (name.isEmpty || phone.isEmpty || pin.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill in all fields.');
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      final url = Uri.parse('http://10.0.2.2:3000/api/payment');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'pin': pin}),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Payment Successful');

        // Save rental to Firestore
        await FirebaseFirestore.instance.collection('rental_cars').add({
          'car_name': widget.car['car_name'],
          'location': widget.car['location'],
          'start_date': widget.startDate,
          'end_date': widget.endDate,
          'price': widget.totalPrice,
          'customer_name': name,
          'customer_phone': phone,
          'timestamp': Timestamp.now(),
        });

        // Generate PDF invoice
        await PdfRentalInvoiceService.generateRentalInvoicePdf(
          name: name,
          phone: phone,
          carName: widget.car['car_name'],
          location: widget.car['location'],
          startDate: widget.startDate,
          endDate: widget.endDate,
          price: widget.totalPrice,
        );

        // Reset form
        _nameController.clear();
        _phoneController.clear();
        _pinController.clear();

        Fluttertoast.showToast(msg: 'Invoice generated and record saved.');
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? 'Payment failed';
        Fluttertoast.showToast(msg: message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Your Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: 'PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _isProcessing
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _submitPayment,
                    icon: Icon(Icons.payment),
                    label: Text('Pay & Generate Invoice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
