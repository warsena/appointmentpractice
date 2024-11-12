import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'landingpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // title: 'My App',
      home: Landingpage(), // Instantiate the LandingPage widget
    );
  }
}

