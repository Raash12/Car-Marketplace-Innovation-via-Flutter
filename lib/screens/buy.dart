import 'package:carmarketplace/utils/payment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'pdf_invoice_service.dart'; // Adjust the path if needed

class BuyCarPage extends StatefulWidget {
  final Map<String, dynamic> carData;

  const BuyCarPage({super.key, required this.carData});

  @override
  State<BuyCarPage> createState() => _BuyCarPageState();
}

class _BuyCarPageState extends State<BuyCarPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
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

  Future<void> _submitPurchase() async {
    if (_formKey.currentState!.validate()) {
      final double price = _parsePrice(widget.carData['buyPrice']);

      try {
        final paymentData = {
          "accountNo": _contactController.text.trim(),
          "referenceId": "CAR-${DateTime.now().millisecondsSinceEpoch}",
          "amount": price,
          "currency": "USD",
          "description": "Buying: ${widget.carData['name']}",
        };

        final paymentResult = await Payment.paymentProcessing(paymentData);
        if (!paymentResult['success']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Payment Failed: ${paymentResult['message']}')));
          return;
        }
        await FirebaseFirestore.instance.collection('buy').add({
          'carName': widget.carData['name'],
          'buyPrice': price,
          'name': _nameController.text.trim(),
          'contact': _contactController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'notes': _notesController.text.trim(),
          'createdAt': Timestamp.now(),
        });

        final buyerInfo = {
          'name': _nameController.text.trim(),
          'contact': _contactController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'paymentReference': paymentData['referenceId'] as String,
        };

        final pdfService = PdfInvoiceService();
        final pdfData =
            await pdfService.generateInvoicePdf(widget.carData, buyerInfo);

        await Printing.layoutPdf(onLayout: (format) async => pdfData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Car purchased for \$${price.toStringAsFixed(2)} and Invoice: ${paymentResult['invoice']}')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = _parsePrice(widget.carData['buyPrice']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Car", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Price: \$${price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter your name'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Contact Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your contact number';
                          }
                          final pattern = RegExp(r'^\+?\d{7,15}$');
                          if (!pattern.hasMatch(value.trim())) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter your address'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes (optional)',
                          prefixIcon: Icon(Icons.note),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitPurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Buy Now',
                            style: TextStyle(fontSize: 18, color: Colors.white),
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
}
