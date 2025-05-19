import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carmarketplace/screens/viewcar.dart';
import 'package:carmarketplace/screens/addcar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<String> imagePaths = [
    'image/car0.jpg',
    'image/car00.jpg',
    'image/car000.jpg',
  ];

  final List<String> titles = [
    'Luxury Ride',
    'Performance Beast',
    'Eco-Friendly Drive',
  ];

  final List<String> descriptions = [
    'Experience unmatched comfort and class.',
    'Power and speed blended with style.',
    'Go green without compromising performance.',
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text('Car Marketplace Admin'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blue[900],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.blue[900]),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 24, bottom: 32),
          child: Column(
            children: [
              SizedBox(
                height: 280,
                child: imagePaths.isEmpty
                    ? Center(
                        child: Text(
                          'No images available.',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: imagePaths.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
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
                                      bottom: 60,
                                      child: Text(
                                        titles[index],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0, 1),
                                              blurRadius: 4,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 20,
                                      bottom: 30,
                                      right: 20,
                                      child: Text(
                                        descriptions[index],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
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
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.directions_car_filled,
                      title: 'Total Cars',
                      count: totalCars.toString(),
                      color: Colors.lightBlueAccent,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      icon: Icons.car_rental,
                      title: 'Total Rentals',
                      count: totalRentals.toString(),
                      color: Colors.deepPurpleAccent,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      icon: Icons.shopping_cart,
                      title: 'Total Buys',
                      count: totalBuys.toString(),
                      color: Colors.orangeAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
                colors: [Color(0xFF001F54), Color(0xFF003580)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage('image/profile.jpg'),
                ),
                SizedBox(height: 12),
                Text(
                  'Admin Panel',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'admin@example.com',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () {}),
          _buildDrawerItem(Icons.add_circle, 'Add Cars', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCarPage()));
          }),
          _buildDrawerItem(Icons.directions_car, 'View Cars', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewCarPage()));
          }),
          _buildDrawerItem(Icons.receipt, 'Reports', () {}),
          _buildDrawerItem(Icons.settings, 'Settings', () {}),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[900]),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Container(
        width: 140,
        height: 120,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
