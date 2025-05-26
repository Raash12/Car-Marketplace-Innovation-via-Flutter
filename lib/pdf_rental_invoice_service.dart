import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfRentalInvoiceService {
  static Future<Uint8List> generateRentalInvoicePdf({
    required String name,
    required String phone,
    required String carName,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required int price,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Rental Invoice',
                  style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 24),
              pw.Text('Customer Name: $name'),
              pw.Text('Phone: $phone'),
              pw.Text('Car Name: $carName'),
              pw.Text('Location: $location'),
              pw.Text('Start Date: ${startDate.toLocal()}'.split(' ')[0]),
              pw.Text('End Date: ${endDate.toLocal()}'.split(' ')[0]),
              pw.SizedBox(height: 12),
              pw.Text('Total Price: \$${price.toString()}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }
}
