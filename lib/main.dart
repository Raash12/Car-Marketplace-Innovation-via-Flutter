import 'package:carmarketplace/screens/authstate.dart';
import 'package:carmarketplace/screens/login_screen.dart';
import 'package:carmarketplace/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:carmarketplace/screens/welcome_screen.dart'; // Import your WelcomePage
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  return runApp(MyApp());
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
      
     home: Authstate(),// Changed to your WelcomePage
    );
  }
}
