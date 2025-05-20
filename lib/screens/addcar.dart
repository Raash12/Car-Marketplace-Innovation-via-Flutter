import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _rentPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String _fuelType = 'Petrol';

  File? _image;
  final ImagePicker picker = ImagePicker();

  final String imgbbApiKey = '409164d54cc9cb69bc6e0c8910d9f487';

  // Mileage options and selected mileage value
  final List<String> _mileageOptions = ['10 km/l', '12 km/l', '15 km/l', '18 km/l', '20 km/l', '25 km/l'];
  String _selectedMileage = '15 km/l';

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (await file.exists()) {
          setState(() {
            _image = file;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected file does not exist.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selection failed: $e')),
      );
    }
  }

  Future<String?> uploadImageToImgBB(File imageFile) async {
    try {
      final base64Image = base64Encode(await imageFile.readAsBytes());
      final response = await http.post(
        Uri.parse("https://api.imgbb.com/1/upload?key=$imgbbApiKey"),
        body: {"image": base64Image},
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData["data"]["url"];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _addCarToFirestore() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        final imageUrl = await uploadImageToImgBB(_image!);
        if (imageUrl == null) {
          throw Exception("Failed to upload image to ImgBB");
        }

        await FirebaseFirestore.instance.collection('carlist').add({
          'name': _nameController.text.trim(),
          'buyPrice': double.parse(_buyPriceController.text.trim()),
          'rentPrice': double.parse(_rentPriceController.text.trim()),
          'description': _descriptionController.text.trim(),
          'quantity': int.parse(_quantityController.text.trim()),
          'specifications': {
            'mileage': _selectedMileage,
            'fuelType': _fuelType,
          },
          'imageUrl': imageUrl,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _fuelType = 'Petrol';
          _selectedMileage = '15 km/l';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding car: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields and select an image.'),
          backgroundColor: Colors.deepPurple,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buyPriceController.dispose();
    _rentPriceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Car'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Car Name'),
                validator: (value) => value!.isEmpty ? 'Enter car name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _buyPriceController,
                decoration: _inputDecoration('Buy Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter buy price';
                  final n = num.tryParse(value);
                  if (n == null) return 'Enter a valid number';
                  if (n <= 0) return 'Price must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rentPriceController,
                decoration: _inputDecoration('Rent Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter rent price';
                  final n = num.tryParse(value);
                  if (n == null) return 'Enter a valid number';
                  if (n <= 0) return 'Price must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration('Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: _inputDecoration('Quantity'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter quantity';
                  final n = int.tryParse(value);
                  if (n == null) return 'Enter a valid number';
                  if (n <= 0) return 'Quantity must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Mileage dropdown field
              DropdownButtonFormField<String>(
                value: _selectedMileage,
                decoration: _inputDecoration('Mileage'),
                items: _mileageOptions
                    .map((mileage) => DropdownMenuItem(
                          value: mileage,
                          child: Text(mileage, style: TextStyle(color: Colors.grey[800])),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMileage = value!;
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Select mileage' : null,
              ),

              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _fuelType,
                decoration: _inputDecoration('Fuel Type'),
                items: ['Petrol', 'Diesel', 'Electric', 'Hybrid']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type, style: TextStyle(color: Colors.grey[800])),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _fuelType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _image == null
                  ? Text('No image selected', style: TextStyle(color: Colors.grey[700]))
                  : Image.file(_image!, height: 150),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Select Image from Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCarToFirestore,
                child: const Text('Add Car'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
