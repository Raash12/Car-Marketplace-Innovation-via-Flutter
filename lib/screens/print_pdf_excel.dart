// print_pdf_excel.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';

/// Generate and print a PDF report with given title, headers, and rows.
Future<void> generateAndPrintPDF({
  required String title,
  required List<String> headers,
  required List<List<String>> rows,
}) async {
  final pdf = pw.Document();

  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4.landscape,
    build: (context) {
      return pw.Column(children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: headers,
          data: rows,
          cellAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ]);
    },
  ));

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

/// Generate and share an Excel report with given sheet name, headers, and rows.
Future<void> generateAndShareExcel({
  required String sheetName,
  required List<String> headers,
  required List<List<String>> rows,
}) async {
  final excel = Excel.createExcel();
  final Sheet sheet = excel[sheetName];

  sheet.appendRow(headers);
  for (final row in rows) {
    sheet.appendRow(row);
  }

  final fileBytes = excel.save();
if (fileBytes == null) return;

// Convert List<int> to Uint8List
final bytes = Uint8List.fromList(fileBytes);

await Printing.sharePdf(bytes: bytes, filename: '$sheetName.xlsx');
  }