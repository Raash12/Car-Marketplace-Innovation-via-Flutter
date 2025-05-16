import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewCarPage extends StatelessWidget {
  const ViewCarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Cars')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('carlist').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading cars'));
          }

          final cars = snapshot.data?.docs ?? [];

          if (cars.isEmpty) {
            return const Center(child: Text('No cars available'));
          }

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final carData = cars[index].data() as Map<String, dynamic>;
              final specs = carData['specifications'] ?? {};

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      carData['imageUrl'] != null
                          ? Image.network(
                              carData['imageUrl'],
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.directions_car, size: 100),
                      const SizedBox(height: 10),
                      Text('Name: ${carData['name'] ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Price: \$${carData['price'] ?? 'N/A'}'),
                      Text('Description: ${carData['description'] ?? 'N/A'}'),
                      Text('Quantity: ${carData['quantity'] ?? 'N/A'}'),
                      Text('Mileage: ${specs['mileage'] ?? 'N/A'}'),
                      Text('Fuel Type: ${specs['fuelType'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
