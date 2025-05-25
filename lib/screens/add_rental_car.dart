import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class AddRentalCarPage extends StatefulWidget {
  const AddRentalCarPage({super.key});

  @override
  State<AddRentalCarPage> createState() => _AddRentalCarPageState();
}

class _AddRentalCarPageState extends State<AddRentalCarPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rentalPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _fuelType = 'Petrol';
  File? _image;
  final ImagePicker picker = ImagePicker();
  final String imgbbApiKey = '409164d54cc9cb69bc6e0c8910d9f487'; // ✅ Your API key

  final List<String> _mileageOptions = ['10 km/l', '12 km/l', '15 km/l', '18 km/l', '20 km/l', '25 km/l'];
  String _selectedMileage = '15 km/l';

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showMessage('Image selection failed: $e', isError: true);
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
        print('Image upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> _addRentalCarToFirestore() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        final imageUrl = await uploadImageToImgBB(_image!);
        if (imageUrl == null) throw Exception("Failed to upload image.");

        await FirebaseFirestore.instance.collection('rental_cars').add({
          'name': _nameController.text.trim(),
          'rentalPrice': double.parse(_rentalPriceController.text.trim()),
          'description': _descriptionController.text.trim(),
          'specifications': {
            'mileage': _selectedMileage,
            'fuelType': _fuelType,
          },
          'imageUrl': imageUrl,
          'createdAt': Timestamp.now(),
        });

        _showMessage('Rental car added successfully!', isSuccess: true);
        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _fuelType = 'Petrol';
          _selectedMileage = '15 km/l';
        });
      } catch (e) {
        _showMessage('Error: $e', isError: true);
      }
    } else {
      _showMessage('Fill all fields and select an image.', isError: true);
    }
  }

  void _showMessage(String message, {bool isSuccess = false, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : (isSuccess ? Colors.green : Colors.deepPurple),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.deepPurple),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rentalPriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Rental Car', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
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
                style: const TextStyle(color: Colors.deepPurple),
                validator: (value) => value == null || value.isEmpty ? 'Enter car name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rentalPriceController,
                decoration: _inputDecoration('Rental Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.deepPurple),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter rental price';
                  final n = num.tryParse(value);
                  if (n == null || n <= 0) return 'Enter valid price';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration('Description'),
                maxLines: 3,
                style: const TextStyle(color: Colors.deepPurple),
                validator: (value) => value == null || value.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedMileage,
                decoration: _inputDecoration('Mileage'),
                items: _mileageOptions.map((mileage) {
                  return DropdownMenuItem(
                    value: mileage,
                    child: Text(mileage),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedMileage = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _fuelType,
                decoration: _inputDecoration('Fuel Type'),
                items: ['Petrol', 'Diesel', 'Electric', 'Hybrid'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _fuelType = value!),
              ),
              const SizedBox(height: 16),
              _image == null
                  ? const Text('No image selected', style: TextStyle(color: Colors.deepPurple))
                  : Image.file(_image!, height: 150),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text('Select Image', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addRentalCarToFirestore,
                child: const Text('Add Rental Car', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
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