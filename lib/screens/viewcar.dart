import 'package:carmarketplace/screens/ViewDetailPage.dart';
import 'package:carmarketplace/screens/addcar.dart';
import 'package:carmarketplace/screens/cartmanager.dart';
import 'package:carmarketplace/screens/cartpage.dart';
import 'package:carmarketplace/screens/rentalbookingpage.dart';
import 'package:carmarketplace/screens/editcar.dart'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewCarPage extends StatefulWidget {
  const ViewCarPage({super.key});

  @override
  State<ViewCarPage> createState() => _ViewCarPageState();
}

class _ViewCarPageState extends State<ViewCarPage> {
  final CartManager cartManager = CartManager();
  final Map<String, int> cartQuantities = {};

  void _increaseQuantity(String carId) {
    setState(() {
      cartQuantities[carId] = (cartQuantities[carId] ?? 1) + 1;
    });
  }

  void _decreaseQuantity(String carId) {
    setState(() {
      if ((cartQuantities[carId] ?? 1) > 1) {
        cartQuantities[carId] = cartQuantities[carId]! - 1;
      }
    });
  }

  Future<void> _deleteCar(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('carlist').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete car: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // keep soft light orange bg
      appBar: AppBar(
        title: const Text('🚗 Available Cars'),
        backgroundColor: Colors.deepPurple,  // changed to deepPurple
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Car',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCarPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('carlist').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          final cars = snapshot.data!.docs;

          if (cars.isEmpty) {
            return Center(
              child: Text(
                'No cars available right now 💔',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final doc = cars[index];
              final car = doc.data() as Map<String, dynamic>;
              final docId = doc.id;
              final specs = car['specifications'] ?? {};
              final carId = docId;
              final quantity = cartQuantities[carId] ?? 1;

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
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Buy: \$${car['buyPrice'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],  // use grey[700]
                                ),
                              ),
                              Text(
                                'Rent: \$${car['rentPrice'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Fuel: ${specs['fuelType'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                                    tooltip: 'Edit Car',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditCarPage(
                                            docId: docId,
                                            carData: car,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    tooltip: 'Delete Car',
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Confirmation'),
                                          content: Text('Are you sure you want to delete "${car['name']}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        _deleteCar(docId);
                                      }
                                    },
                                  ),
                                ],
                              )
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
                                MaterialPageRoute(
                                  builder: (context) => ViewDetailPage(carData: car),
                                ),
                              );
                            },
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[300],
                                child: IconButton(
                                  icon: Icon(Icons.remove, size: 18, color: Colors.grey[700]),
                                  onPressed: () => _decreaseQuantity(carId),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$quantity',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[300],
                                child: IconButton(
                                  icon: Icon(Icons.add, size: 18, color: Colors.grey[700]),
                                  onPressed: () => _increaseQuantity(carId),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    cartManager.addToCart({
                                      ...car,
                                      'selectedPrice': car['buyPrice'],
                                      'priceType': 'buy',
                                      'quantity': quantity,
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${car['name']} added to cart (x$quantity) 🧡',
                                        ),
                                        backgroundColor: Colors.green.shade100,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(12),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('Buy'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RentalBookingPage(carData: car),
                                ),
                              );
                            },
                            icon: const Icon(Icons.car_rental),
                            label: const Text('Rent'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.withOpacity(0.7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
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
