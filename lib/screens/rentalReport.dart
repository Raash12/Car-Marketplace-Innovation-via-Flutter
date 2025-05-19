import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white, // Body background white
        appBar: AppBar(
          backgroundColor: Colors.indigo[900], // Dark blue AppBar
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Reports', style: TextStyle(color: Colors.white)),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.indigo[200],
            tabs: const [
              Tab(text: 'Rental Reports'),
              Tab(text: 'Buy Reports'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RentalReportWidget(),
            BuyReportWidget(),
          ],
        ),
      ),
    );
  }
}

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
              primary: Colors.indigo[900]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.indigo[900]!,
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
              primary: Colors.indigo[900]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.indigo[900]!,
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
      final Timestamp? startTimestamp = data['startDate'];
      if (startTimestamp == null) return false;

      final date = startTimestamp.toDate();

      if (_startDate != null && date.isBefore(_startDate!)) return false;
      if (_endDate != null && date.isAfter(_endDate!)) return false;

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
    return Container(
      color: Colors.white, // Body white background
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStartDate,
                  icon: Icon(Icons.calendar_today, color: Colors.indigo[900]),
                  label: Text(
                    _startDate == null ? 'Start Date' : _dateFormat.format(_startDate!),
                    style: TextStyle(color: Colors.indigo[900]),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.indigo[900]!),
                    foregroundColor: Colors.indigo[900],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickEndDate,
                  icon: Icon(Icons.calendar_today, color: Colors.indigo[900]),
                  label: Text(
                    _endDate == null ? 'End Date' : _dateFormat.format(_endDate!),
                    style: TextStyle(color: Colors.indigo[900]),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.indigo[900]!),
                    foregroundColor: Colors.indigo[900],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('rental').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.indigo[900]));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('No rental records found.',
                          style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold)));
                }

                _allDocs = snapshot.data!.docs;
                if (_filteredDocs.isEmpty && (_startDate != null || _endDate != null)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilterAndSort());
                } else if (_filteredDocs.isEmpty) {
                  _filteredDocs = _allDocs;
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    headingRowColor: MaterialStateProperty.all(Colors.indigo[900]),
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.indigo[300];
                        }
                        // Alternate row color
                        int index = _filteredDocs.indexWhere((d) => d.id == states.toString());
                        if (index % 2 == 0) {
                          return Colors.indigo[50]; // light blueish white
                        } else {
                          return Colors.indigo[100]; // slightly darker light blue
                        }
                      },
                    ),
                    headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    dataTextStyle: TextStyle(color: Colors.indigo[900]),
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
    );
  }
}

class BuyReportWidget extends StatefulWidget {
  const BuyReportWidget({super.key});

  @override
  State<BuyReportWidget> createState() => _BuyReportWidgetState();
}

class _BuyReportWidgetState extends State<BuyReportWidget> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  DateTime? _startDate;
  DateTime? _endDate;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<QueryDocumentSnapshot> _filteredDocs = [];
  List<QueryDocumentSnapshot> _allDocs = [];

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
              primary: Colors.indigo[900]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.indigo[900]!,
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
              primary: Colors.indigo[900]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.indigo[900]!,
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
      final Timestamp? createdAtTimestamp = data['createdAt'];
      if (createdAtTimestamp == null) return false;

      final date = createdAtTimestamp.toDate();

      if (_startDate != null && date.isBefore(_startDate!)) return false;
      if (_endDate != null && date.isAfter(_endDate!)) return false;

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
            cmp = (aData['buyPrice'] as num).compareTo(bData['buyPrice'] as num);
            break;
          case 4:
            cmp = (aData['quantity'] as num).compareTo(bData['quantity'] as num);
            break;
          case 5:
            cmp = (aData['totalPrice'] as num).compareTo(bData['totalPrice'] as num);
            break;
          case 6:
            cmp = (aData['createdAt'] as Timestamp).compareTo(bData['createdAt'] as Timestamp);
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStartDate,
                  icon: Icon(Icons.calendar_today, color: Colors.indigo[900]),
                  label: Text(
                    _startDate == null ? 'Start Date' : _dateFormat.format(_startDate!),
                    style: TextStyle(color: Colors.indigo[900]),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.indigo[900]!),
                    foregroundColor: Colors.indigo[900],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickEndDate,
                  icon: Icon(Icons.calendar_today, color: Colors.indigo[900]),
                  label: Text(
                    _endDate == null ? 'End Date' : _dateFormat.format(_endDate!),
                    style: TextStyle(color: Colors.indigo[900]),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.indigo[900]!),
                    foregroundColor: Colors.indigo[900],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('buy').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.indigo[900]));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('No buy records found.',
                          style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold)));
                }

                _allDocs = snapshot.data!.docs;
                if (_filteredDocs.isEmpty && (_startDate != null || _endDate != null)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilterAndSort());
                } else if (_filteredDocs.isEmpty) {
                  _filteredDocs = _allDocs;
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    headingRowColor: MaterialStateProperty.all(Colors.indigo[900]),
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.indigo[300];
                        }
                        // Alternate row color by index in filtered list
                        int index = _filteredDocs.indexWhere((d) => d.id == states.toString());
                        if (index % 2 == 0) {
                          return Colors.indigo[50];
                        } else {
                          return Colors.indigo[100];
                        }
                      },
                    ),
                    headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    dataTextStyle: TextStyle(color: Colors.indigo[900]),
                    columns: [
                      DataColumn(label: const Text('Car'), onSort: (i, asc) => _onSort(i, asc)),
                      DataColumn(label: const Text('Customer'), onSort: (i, asc) => _onSort(i, asc)),
                      DataColumn(label: const Text('Contact'), onSort: (i, asc) => _onSort(i, asc)),
                      DataColumn(label: const Text('Buy Price'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                      DataColumn(label: const Text('Quantity'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                      DataColumn(label: const Text('Total Price'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                      DataColumn(label: const Text('Date'), onSort: (i, asc) => _onSort(i, asc)),
                    ],
                    rows: _filteredDocs.map((doc) {
                      final data = doc.data()! as Map<String, dynamic>;
                      return DataRow(cells: [
                        DataCell(Text(data['carName'] ?? '-')),
                        DataCell(Text(data['name'] ?? '-')),
                        DataCell(Text(data['contact'] ?? '-')),
                        DataCell(Text(data['buyPrice']?.toString() ?? '-')),
                        DataCell(Text(data['quantity']?.toString() ?? '-')),
                        DataCell(Text(data['totalPrice']?.toString() ?? '-')),
                        DataCell(Text(formatTimestamp(data['createdAt']))),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
