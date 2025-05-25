import 'package:flutter/material.dart';

class ViewDetailPage extends StatelessWidget {
  final Map<String, dynamic> carData;
  const ViewDetailPage({super.key, required this.carData});
  @override
  Widget build(BuildContext context) {
    final specs = carData['specifications'] ?? {};
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      body: CustomScrollView(
        slivers: [
          // Car image with SliverAppBar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                carData['name'] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white, // Make title white
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    )
                  ],
                ),
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

          // Details Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     
                      _buildInfoBox('Mileage', specs['mileage'] ?? 'N/A'),
                      _buildInfoBox('Fuel', specs['fuelType'] ?? 'N/A'),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    carData['description'] ?? 'No description available.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
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
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
