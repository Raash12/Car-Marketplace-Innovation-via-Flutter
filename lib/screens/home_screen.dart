import 'package:carmarketplace/screens/Info.dart';
import 'package:carmarketplace/screens/feedback.dart';
import 'package:carmarketplace/screens/login_screen.dart';
import 'package:carmarketplace/screens/viewcar_user.dart';
import 'package:carmarketplace/screens/viewrentalcar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';

// Import your existing pages here


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> carouselImages = [
    'image/car0.jpg',
    'image/car00.jpg',
    'image/car000.jpg',
  ];

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(), // Moved content below to a separate widget
    ViewUserCarPage(),
    ViewrentalCarPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
       
      ),
      drawer: _buildDrawer(context),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF0A2463),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Buy Car',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Rent Car',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF0A2463)),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              setState(() {
                _currentIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('feedback'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackFormPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutContactPage()),
              );
            },
          ),
         ListTile(
            leading: const Icon(Icons.logout, color: Colors.deepPurple),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }


  


 
}

// --- The Original Home Page UI (as separate widget) ---
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCarouselSwiper(),
          const SizedBox(height: 20),
          _buildQuickActions(context),
          const SizedBox(height: 20),
          _buildFeaturedCategories(context),
          const SizedBox(height: 20),
          _buildLatestDeals(context),
        ],
      ),
    );
  }

  static Widget _buildCarouselSwiper() {
    final List<String> carouselImages = [
      'image/car0.jpg',
      'image/car00.jpg',
      'image/car000.jpg',
    ];

    return SizedBox(
      height: 220,
      child: Swiper(
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(carouselImages[index]),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          );
        },
        itemCount: carouselImages.length,
        autoplay: true,
        autoplayDelay: 5000,
        duration: 1000,
        curve: Curves.easeInOut,
        pagination: SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            activeColor: Color(0xFF0A2463),
            color: Colors.grey[300],
            size: 8,
            activeSize: 10,
          ),
        ),
      ),
    );
  }

  static Widget _buildQuickActions(BuildContext context) {
    // Placeholder
    return Container();
  }

  static Widget _buildFeaturedCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Featured Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2463),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildCategoryCard(
                context,
                image: 'image/deal_.jpeg',
                title: 'Sedans',
                onTap: () {},
              ),
              _buildCategoryCard(
                context,
                image: 'image/car9.jpeg',
                title: 'SUVs',
                onTap: () {},
              ),
              _buildCategoryCard(
                context,
                image: 'image/car5.jpeg',
                title: 'Sports',
                onTap: () {},
              ),
              _buildCategoryCard(
                context,
                image: 'image/car1.jpeg',
                title: 'Electric',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildCategoryCard(BuildContext context, {
    required String image,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildLatestDeals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Latest Deals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2463),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(3, (index) {
          return _buildDealCard(context, index);
        }),
      ],
    );
  }

  static Widget _buildDealCard(BuildContext context, int index) {
    final deals = [
      {'title': 'Weekend Special', 'subtitle': '20% off all rentals'},
      {'title': 'New Arrival', 'subtitle': '2023 Models available now'},
      {'title': 'Trade-In Bonus', 'subtitle': 'Get extra \$1000 for your old car'},
    ];

    final List<String> dealImages = [
      'image/car5.jpeg',
      'image/car1.jpeg',
      'image/deal_.jpeg',
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  dealImages[index],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deals[index]['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deals[index]['subtitle']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A2463).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Limited Time',
                        style: TextStyle(
                          color: Color(0xFF0A2463),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
