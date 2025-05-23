import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BuyReportWidget extends StatefulWidget {
  const BuyReportWidget({super.key});

  @override
  State<BuyReportWidget> createState() => _BuyReportWidgetState();
}

class _BuyReportWidgetState extends State<BuyReportWidget> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _pdfDateFormat = DateFormat('d/M/yyyy');
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<QueryDocumentSnapshot> _allDocs = [];
  List<QueryDocumentSnapshot> _filteredDocs = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text);
    _applyFilterAndSort();
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.deepPurple,
            onPrimary: Colors.white,
            onSurface: Colors.deepPurple.shade700,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.deepPurple.shade700),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          if (_startDate != null && picked.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End date cannot be before start date.')),
            );
            return;
          }
          _endDate = picked;
        }
      });
      _applyFilterAndSort();
    }
  }

  String _formatCurrency(num? value) => value?.toStringAsFixed(2) ?? '0.00';
  String _formatTimestamp(Timestamp? ts) => ts != null ? _dateFormat.format(ts.toDate()) : '-';
  String _formatPdfTimestamp(Timestamp? ts) => ts != null ? _pdfDateFormat.format(ts.toDate()) : '-';

  void _applyFilterAndSort() {
    List<QueryDocumentSnapshot> docs = _allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['createdAt'] as Timestamp?)?.toDate();

      if (_startDate != null && date != null && date.isBefore(_startDate!)) return false;
      if (_endDate != null && date != null && date.isAfter(_endDate!.add(const Duration(days: 1)))) return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final customerName = data['name']?.toString().toLowerCase() ?? '';
        final carName = data['carName']?.toString().toLowerCase() ?? '';
        final contact = data['contact']?.toString().toLowerCase() ?? '';

        if (!(customerName.contains(query) || carName.contains(query) || contact.contains(query))) {
          return false;
        }
      }
      return true;
    }).toList();

    if (_sortColumnIndex != null) {
      docs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        dynamic getValue(Map<String, dynamic> data, int index) {
          switch (index) {
            case 0: return data['carName'] ?? '';
            case 1: return data['name'] ?? '';
            case 2: return data['contact'] ?? '';
            case 3: return (data['buyPrice'] as num?) ?? 0;
            case 4: return (data['quantity'] as num?) ?? 0;
            case 5: return (data['totalPrice'] as num?) ?? 0;
            case 6: return (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime(1970);
            default: return '';
          }
        }

        final aValue = getValue(aData, _sortColumnIndex!);
        final bValue = getValue(bData, _sortColumnIndex!);

        int comparisonResult;
        if (aValue is String && bValue is String) {
          comparisonResult = aValue.toLowerCase().compareTo(bValue.toLowerCase());
        } else if (aValue is num && bValue is num) {
          comparisonResult = aValue.compareTo(bValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          comparisonResult = aValue.compareTo(bValue);
        } else {
          comparisonResult = aValue.toString().compareTo(bValue.toString());
        }

        return _sortAscending ? comparisonResult : -comparisonResult;
      });
    }
    if (mounted) {
      setState(() => _filteredDocs = docs);
    }
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    _applyFilterAndSort();
  }

  Widget _header(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple.shade800,
        fontSize: 14,
      ),
    );
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final currentDate = _pdfDateFormat.format(DateTime.now());
    final totalAmount = _filteredDocs.fold<double>(0.0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>;
      return sum + ((data['totalPrice'] as num?)?.toDouble() ?? 0.0);
    });

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Buy Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple700,
                    ),
                  ),
                  pw.Text(
                    'Date: $currentDate',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Text('Date Range: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(_startDate != null ? _pdfDateFormat.format(_startDate!) : 'Start'),
                  pw.Text(' - '),
                  pw.Text(_endDate != null ? _pdfDateFormat.format(_endDate!) : 'End'),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.purple700, width: 0.5),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.purple700),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                },
                headers: ['Car', 'Customer', 'Contact', 'Price', 'Qty', 'Total', 'Date'],
                data: _filteredDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return [
                    data['carName'] ?? '-',
                    data['name'] ?? '-',
                    data['contact'] ?? '-',
                    _formatCurrency(data['buyPrice'] as num?),
                    '${data['quantity'] ?? 0}',
                    _formatCurrency(data['totalPrice'] as num?),
                    _formatPdfTimestamp(data['createdAt'] as Timestamp?),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Amount: ${_formatCurrency(totalAmount)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.purple700),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total Records: ${_filteredDocs.length}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.bottomCenter,
                child: pw.Text(
                  'Generated on: $currentDate',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Buy Report', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        color: Colors.blueGrey[50],
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple.shade700,
                              side: BorderSide(color: Colors.deepPurple.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.date_range),
                            label: Text(
                              _startDate != null ? _dateFormat.format(_startDate!) : 'Start Date',
                              style: TextStyle(
                                color: _startDate != null ? Colors.deepPurple.shade900 : Colors.deepPurple.shade400,
                              ),
                            ),
                            onPressed: () => _pickDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple.shade700,
                              side: BorderSide(color: Colors.deepPurple.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.date_range),
                            label: Text(
                              _endDate != null ? _dateFormat.format(_endDate!) : 'End Date',
                              style: TextStyle(
                                color: _endDate != null ? Colors.deepPurple.shade900 : Colors.deepPurple.shade400,
                              ),
                            ),
                            onPressed: () => _pickDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.deepPurple.shade400),
                        hintText: 'Search by customer, car, or contact...',
                        hintStyle: TextStyle(color: Colors.deepPurple.shade200),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.deepPurple.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.deepPurple.shade400),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(color: Colors.deepPurple.shade900),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('buy').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.black)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No buy records found.', style: TextStyle(color: Colors.black54)));
                  }

                  _allDocs = snapshot.data?.docs ?? [];

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _applyFilterAndSort();
                    }
                  });

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.deepPurple.shade100),
                        dataRowColor: MaterialStateProperty.all(Colors.white),
                        columnSpacing: 28,
                        headingTextStyle: TextStyle(
                          color: Colors.deepPurple.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        sortAscending: _sortAscending,
                        sortColumnIndex: _sortColumnIndex,
                        columns: [
                          DataColumn(label: _header('Car'), onSort: (i, asc) => _onSort(i, asc)),
                          DataColumn(label: _header('Customer'), onSort: (i, asc) => _onSort(i, asc)),
                          DataColumn(label: _header('Contact'), onSort: (i, asc) => _onSort(i, asc)),
                          DataColumn(label: _header('Price'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                          DataColumn(label: _header('Qty'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                          DataColumn(label: _header('Total'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                          DataColumn(label: _header('Date'), onSort: (i, asc) => _onSort(i, asc)),
                        ],
                        rows: _filteredDocs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DataRow(cells: [
                            DataCell(Text(data['carName'] ?? '-', style: TextStyle(color: Colors.deepPurple.shade900))),
                            DataCell(Text(data['name'] ?? '-', style: TextStyle(color: Colors.deepPurple.shade900))),
                            DataCell(Text(data['contact'] ?? '-', style: TextStyle(color: Colors.deepPurple.shade900))),
                            DataCell(Text(_formatCurrency(data['buyPrice'] as num?), style: TextStyle(color: Colors.deepPurple.shade900))),
                            DataCell(Text('${data['quantity'] ?? 0}', style: TextStyle(color: Colors.deepPurple.shade900))),
                            DataCell(Text(_formatCurrency(data['totalPrice'] as num?), style: TextStyle(color: Colors.deepPurple.shade900))),
                            DataCell(Text(_formatTimestamp(data['createdAt'] as Timestamp?), style: TextStyle(color: Colors.deepPurple.shade900))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}