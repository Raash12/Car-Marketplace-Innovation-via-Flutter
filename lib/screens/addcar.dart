import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _rentPriceController = TextEditingController();  // New controller
  final TextEditingController _buyPriceController = TextEditingController();   // New controller
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();

  String _fuelType = 'Petrol';
  File? _image;
  final ImagePicker picker = ImagePicker();

  final String imgbbApiKey = '409164d54cc9cb69bc6e0c8910d9f487';

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
          'price': _priceController.text.trim(),
          'buyPrice': _buyPriceController.text.trim(),  // Save buy price
          'rentPrice': _rentPriceController.text.trim(), // Save rent price
          'description': _descriptionController.text.trim(),
          'quantity': int.parse(_quantityController.text.trim()),
          'specifications': {
            'mileage': _mileageController.text.trim(),
            'fuelType': _fuelType,
          },
          'imageUrl': imageUrl,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car added successfully')),
        );

        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _fuelType = 'Petrol';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding car: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and select an image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Car')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Car Name'),
                validator: (value) => value!.isEmpty ? 'Enter car name' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter price' : null,
              ),
              // New buy price field
              TextFormField(
                controller: _buyPriceController,
                decoration: const InputDecoration(labelText: 'Buy Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter buy price' : null,
              ),
              // New rent price field
              TextFormField(
                controller: _rentPriceController,
                decoration: const InputDecoration(labelText: 'Rent Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter rent price' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Enter description' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
              ),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Mileage'),
                validator: (value) => value!.isEmpty ? 'Enter mileage' : null,
              ),
              DropdownButtonFormField<String>(
                value: _fuelType,
                decoration: const InputDecoration(labelText: 'Fuel Type'),
                items: ['Petrol', 'Diesel', 'Electric', 'Hybrid']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _fuelType = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              _image == null
                  ? const Text('No image selected')
                  : Image.file(_image!, height: 150),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Select Image from Device'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCarToFirestore,
                child: const Text('Add Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
