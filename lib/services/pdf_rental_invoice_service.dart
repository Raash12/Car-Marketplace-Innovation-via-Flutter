import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Already imported in rental_page, but good to keep here
import 'package:intl/intl.dart';

class PdfRentalInvoiceService {
  Future<Uint8List> generateRentalInvoicePdf(Map<String, dynamic> rentalData) async {
    final pdf = pw.Document();

    final String carName = rentalData['carName'] ?? 'N/A';
    final double rentPrice = rentalData['rentPrice'] ?? 0.0;
    final double totalPrice = rentalData['totalPrice'] ?? 0.0;
    final int days = rentalData['days'] ?? 0;
    final String customerName = rentalData['customerName'] ?? 'N/A';
    final String customerContact = rentalData['customerContact'] ?? 'N/A';
    final String paymentNumber = rentalData['paymentNumber'] ?? 'N/A';
    final String paymentReference = rentalData['paymentReference'] ?? 'N/A';
    final DateTime startDate = (rentalData['startDate'] as Timestamp).toDate();
    final DateTime endDate = (rentalData['endDate'] as Timestamp).toDate();
    final DateTime createdAt = (rentalData['createdAt'] as Timestamp).toDate();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Rental Invoice',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(createdAt)}'),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),

              pw.Text(
                'Customer Details:',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Name: $customerName'),
              pw.Text('Contact: $customerContact'),
              pw.Text('Payment Number: $paymentNumber'),
              pw.SizedBox(height: 20),

              pw.Text(
                'Rental Details:',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Car: $carName'),
              pw.Text('Rental Price per Day: \$${rentPrice.toStringAsFixed(2)}'),
              pw.Text('Start Date: ${DateFormat('MMM d, yyyy').format(startDate)}'),
              pw.Text('End Date: ${DateFormat('MMM d, yyyy').format(endDate)}'),
              pw.Text('Number of Days: $days'),
              pw.SizedBox(height: 20),

              pw.Text(
                'Payment Details:',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Payment Reference: $paymentReference'),
              pw.Text('Amount Paid: \$${totalPrice.toStringAsFixed(2)}'),
              pw.SizedBox(height: 30),

              pw.Center(
                child: pw.Text(
                  'Thank you for your rental!',
                  style: pw.TextStyle(fontSize: 18, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}