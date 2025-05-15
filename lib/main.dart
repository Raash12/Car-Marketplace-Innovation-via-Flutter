import 'package:carmarketplace/screens/login_screen.dart';
import 'package:carmarketplace/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:carmarketplace/screens/welcome_screen.dart';// Import your WelcomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Marketplace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  WelcomeScreen() , // Changed to your WelcomePage
    );
  }
}