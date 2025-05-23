import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BuyReportWidget extends StatefulWidget {
  const BuyReportWidget({super.key});

  @override
  State<BuyReportWidget> createState() => _BuyReportWidgetState();
}

class _BuyReportWidgetState extends State<BuyReportWidget> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<QueryDocumentSnapshot> _allDocs = [];
  List<QueryDocumentSnapshot> _filteredDocs = [];

  final TextEditingController _searchController = TextEditingController();

  // Flag to prevent repeated filtering during build
  bool _needsFilterUpdate = false;

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
    setState(() {
      _searchQuery = _searchController.text.trim();
      _needsFilterUpdate = true;
    });
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
        _needsFilterUpdate = true;
      });
    }
  }

  String _formatCurrency(num? value) {
    return value?.toStringAsFixed(2) ?? '0.00';
  }

  String _formatTimestamp(Timestamp? ts) {
    return ts != null ? _dateFormat.format(ts.toDate()) : '-';
  }

  void _applyFilterAndSort() {
    if (_allDocs.isEmpty) {
      setState(() {
        _filteredDocs = [];
        _needsFilterUpdate = false;
      });
      return;
    }

    List<QueryDocumentSnapshot> docs = _allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['createdAt'] as Timestamp?)?.toDate();

      // Date filtering
      if (_startDate != null && date != null && date.isBefore(_startDate!)) return false;
      if (_endDate != null && date != null && date.isAfter(_endDate!)) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();

        // Search in multiple fields: carName, name, contact, price, quantity, totalPrice, date string
        final carName = (data['carName'] ?? '').toString().toLowerCase();
        final customerName = (data['name'] ?? '').toString().toLowerCase();
        final contact = (data['contact'] ?? '').toString().toLowerCase();
        final price = (data['buyPrice']?.toString() ?? '').toLowerCase();
        final quantity = (data['quantity']?.toString() ?? '').toLowerCase();
        final totalPrice = (data['totalPrice']?.toString() ?? '').toLowerCase();
        final createdAtStr = date != null ? _dateFormat.format(date).toLowerCase() : '';

        if (!(carName.contains(q) ||
            customerName.contains(q) ||
            contact.contains(q) ||
            price.contains(q) ||
            quantity.contains(q) ||
            totalPrice.contains(q) ||
            createdAtStr.contains(q))) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    if (_sortColumnIndex != null) {
      docs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        int cmp;

        switch (_sortColumnIndex) {
          case 0:
            cmp = (aData['carName'] ?? '').toString().compareTo((bData['carName'] ?? '').toString());
            break;
          case 1:
            cmp = (aData['name'] ?? '').toString().compareTo((bData['name'] ?? '').toString());
            break;
          case 2:
            cmp = (aData['contact'] ?? '').toString().compareTo((bData['contact'] ?? '').toString());
            break;
          case 3:
            cmp = ((aData['buyPrice'] as num?) ?? 0).compareTo((bData['buyPrice'] as num?) ?? 0);
            break;
          case 4:
            cmp = ((aData['quantity'] as num?) ?? 0).compareTo((bData['quantity'] as num?) ?? 0);
            break;
          case 5:
            cmp = ((aData['totalPrice'] as num?) ?? 0).compareTo((bData['totalPrice'] as num?) ?? 0);
            break;
          case 6:
            cmp = ((aData['createdAt'] as Timestamp?) ?? Timestamp(0, 0))
                .compareTo((bData['createdAt'] as Timestamp?) ?? Timestamp(0, 0));
            break;
          default:
            cmp = 0;
        }
        return _sortAscending ? cmp : -cmp;
      });
    }

    setState(() {
      _filteredDocs = docs;
      _needsFilterUpdate = false;
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _needsFilterUpdate = true;
    });
  }

  Widget _header(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple,
        fontSize: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Buy Report'),
        centerTitle: true,
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
                              foregroundColor: Colors.deepPurple,
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
                              foregroundColor: Colors.deepPurple,
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
                        hintText: 'Search by any field (car, customer, contact, price...)',
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('buy').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.black)));
                      }

                      // Update allDocs and mark filter needed
                      if (snapshot.hasData) {
                        final newDocs = snapshot.data!.docs;
                        // Only update if data changed to avoid infinite loops
                        if (newDocs.length != _allDocs.length ||
                            !_allDocs.every((doc) => newDocs.contains(doc))) {
                          _allDocs = newDocs;
                          _needsFilterUpdate = true;
                        }
                      }

                      // Apply filter and sort if needed (do it outside build with post frame)
                      if (_needsFilterUpdate) {
                        WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilterAndSort());
                      }

                      if (_filteredDocs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No records found',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          sortAscending: _sortAscending,
                          sortColumnIndex: _sortColumnIndex,
                          headingRowColor: MaterialStateProperty.all(Colors.deepPurple.shade100),
                          columns: [
                            DataColumn(
                              label: _header('Car Name'),
                              onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
                            ),
                            DataColumn(
                              label: _header('Customer Name'),
                              onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
                            ),
                            DataColumn(
                              label: _header('Contact'),
                              onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
                            ),
                            DataColumn(
                              label: _header('Price'),
                              numeric: true,
                              onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
                            ),
                            DataColumn(
                              label: _header('Quantity'),
                              numeric: true,
                              onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
                            ),
                            DataColumn(
                              label: _header('Total Price'),
                              numeric: true,
                              onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
                            ),
                            DataColumn(
                              label: _header('Date'),
                              onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
                            ),
                          ],
                          rows: _filteredDocs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DataRow(cells: [
                              DataCell(Text(data['carName'] ?? '-')),
                              DataCell(Text(data['name'] ?? '-')),
                              DataCell(Text(data['contact'] ?? '-')),
                              DataCell(Text(_formatCurrency(data['buyPrice']))),
                              DataCell(Text(data['quantity']?.toString() ?? '-')),
                              DataCell(Text(_formatCurrency(data['totalPrice']))),
                              DataCell(Text(_formatTimestamp(data['createdAt']))),
                            ]);
                          }).toList(),
                        ),
                      );
                    },
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
