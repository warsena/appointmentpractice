import 'package:flutter/material.dart';
import 'package:appointmentpractice/Schedule/doctorschedule.dart';
import 'package:appointmentpractice/Profile/setting.dart';
import 'package:appointmentpractice/MedicalCertificate/listmedicalcertificate.dart';

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
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(37, 163, 255, 1),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(),
          Container(), // Placeholder for direct navigation to DoctorSchedule
          Container(), // Placeholder for direct navigation to Setting page
          Container(), // Placeholder for medical certificate page
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
            // Navigate to the doctor medical certificate page
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ListMedicalCertificate()),
            );
          } else if (index == 3) {
            // Navigate to the setting page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Setting()),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        selectedItemColor: const Color.fromRGBO(37, 163, 255, 1),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        iconSize: 24.0,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0, // Adds a shadow to the bottom navigation bar
        backgroundColor: Colors.white, // Explicit background color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_late),
            label: 'Certificate',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Welcome Doctor to the Dual Campus Booking',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20), // Adds some spacing below the text
          ],
        ),
      ),
    );
  }
}