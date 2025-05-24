import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carmarketplace/screens/viewcar.dart';
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
    final List<Widget> cards = [
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
      _buildQuickAction(
        icon: Icons.add_circle_outline,
        label: 'Add Car',
        color: Colors.green,
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const AddCarPage()));
        },
      ),
      _buildQuickAction(
        icon: Icons.directions_car,
        label: 'View Cars',
        color: Colors.blue,
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const ViewCarPage()));
        },
      ),
      _buildQuickAction(
        icon: Icons.analytics,
        label: 'Rental Reports',
        color: Colors.purple,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const RentalReportWidget()));
        },
      ),
      _buildQuickAction(
        icon: Icons.receipt_long,
        label: 'Buy Reports',
        color: Colors.teal,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>  BuyReportPage()));
        },
      ),
    ];

    final isLargeScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: isLargeScreen ? null : _buildDrawer(),
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
                MaterialPageRoute(builder: (context) => const FeedbackReportPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (isLargeScreen)
              SizedBox(
                width: 250,
                child: _buildSidebar(), // Permanent Sidebar
              ),
            Expanded(
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
                    _buildCardGridFlexible(cards),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar similar to drawer but permanent
  Widget _buildSidebar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 120,
            color: Colors.deepPurple,
            child: const Center(
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildSidebarItem(
            icon: Icons.add_circle_outline,
            label: 'Add Car',
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const AddCarPage()));
            },
          ),
          _buildSidebarItem(
            icon: Icons.directions_car,
            label: 'View Cars',
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const ViewCarPage()));
            },
          ),
          _buildSidebarItem(
            icon: Icons.feedback,
            label: 'Feedback',
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const FeedbackReportPage()));
            },
          ),
          _buildSidebarItem(
            icon: Icons.analytics,
            label: 'Rental Reports',
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const RentalReportWidget()));
            },
          ),
          _buildSidebarItem(
            icon: Icons.receipt_long,
            label: 'Buy Reports',
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => BuyReportPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.deepPurple),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  LoginScreen()),
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
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label),
      onTap: onTap,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: _buildSidebar(), // reuse sidebar content
    );
  }

  Widget _buildCardGridFlexible(List<Widget> cards) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = 24 * 2; // padding on left and right
    final spacing = 16 * 2; // two gaps between 3 cards per row
    final cardWidth = (width - horizontalPadding - spacing) / 3;

    List<Widget> cardWidgets = [];

    for (int i = 0; i < cards.length; i++) {
      final isLastSingle = (i == cards.length - 1) && (cards.length % 3 != 0);
      cardWidgets.add(
        SizedBox(
          width: isLastSingle ? (width - horizontalPadding) : cardWidth,
          child: cards[i],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: cardWidgets,
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w600,
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
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}