import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Edit_buy_CarPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> carData;

  const Edit_buy_CarPage({super.key, required this.docId, required this.carData});

  @override
  State<Edit_buy_CarPage> createState() => _EditCarPageState();
}

class _EditCarPageState extends State<Edit_buy_CarPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _buyPriceController;
 

  String currentImageUrl = '';
  String? _selectedFuelType;

  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    final car = widget.carData;
    final specs = car['specifications'] ?? {};

    _nameController = TextEditingController(text: car['name'] ?? '');
    _buyPriceController =
        TextEditingController(text: (car['buyPrice'] ?? '').toString());
  

    _selectedFuelType = specs['fuelType']?.toString().trim();
    if (_selectedFuelType == null || !_fuelTypes.contains(_selectedFuelType)) {
      _selectedFuelType = _fuelTypes[0];
    }

    currentImageUrl = car['imageUrl'] ?? '';
  }

  Future<void> _updateCar() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('carlist')
            .doc(widget.docId)
            .update({
          'name': _nameController.text.trim(),
          'buyPrice': double.tryParse(_buyPriceController.text.trim()) ?? 0,
        
          'specifications': {
            'fuelType': _selectedFuelType ?? '',
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car updated successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating car: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buyPriceController.dispose();
   
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade700),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade900, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Buy Car'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (currentImageUrl.isNotEmpty)
                Center(
                  child: Image.network(
                    currentImageUrl,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Car Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter car name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _buyPriceController,
                decoration: _inputDecoration('Buy Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter buy price' : null,
              ),
             
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Fuel Type',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                value: _selectedFuelType,
                items: _fuelTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFuelType = value;
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select fuel type' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateCar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Update Car',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
