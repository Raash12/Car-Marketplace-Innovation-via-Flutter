import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();

  String _fuelType = 'Petrol';
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addCarToFirestore() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('car_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

        final uploadTask = storageRef.putFile(_image!);
        final TaskSnapshot snapshot = await uploadTask;

        // Get the download URL
        final imageUrl = await snapshot.ref.getDownloadURL();

        // Save car data with imageUrl in Firestore
        await FirebaseFirestore.instance.collection('carlist').add({
          'name': _nameController.text.trim(),
          'price': _priceController.text.trim(),
          'description': _descriptionController.text.trim(),
          'quantity': int.parse(_quantityController.text.trim()),
          'specifications': {
            'mileage': _mileageController.text.trim(),
            'fuelType': _fuelType,
          },
          'imageUrl': imageUrl,
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
        const SnackBar(content: Text('Please complete all fields & select an image')),
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
                decoration: const InputDecoration(labelText: 'Fuel Type'),
              ),
              const SizedBox(height: 10),
              _image == null
                  ? const Text('No image selected')
                  : Image.file(_image!, height: 150),
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
