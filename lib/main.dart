
import 'package:carmarketplace/screens/addcar.dart';
import 'package:carmarketplace/screens/viewcar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:carmarketplace/screens/viewcar.dart';

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
<<<<<<< HEAD
      home: const AddCarPage(),       
=======
      home: const ViewCarPage(), // Change to AdminDashboard() or ViewCarPage() as needed
       
>>>>>>> 5a10e8c5d7819687c41c802268ee895b9600897b
    );
  }
}