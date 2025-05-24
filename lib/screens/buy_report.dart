import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BuyReportPage extends StatefulWidget {
  const BuyReportPage({super.key});

  @override
  State<BuyReportPage> createState() => _BuyReportPageState();
}

class _BuyReportPageState extends State<BuyReportPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<QueryDocumentSnapshot> _allDocs = [];
  List<QueryDocumentSnapshot> _filteredDocs = [];

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
            onSurface: Colors.deepPurple,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
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
          _endDate = picked;
        }
      });
      _applyFilterAndSort();
    }
  }

  String _formatCurrency(num? value) {
    return '\$${value?.toStringAsFixed(2) ?? '0.00'}';
  }

  String _formatTimestamp(Timestamp? ts) {
    return ts != null ? DateFormat('yyyy-MM-dd – kk:mm').format(ts.toDate()) : '-';
  }

  bool _matchesDateRange(Timestamp timestamp) {
    final date = timestamp.toDate();
    if (_startDate != null && date.isBefore(_startDate!)) return false;
    if (_endDate != null && date.isAfter(_endDate!)) return false;
    return true;
  }

  void _applyFilterAndSort() {
    List<QueryDocumentSnapshot> docs = _allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'] as Timestamp?;
      final query = _searchQuery.toLowerCase();

      if (createdAt != null && !_matchesDateRange(createdAt)) return false;

      if (_searchQuery.isNotEmpty) {
        final carName = data['carName']?.toString().toLowerCase() ?? '';
        final buyerName = data['name']?.toString().toLowerCase() ?? '';
        final contact = data['contact']?.toString().toLowerCase() ?? '';
        final address = data['address']?.toString().toLowerCase() ?? '';
        if (!carName.contains(query) &&
            !buyerName.contains(query) &&
            !contact.contains(query) &&
            !address.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    if (_sortColumnIndex != null) {
      docs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        switch (_sortColumnIndex) {
          case 0:
            return _sortAscending
                ? (aData['carName'] ?? '').compareTo(bData['carName'] ?? '')
                : (bData['carName'] ?? '').compareTo(aData['carName'] ?? '');
          case 1:
            return _sortAscending
                ? ((aData['buyPrice'] as num?) ?? 0).compareTo((bData['buyPrice'] as num?) ?? 0)
                : ((bData['buyPrice'] as num?) ?? 0).compareTo((aData['buyPrice'] as num?) ?? 0);
          case 2:
            return _sortAscending
                ? (aData['name'] ?? '').compareTo(bData['name'] ?? '')
                : (bData['name'] ?? '').compareTo(aData['name'] ?? '');
          case 3:
            return _sortAscending
                ? (aData['contact'] ?? '').compareTo(bData['contact'] ?? '')
                : (bData['contact'] ?? '').compareTo(aData['contact'] ?? '');
          case 4:
            return _sortAscending
                ? (aData['email'] ?? '').compareTo(bData['email'] ?? '')
                : (bData['email'] ?? '').compareTo(aData['email'] ?? '');
          case 5:
            return _sortAscending
                ? (aData['address'] ?? '').compareTo(bData['address'] ?? '')
                : (bData['address'] ?? '').compareTo(aData['address'] ?? '');
          case 6:
            return _sortAscending
                ? (aData['notes'] ?? '').compareTo(bData['notes'] ?? '')
                : (bData['notes'] ?? '').compareTo(aData['notes'] ?? '');
          case 7:
            return _sortAscending
                ? ((aData['createdAt'] as Timestamp?) ?? Timestamp(0, 0)).compareTo(
                    (bData['createdAt'] as Timestamp?) ?? Timestamp(0, 0))
                : ((bData['createdAt'] as Timestamp?) ?? Timestamp(0, 0)).compareTo(
                    (aData['createdAt'] as Timestamp?) ?? Timestamp(0, 0));
          default:
            return 0;
        }
      });
    }

    setState(() => _filteredDocs = docs);
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    _applyFilterAndSort();
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final currentDate = DateFormat('M/d/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Buy Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text('Report Date: $currentDate', style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 16),
          if (_startDate != null && _endDate != null)
            pw.Text(
              'Date Range: ${DateFormat('d/M/yyyy').format(_startDate!)} to ${DateFormat('d/M/yyyy').format(_endDate!)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Car', 'Price', 'Buyer', 'Contact', 'Email', 'Address', 'Notes', 'Date'],
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: PdfColors.purple),
            border: pw.TableBorder.all(color: PdfColors.purple),
            data: _filteredDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return [
                data['carName'] ?? '-',
                _formatCurrency(data['buyPrice'] as num?),
                data['name'] ?? '-',
                data['contact'] ?? '-',
                data['email'] ?? '-',
                data['address'] ?? '-',
                data['notes'] ?? '-',
                _formatTimestamp(data['createdAt'] as Timestamp?),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total Records: ${_filteredDocs.length}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
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
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: 'Export as PDF',
            onPressed: _generatePdf,
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
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: BorderSide(color: Colors.deepPurple.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Start Date',
                              style: TextStyle(
                                color: _startDate != null ? Colors.deepPurple.shade900 : Colors.deepPurple.shade400,
                              ),
                            ),
                            onPressed: () => _pickDate(context, true), // Start date button
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: BorderSide(color: Colors.deepPurple.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'End Date',
                              style: TextStyle(
                                color: _endDate != null ? Colors.deepPurple.shade900 : Colors.deepPurple.shade400,
                              ),
                            ),
                            onPressed: () => _pickDate(context, false), // End date button
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.deepPurple.shade400),
                        hintText: 'Search by car, buyer, contact, or address...',
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
                stream: FirebaseFirestore.instance.collection('buy').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  _allDocs = snapshot.data?.docs ?? [];
                  if (_filteredDocs.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilterAndSort());
                  }

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.deepPurple.shade100),
                        dataRowColor: MaterialStateProperty.all(Colors.white),
                        columnSpacing: 16,
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        columns: const [
                          DataColumn(label: Text('Car')),
                          DataColumn(label: Text('Price'), numeric: true),
                          DataColumn(label: Text('Buyer')),
                          DataColumn(label: Text('Contact')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Address')),
                          DataColumn(label: Text('Notes')),
                          DataColumn(label: Text('Date')),
                        ],
                        rows: _filteredDocs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DataRow(cells: [
                            DataCell(Text(data['carName'] ?? '-')),
                            DataCell(Text(_formatCurrency(data['buyPrice'] as num?))),
                            DataCell(Text(data['name'] ?? '-')),
                            DataCell(Text(data['contact'] ?? '-')),
                            DataCell(Text(data['email'] ?? '-')),
                            DataCell(Text(data['address'] ?? '-')),
                            DataCell(Text(data['notes'] ?? '-')),
                            DataCell(Text(_formatTimestamp(data['createdAt'] as Timestamp?))),
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