import 'package:flutter/material.dart';
import 'landingpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Landingpage(), // Instantiate the LandingPage widget
    );
  }
}