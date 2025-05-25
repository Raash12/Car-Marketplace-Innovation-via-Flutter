import 'package:carmarketplace/screens/Rent.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carmarketplace/screens/ViewDetailPage.dart';




class ViewrentalCarPage extends StatefulWidget {
  const ViewrentalCarPage({super.key});

  @override
  State<ViewrentalCarPage> createState() => _ViewUserCarPageState();
}

class _ViewUserCarPageState extends State<ViewrentalCarPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('Available rental Cars'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Search by name, fuel, etc...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.deepPurple.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
  
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rental_cars').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          final cars = snapshot.data!.docs;
          final filteredCars = cars.where((doc) {
            final car = doc.data() as Map<String, dynamic>;
            final specs = car['specifications'] ?? {};
            final name = (car['name'] ?? '').toString().toLowerCase();
            final fuelType = (specs['fuelType'] ?? '').toString().toLowerCase();
            final rentalPrice = (car['rentalPrice'] ?? '').toString().toLowerCase();
          

            return name.contains(_searchQuery) ||
                fuelType.contains(_searchQuery) ||
                rentalPrice.contains(_searchQuery);
                
          }).toList();

          if (filteredCars.isEmpty) {
            return Center(
              child: Text(
                'No cars found matching "$_searchQuery" 😞',
                style: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: filteredCars.length,
            itemBuilder: (context, index) {
              final doc = filteredCars[index];
              final car = doc.data() as Map<String, dynamic>;
              final specs = car['specifications'] ?? {};

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            car['imageUrl'] ?? '',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported, size: 110, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car['name'] ?? 'Unknown Car',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                              ),
                              const SizedBox(height: 6),
                              Text('rental: \$${car['rentalPrice'] ?? 'N/A'}', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                              Text('Fuel: ${specs['fuelType'] ?? 'N/A'}', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ViewDetailPage(carData: car)),
                              );
                            },
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RentalPage(carData: car)),
                              );
                            },
                            icon: const Icon(Icons.shopping_bag_outlined),
                            label: const Text('rent'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}