import 'package:carmarketplace/screens/feedbackreport.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carmarketplace/screens/viewcar.dart';
import 'package:carmarketplace/screens/addcar.dart';
import 'package:carmarketplace/screens/rentalReport.dart';
import 'package:carmarketplace/screens/login_screen.dart';
// <-- Import this

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<String> imagePaths = ['image/car0.jpg', 'image/car00.jpg', 'image/car000.jpg'];
  final List<String> titles = ['Luxury Ride', 'Performance Beast', 'Eco-Friendly Drive'];
  final List<String> descriptions = [
    'Experience unmatched comfort and class.',
    'Power and speed blended with style.',
    'Go green without compromising performance.'
  ];

  late final PageController _pageController;
  int _currentPage = 0;
  int totalCars = 0;
  int totalBuys = 0;
  int totalRentals = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoPlay();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    final firestore = FirebaseFirestore.instance;
    try {
      final carSnapshot = await firestore.collection('carlist').get();
      final buySnapshot = await firestore.collection('buy').get();
      final rentalSnapshot = await firestore.collection('rental').get();
      setState(() {
        totalCars = carSnapshot.docs.length;
        totalBuys = buySnapshot.docs.length;
        totalRentals = rentalSnapshot.docs.length;
      });
    } catch (e) {
      debugPrint('Error fetching counts: $e');
    }
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_currentPage < imagePaths.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients && imagePaths.isNotEmpty) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuint,
        );
      }
      _startAutoPlay();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text('Car Marketplace Admin'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.deepPurple,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.deepPurple),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.feedback, color: Colors.deepPurple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackReportPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: imagePaths.isEmpty
                    ? const Center(
                        child: Text(
                          'No images available.',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: imagePaths.length,
                        onPageChanged: (index) => setState(() => _currentPage = index),
                        itemBuilder: (context, index) {
                          final imagePath = imagePaths[index];
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double value = 1.0;
                              if (_pageController.position.haveDimensions) {
                                value = _pageController.page! - index;
                                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                              }
                              return Transform.scale(scale: value, child: child);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(imagePath, fit: BoxFit.cover),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.7),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 20,
                                      bottom: 50,
                                      child: Text(
                                        titles[index],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 20,
                                      bottom: 20,
                                      right: 20,
                                      child: Text(
                                        descriptions[index],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Stats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 120,
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 13,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatCard(
                        icon: Icons.directions_car_filled,
                        title: 'Total Cars',
                        count: totalCars.toString(),
                        color: Colors.lightBlueAccent,
                      ),
                      _buildStatCard(
                        icon: Icons.car_rental,
                        title: 'Total Rentals',
                        count: totalRentals.toString(),
                        color: Colors.deepPurpleAccent,
                      ),
                      _buildStatCard(
                        icon: Icons.shopping_cart,
                        title: 'Total Buys',
                        count: totalBuys.toString(),
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 120,
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildQuickAction(
                        icon: Icons.add_circle_outline,
                        label: 'Add Car',
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddCarPage()),
                          );
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.directions_car,
                        label: 'View Cars',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ViewCarPage()),
                          );
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.analytics,
                        label: 'Reports',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReportsPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Removed floatingActionButton here
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(color: Colors.deepPurple)),
      onTap: onTap,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF673AB7), Color(0xFF673AB7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 32, backgroundImage: AssetImage('image/profile.jpg')),
                SizedBox(height: 12),
                Text('Admin Panel',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('admin@gmail.com', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.add_circle, 'Add Cars', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCarPage()));
          }),
          _buildDrawerItem(Icons.directions_car, 'View Cars', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewCarPage()));
          }),
          _buildDrawerItem(Icons.analytics, 'Reports', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsPage()));
          }),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', () {
            Navigator.pop(context);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          }),
        ],
      ),
    );
  }
}
