import 'package:flutter/material.dart';
import 'package:appointmentpractice/login_page.dart';
import 'package:appointmentpractice/Profile/doctorprofile.dart';
import 'package:appointmentpractice/Schedule/doctorschedule.dart';
import 'package:appointmentpractice/Profile/setting.dart'; // Import Setting page
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Doctorhomepage extends StatefulWidget {
  const Doctorhomepage({super.key});

  @override
  State<Doctorhomepage> createState() => _DoctorhomepageState();
}

class _DoctorhomepageState extends State<Doctorhomepage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dual Campus',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Centers the title text
        backgroundColor: const Color.fromRGBO(37, 163, 255, 1),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(),
          Container(), // Placeholder for direct navigation to DoctorSchedule
          Container(), // Placeholder for direct navigation to Setting page
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            // Navigate to the DoctorSchedule page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorSchedule()),
            );
          } else if (index == 2) {
            // Navigate to the Setting page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Setting()), // Replace with your Setting page widget
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        selectedItemColor: const Color.fromRGBO(37, 163, 255, 1), // Custom blue color
        unselectedItemColor: Colors.grey, // Optional: grey for unselected items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return const Center(
      child: Align(
        alignment: Alignment.center,
        child: Text(
          'Welcome Doctor to the Dual Campus Booking',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
