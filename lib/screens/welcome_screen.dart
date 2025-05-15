import 'package:flutter/material.dart';
import 'package:carmarketplace/screens/register_screen.dart'; // ← import your registration page

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Top title row
              Row(
                children: const [
                  Icon(Icons.directions_car, size: 28, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    "Car sales",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),

              // Main welcome text
              const Text(
                "WELCOME TO OUR",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  height: 0.1,
                ),
              ),
              const Text(
                "ADVANCED",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  height: 0.1,
                ),
              ),
              const Text(
                "CAR MARKETPLACE",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  height: 0.1,
                ),
              ),

              // Car with orange moon
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    Positioned(
                      right: 70,
                      top: 0,
                      child: Container(
                        width: 80,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 115,
                      top: 20,
                      child: Image.asset(
                        'image/welcome.png',
                        height: 180,
                      ),
                    ),
                  ],
                ),
              ),

              // ← WRAP IN GestureDetector TO NAVIGATE
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegistrationScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      "Let’s Get Started!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 28,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
