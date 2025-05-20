import 'package:flutter/material.dart';

class AboutContactPage extends StatelessWidget {
  const AboutContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('About & Contact'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // About Section
            Text(
              'About CarMarketPlace',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'CarMarketPlace is a user-friendly platform for car enthusiasts and everyday drivers. '
              'We make car buying or renting simple, fast, and transparent. '
              'All vehicles are high quality with full specifications, competitive pricing, and real photos to help you decide confidently.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Contact Section
            Text(
              'Contact Us',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We’re here 7 days a week. Whether you have questions about a listing, renting, or suggestions, contact us:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              '📧 Email: support@carmarketplace.com\n'
              '📞 Phone: +1 (555) 123-4567\n'
              '🌐 Website: www.carmarketplace.com\n'
              '📍 Address: 123 Auto Lane, Motor City, USA',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),

            // License Section
            Text(
              'License & Terms',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'All app content including text, graphics, and listings belongs to CarMarketPlace. '
              'Unauthorized use is prohibited. By using this app, you accept our Terms of Service and Privacy Policy.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
