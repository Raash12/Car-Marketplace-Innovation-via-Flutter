import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RentalReportWidget extends StatefulWidget {
  const RentalReportWidget({super.key});

  @override
  State<RentalReportWidget> createState() => _RentalReportWidgetState();
}

class _RentalReportWidgetState extends State<RentalReportWidget> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  DateTime? _startDate;
  DateTime? _endDate;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<QueryDocumentSnapshot> _filteredDocs = [];
  List<QueryDocumentSnapshot> _allDocs = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _endDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.deepPurple,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      _applyFilterAndSort();
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.deepPurple,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _applyFilterAndSort();
    }
  }

  String formatTimestamp(Timestamp? ts) {
    if (ts == null) return '-';
    return _dateFormat.format(ts.toDate());
  }

  void _applyFilterAndSort() {
    List<QueryDocumentSnapshot> temp = _allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Filter by startDate field
      final Timestamp? startTimestamp = data['startDate'];
      if (startTimestamp == null) return false;
      final date = startTimestamp.toDate();

      if (_startDate != null && date.isBefore(_startDate!)) return false;
      if (_endDate != null && date.isAfter(_endDate!)) return false;

      // Filter by search query (carName or name)
      final carName = data['carName']?.toString().toLowerCase() ?? '';
      final customerName = data['name']?.toString().toLowerCase() ?? '';
      if (_searchQuery.isNotEmpty) {
        if (!carName.contains(_searchQuery.toLowerCase()) &&
            !customerName.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();

    if (_sortColumnIndex != null) {
      temp.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        int cmp;

        switch (_sortColumnIndex) {
          case 0:
            cmp = aData['carName'].toString().compareTo(bData['carName'].toString());
            break;
          case 1:
            cmp = aData['name'].toString().compareTo(bData['name'].toString());
            break;
          case 2:
            cmp = aData['contact'].toString().compareTo(bData['contact'].toString());
            break;
          case 3:
            cmp = (aData['rentPrice'] as num).compareTo(bData['rentPrice'] as num);
            break;
          case 4:
            cmp = (aData['days'] as num).compareTo(bData['days'] as num);
            break;
          case 5:
            cmp = (aData['totalPrice'] as num).compareTo(bData['totalPrice'] as num);
            break;
          case 6:
            cmp = (aData['startDate'] as Timestamp).compareTo(bData['startDate'] as Timestamp);
            break;
          case 7:
            cmp = (aData['endDate'] as Timestamp).compareTo(bData['endDate'] as Timestamp);
            break;
          default:
            cmp = 0;
        }
        return _sortAscending ? cmp : -cmp;
      });
    }

    setState(() {
      _filteredDocs = temp;
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    _applyFilterAndSort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Rental Report'),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                  _applyFilterAndSort();
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                  hintText: 'Search by Car or Customer Name',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.deepPurple.shade200),
                ),
                style: TextStyle(color: Colors.deepPurple.shade900),
              ),
            ),

            // Date Pickers Container
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickStartDate,
                      icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                      label: Text(
                        _startDate == null ? 'Start Date' : _dateFormat.format(_startDate!),
                        style: TextStyle(color: Colors.deepPurple.shade900),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.deepPurple, width: 1.5),
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickEndDate,
                      icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                      label: Text(
                        _endDate == null ? 'End Date' : _dateFormat.format(_endDate!),
                        style: TextStyle(color: Colors.deepPurple.shade900),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.deepPurple, width: 1.5),
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // DataTable Expanded
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('rental').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No rental records found.',
                            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)));
                  }

                  _allDocs = snapshot.data!.docs;

                  // If filtered docs empty but filters/search applied, apply filter
                  if ((_filteredDocs.isEmpty && (_startDate != null || _endDate != null || _searchQuery.isNotEmpty))) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilterAndSort());
                  } else if (_filteredDocs.isEmpty) {
                    _filteredDocs = _allDocs;
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      headingRowColor: MaterialStateProperty.all(Colors.deepPurple),
                      dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.deepPurple[300];
                          }
                          // Alternate row color by index
                          final index = _filteredDocs.indexWhere((d) => d.id == states.toString());
                          if (index.isEven) {
                            return Colors.deepPurple[50];
                          } else {
                            return Colors.deepPurple[100];
                          }
                        },
                      ),
                      headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      dataTextStyle: const TextStyle(color: Colors.deepPurple),
                      columns: [
                        DataColumn(label: const Text('Car'), onSort: (i, asc) => _onSort(i, asc)),
                        DataColumn(label: const Text('Customer'), onSort: (i, asc) => _onSort(i, asc)),
                        DataColumn(label: const Text('Contact'), onSort: (i, asc) => _onSort(i, asc)),
                        DataColumn(label: const Text('Rent/Day'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                        DataColumn(label: const Text('Days'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                        DataColumn(label: const Text('Total Price'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                        DataColumn(label: const Text('Start Date'), onSort: (i, asc) => _onSort(i, asc)),
                        DataColumn(label: const Text('End Date'), onSort: (i, asc) => _onSort(i, asc)),
                      ],
                      rows: _filteredDocs.map((doc) {
                        final data = doc.data()! as Map<String, dynamic>;
                        return DataRow(cells: [
                          DataCell(Text(data['carName'] ?? '-')),
                          DataCell(Text(data['name'] ?? '-')),
                          DataCell(Text(data['contact'] ?? '-')),
                          DataCell(Text(data['rentPrice']?.toString() ?? '-')),
                          DataCell(Text(data['days']?.toString() ?? '-')),
                          DataCell(Text(data['totalPrice']?.toString() ?? '-')),
                          DataCell(Text(formatTimestamp(data['startDate']))),
                          DataCell(Text(formatTimestamp(data['endDate']))),
                        ]);
                      }).toList(),
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
