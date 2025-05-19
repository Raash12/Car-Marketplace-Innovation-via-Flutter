import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoPlay();
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
      backgroundColor: Colors.grey[100],
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text('Car Marketplace Admin'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueGrey[50]!, Colors.grey[200]!],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: imagePaths.isEmpty
                      ? Center(
                          child: Text(
                            'No images available.',
                            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                              Colors.black.withOpacity(0.6),
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
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 227, 175, 7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildIcon(Icons.dashboard, 'Dashboard', Colors.blue, () {}),
                      _buildIcon(Icons.add_circle, 'Add Cars', Colors.orange, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCarPage()));
                      }),
                      _buildIcon(Icons.directions_car, 'View Cars', Colors.green, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewCarPage()));
                      }),
                      _buildIcon(Icons.receipt, 'Orders', Colors.teal, () {}),
                      _buildIcon(Icons.manage_accounts, 'Manage user', Colors.purple, () {}),
                      _buildIcon(Icons.settings, 'Settings', Colors.red, () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 231, 163, 4),
                  const Color.fromARGB(255, 242, 179, 6)
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('image/profile.jpg'),
                ),
                SizedBox(height: 10),
                Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 20)),
                Text('admin@example.com', style: TextStyle(color: Colors.white70)),
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
          _buildDrawerItem(Icons.receipt, 'Orders', () {}),
          _buildDrawerItem(Icons.manage_accounts, 'Manage users', () {}),
          _buildDrawerItem(Icons.settings, 'Settings', () {}),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[800]),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  Widget _buildIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
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
