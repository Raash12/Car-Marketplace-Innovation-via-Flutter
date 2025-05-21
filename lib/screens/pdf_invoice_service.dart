// pdf_invoice_service.dart
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfInvoiceService {
  Future<Uint8List> generateInvoicePdf(
      Map<String, dynamic> carData, Map<String, String> buyerInfo) async {
    final pdf = pw.Document();

    final date = DateTime.now();
    final invoiceNumber =
        'INV${date.millisecondsSinceEpoch}${Random().nextInt(999)}';

    // Load your logo image from assets folder
    final logoImage =
        (await rootBundle.load('image/Logo.png')).buffer.asUint8List();

    final price = carData['buyPrice'].toString();
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
              pw.Text('INVOICE',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text('Date: ${date.day}/${date.month}/${date.year}'),
              pw.Text('Invoice No: $invoiceNumber'),
              pw.SizedBox(height: 16),

              // Buyer Info
              pw.Text('Billed To:',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(buyerInfo['name'] ?? ''),
              pw.Text(buyerInfo['email'] ?? ''),
              pw.Text(buyerInfo['contact'] ?? ''),
              pw.Text(buyerInfo['address'] ?? ''),
              pw.SizedBox(height: 20),

              // Car Details
              pw.Text('Car Purchased:',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Name: ${carData['name']}'),
              pw.Text('Fuel: ${carData['fuelType'] ?? 'N/A'}'),
              pw.Text('Mileage: ${carData['mileage'] ?? 'N/A'} km/l'),
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
                          child: pw.Text('Car Purchase')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('\$${price}')),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Total amount
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total: \$${price}',
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
              pw.Text('Thank you for your purchase!',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'This invoice was generated digitally and does not require a signature.',
                  style:
                      pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
