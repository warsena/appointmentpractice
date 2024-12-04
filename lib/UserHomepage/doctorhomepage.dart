import 'package:flutter/material.dart';
import 'package:appointmentpractice/login_page.dart';
import 'package:appointmentpractice/Profile/doctorprofile.dart';
import 'package:appointmentpractice/Schedule/doctorschedule.dart';
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
          'Doctor Dashboard', 
          style: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor:const Color.fromRGBO(37, 163, 255, 1), // Set AppBar background color to blue
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              if (value == 1) {
                // Navigate to DoctorProfile page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DoctorProfile()),
                );
              } else if (value == 2) {
                // Log Out action: Navigate to the login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Profile'),
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(),
          _buildAppointmentPage(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              color: const Color.fromRGBO(37, 163, 255, 1),
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Doctor Menu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Appointment'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule'),
              onTap: () async {
                try {
                  // Get the current authenticated user
                  User? currentUser = FirebaseAuth.instance.currentUser;

                  if (currentUser != null) {
                    // Retrieve the User_ID (UID) of the current user
                    String userId = currentUser.uid;

                    // Retrieve data from Firebase based on User_ID
                    DocumentSnapshot userDoc = await FirebaseFirestore.instance
                        .collection('User') // Collection name in your Firebase
                        .doc(userId)
                        .get();

                    if (userDoc.exists) {
                      // Extract 'Campus' and 'Selected_Service' fields from the document
                      String campus = userDoc['Campus'] ?? 'Default Campus';
                      String service = userDoc['Selected_Service'] ?? 'Default Service';

                      // Navigate to the DoctorSchedule page with retrieved data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorSchedule(
                            campus: campus,
                            service: service,
                          ),
                        ),
                      );
                    } else {
                      // Handle the case where the document doesn't exist
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not found in Firebase')),
                      );
                    }
                  } else {
                    // Handle the case where the user is not authenticated
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User is not logged in')),
                    );
                  }
                } catch (e) {
                  // Handle errors (e.g., network issues, permission issues)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        ),
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

  Widget _buildAppointmentPage() {
    return const Center(
      child: Text(
        'Appointment Management Page',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}