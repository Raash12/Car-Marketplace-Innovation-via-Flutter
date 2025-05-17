import 'package:flutter/material.dart';

class ViewDetailPage extends StatelessWidget {
  final Map<String, dynamic> carData;

  const ViewDetailPage({super.key, required this.carData});

  @override
  Widget build(BuildContext context) {
    final specs = carData['specifications'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar with car image
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                carData['name'] ?? '',
                style: const TextStyle(fontSize: 18, shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  )
                ]),
              ),
              background: Image.network(
                carData['imageUrl'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 80),
                ),
              ),
            ),
          ),

          // Sliver Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${carData['price'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBox('Quantity', '${carData['quantity'] ?? 'N/A'}'),
                      _buildInfoBox('Mileage', specs['mileage'] ?? 'N/A'),
                      _buildInfoBox('Fuel', specs['fuelType'] ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    carData['description'] ?? 'No description available.',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                 ElevatedButton.icon(
  onPressed: () => Navigator.pop(context),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange, // changed from black to orange
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  icon: const Icon(Icons.arrow_back, color: Colors.white), // icon color
  label: const Text(
    'Back to Cars',
    style: TextStyle(fontSize: 18, color: Colors.white), // text color
  ),
),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple.shade100),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(221, 243, 8, 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
