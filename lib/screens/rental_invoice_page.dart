// pdf_rental_invoice_service.dart
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class RentalInvoicePage {
  Future<Uint8List> generateRentalInvoicePdf(
      Map<String, dynamic> rentalData) async {
    final pdf = pw.Document();

    final date = DateTime.now();
    final invoiceNumber =
        'RENT${date.millisecondsSinceEpoch}${Random().nextInt(999)}';

    // Load your logo image from assets folder
    final logoImage =
        (await rootBundle.load('image/Logo.png')).buffer.asUint8List();

    final pricePerDay = rentalData['rentPrice'] as double? ?? 0.0;
    final totalPrice = rentalData['totalPrice'] as double? ?? 0.0;
    final startDate = DateTime.parse(rentalData['startDate']);
    final endDate = DateTime.parse(rentalData['endDate']);
    final days = rentalData['days'] ?? 0;

    final dateFormat = DateFormat('yyyy-MM-dd');

    final qrData = "Invoice No: $invoiceNumber";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Company Info & Logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Car Marketplace Inc.',
                          style: pw.TextStyle(
                              fontSize: 22, fontWeight: pw.FontWeight.bold)),
                      pw.Text('123 Auto Lane, Speed City'),
                      pw.Text('Email: support@carmarketplace.com'),
                    ],
                  ),
                  pw.Image(pw.MemoryImage(logoImage), width: 80),
                ],
              ),
              pw.SizedBox(height: 20),

              // Invoice Info
              pw.Text('RENTAL INVOICE',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text('Date: ${dateFormat.format(date)}'),
              pw.Text('Invoice No: $invoiceNumber'),
              pw.SizedBox(height: 16),

              // Renter Info
              pw.Text('Renter Information:',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(rentalData['name'] ?? ''),
              pw.Text(rentalData['contact'] ?? ''),
              pw.Text(rentalData['address'] ?? ''),
              pw.SizedBox(height: 20),

              // Rental Details
              pw.Text('Rental Details:',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Car Name: ${rentalData['carName'] ?? ''}'),
              pw.Text('Start Date: ${dateFormat.format(startDate)}'),
              pw.Text('End Date: ${dateFormat.format(endDate)}'),
              pw.Text('Total Days: $days'),
              pw.Text('Price Per Day: \$${pricePerDay.toStringAsFixed(2)}'),
              pw.SizedBox(height: 20),

              // Table with Item and Amount
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Item')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Amount')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Car Rental')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text('\$${totalPrice.toStringAsFixed(2)}')),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Total amount
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total: \$${totalPrice.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),

              // QR Code section
              pw.Text('Scan QR to verify invoice:',
                  style: pw.TextStyle(fontSize: 12)),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: qrData,
                width: 100,
                height: 100,
              ),
              pw.SizedBox(height: 24),

              pw.Divider(),

              // Footer message
              pw.Text('Thank you for choosing Car Marketplace!',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'This invoice was generated digitally and does not require a signature.',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
