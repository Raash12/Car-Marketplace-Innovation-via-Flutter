// import 'package:carmarketplace/screens/buy_report.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:carmarketplace/screens/welcome_screen.dart';
// import 'package:carmarketplace/screens/login_screen.dart';
// import 'package:carmarketplace/screens/register_screen.dart';
// import 'package:carmarketplace/screens/admin_dashboard.dart';
// import 'package:carmarketplace/screens/addcar.dart';
// import 'package:carmarketplace/screens/viewcar.dart';
// import 'package:carmarketplace/screens/viewcar_user.dart';

// import 'package:carmarketplace/screens/rental_report.dart';
// import 'package:carmarketplace/screens/feedbackreport.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Car Marketplace',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const BuyReportWidget(), // Start from the welcome screen
//       routes: {
//         '/welcome': (context) => const WelcomeScreen(),
//         '/login': (context) =>  LoginScreen(),
//         '/register': (context) => const RegistrationScreen(),
//         '/adminDashboard': (context) => const AdminDashboard(),
//         '/addCar': (context) => const AddCarPage(),
//         '/viewCars': (context) => const ViewCarPage(),
//         '/viewCarUser': (context) => const ViewUserCarPage(),
//         '/feedbackReport': (context) => const FeedbackReportPage(),
//           '/rentalReport': (context) => const RentalReportWidget(),  // Add rental report route
//         '/buyReport': (context) =>  BuyReportPage(),
//       },
//     );
//   }
// }

import 'package:carmarketplace/screens/Rent.dart';
import 'package:carmarketplace/screens/buy_report.dart';
import 'package:carmarketplace/screens/addmin_view_rental_car_user.dart';
import 'package:carmarketplace/screens/home_screen.dart';
import 'package:carmarketplace/screens/viewrentalcar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:carmarketplace/screens/welcome_screen.dart';
import 'package:carmarketplace/screens/login_screen.dart';
import 'package:carmarketplace/screens/register_screen.dart';
import 'package:carmarketplace/screens/admin_dashboard.dart';
import 'package:carmarketplace/screens/addcar.dart';
import 'package:carmarketplace/screens/addmin_buy_viewcar.dart';
import 'package:carmarketplace/screens/viewcar_user.dart';

import 'package:carmarketplace/screens/rental_report.dart';
import 'package:carmarketplace/screens/feedbackreport.dart';
import 'package:carmarketplace/screens/add_rental_car.dart';

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
        home: const ViewrentalCarPage() // viewStart from the welcome screen

        );
  }
}
