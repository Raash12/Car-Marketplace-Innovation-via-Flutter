import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:carmarketplace/screens/viewcar.dart';
import 'package:carmarketplace/screens/addcar.dart';
import 'package:carmarketplace/screens/RentalBookingPage.dart'; // ← Import this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Marketplace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Optional: Use routes or navigate with MaterialPageRoute
      home: const ViewCarPage(), // You can change this to AddCarPage() for testing
    );
  }
}
