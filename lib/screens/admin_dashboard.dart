import 'package:carmarketplace/screens/add_rental_car.dart';
import 'package:carmarketplace/screens/addmin_buy_viewcar.dart';
import 'package:carmarketplace/screens/addmin_view_rental_car_user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:carmarketplace/screens/addcar.dart';
import 'package:carmarketplace/screens/rental_report.dart';
import 'package:carmarketplace/screens/login_screen.dart';
import 'package:carmarketplace/screens/feedbackreport.dart';
import 'package:carmarketplace/screens/buy_report.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<String> imagePaths = [
    'image/car0.jpg',
    'image/car00.jpg',
    'image/car000.jpg'
  ];
  final List<String> titles = [
    'Luxury Ride',
    'Performance Beast',
    'Eco-Friendly Drive'
  ];
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
  int rentalCars = 0;

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
      final rentalsSnapshot = await firestore.collection('rental_cars').get();
      setState(() {
        totalCars = carSnapshot.docs.length;
        totalBuys = buySnapshot.docs.length;
        totalRentals = rentalSnapshot.docs.length;
        rentalCars = rentalsSnapshot.docs.length;
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Card(
      color: color, // This line sets the background color of the card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white), // Smaller icon size
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10, // Smaller font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              count,
              style: const TextStyle(
                fontSize: 14, // Smaller font size
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
    return Card(
      color: Colors.white, // This line sets the background color of the card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color), // Smaller icon size
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10, // Smaller font size
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardGrid(List<Widget> cards, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 3, // Changed for more columns on large screens
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8, // Reduced spacing
        mainAxisSpacing: 8, // Reduced spacing
        childAspectRatio: 0.9, // More rectangular shape
        children: cards,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = [
      _buildStatCard(
        icon: Icons.directions_car_filled,
        title: 'Buy Cars', // Simplified title
        count: totalCars.toString(),
        color: Colors.lightBlueAccent,
      ),
      _buildStatCard(
        icon: Icons.car_rental,
        title: 'Rentals', // Simplified title
        count: totalRentals.toString(),
        color: Colors.deepPurpleAccent,
      ),
      _buildStatCard(
        icon: Icons.shopping_cart,
        title: 'Buys', // Simplified title
        count: totalBuys.toString(),
        color: Colors.orangeAccent,
      ),
      _buildStatCard(
        icon: Icons.shopping_cart_checkout,
        title: 'Rental Cars', // Simplified title
        count: rentalCars.toString(),
        color: Colors.indigo,
      ),
      _buildQuickAction(
        icon: Icons.add_circle_outline,
        label: 'Add Buy Car',
        color: Colors.green,
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddCarPage()));
        },
      ),
      _buildQuickAction(
        icon: Icons.add_circle_outline,
        label: 'Add Rent Car',
        color: Colors.blueAccent,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddRentalCarPage()));
        },
      ),
      _buildQuickAction(
        icon: Icons.directions_car,
        label: 'View Buy Cars',
        color: Colors.blue,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const admin_buy_ViewCarPage()));
        },
      ),
      _buildQuickAction(
        icon: Icons.car_rental,
        label: 'View Rent Cars',
        color: Colors.orange,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => admin_rental_ViewCarPage())); // Corrected navigation to AdminViewRentalCarUserPage
        },
      ),
      _buildQuickAction(
        icon: Icons.analytics,
        label: 'Rental Reports',
        color: Colors.purple,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RentalReportWidget()));
        },
      ),
      _buildQuickAction(
        icon: Icons.receipt_long,
        label: 'Buy Reports',
        color: Colors.teal,
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => BuyReportPage()));
        },
      ),
    ];

    final isLargeScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: isLargeScreen ? null : Drawer(child: _buildSidebar()),
      appBar: AppBar(
        title: const Text('Car Marketplace Admin'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.deepPurple,
        leading: isLargeScreen
            ? null
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.deepPurple),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.feedback, color: Colors.deepPurple),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FeedbackReportPage()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (isLargeScreen)
              SizedBox(
                width: 200, // Reduced width for sidebar
                child: _buildSidebar(),
              ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 150, // Reduced height for carousel
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: imagePaths.length,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0), // Reduced padding
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8), // Smaller radius
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(imagePaths[index],
                                      fit: BoxFit.cover),
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
                                    left: 12, // Reduced from 16
                                    bottom: 30, // Reduced from 40
                                    child: Text(
                                      titles[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16, // Reduced from 18
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 12, // Reduced from 16
                                    bottom: 12, // Reduced from 16
                                    right: 12, // Reduced from 16
                                    child: Text(
                                      descriptions[index],
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10, // Reduced from 12
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
                  const SizedBox(height: 8), // Reduced spacing
                  Expanded(
                    child: SingleChildScrollView( // Added SingleChildScrollView to prevent overflow
                      child: _buildCardGrid(cards, context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 100, // Reduced height
            color: Colors.deepPurple,
            child: const Center(
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildSidebarItem(
            icon: Icons.add_circle_outline,
            label: 'Add Buy Car',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AddCarPage())),
          ),
          _buildSidebarItem(
            icon: Icons.add_circle_outline,
            label: 'Add Rent Car',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddRentalCarPage())),
          ),
          _buildSidebarItem(
            icon: Icons.directions_car,
            label: 'View Buy Cars',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const admin_buy_ViewCarPage())),
          ),
          _buildSidebarItem(
              icon: Icons.car_rental,
              label: 'View Rent Cars',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const admin_rental_ViewCarPage()))), // Corrected navigation
          _buildSidebarItem(
            icon: Icons.feedback,
            label: 'Feedback',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FeedbackReportPage())),
          ),
          _buildSidebarItem(
            icon: Icons.analytics,
            label: 'Rental Reports',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RentalReportWidget())),
          ),
          _buildSidebarItem(
            icon: Icons.receipt_long,
            label: 'Buy Reports',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => BuyReportPage())),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.deepPurple, size: 20), // Smaller icon
            title: const Text('Logout', style: TextStyle(fontSize: 14)), // Smaller text
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple, size: 20), // Smaller icon
      title: Text(label, style: const TextStyle(fontSize: 14)), // Smaller text
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding
    );
  }
}