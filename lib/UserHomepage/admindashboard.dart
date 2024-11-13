import 'package:appointmentpractice/Appointment/appointmentlist.dart';
import 'package:appointmentpractice/Appointment/createappointment.dart';
import 'package:appointmentpractice/HealthBulletin/bulletinlist.dart';
import 'package:appointmentpractice/HealthBulletin/createbulletin.dart';
import 'package:flutter/material.dart';
import 'package:appointmentpractice/Registration/userlist.dart';
import 'package:appointmentpractice/Registration/doctorlist.dart';
import 'package:appointmentpractice/Registration/registrationuser.dart';
import 'package:appointmentpractice/Registration/registrationdoctor.dart';
import 'package:appointmentpractice/login_page.dart'; // Import your login page

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.person),
            onSelected: (value) {
              if (value == 1) {
                // Log out action
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
          _buildUserPage(),
          _buildDoctorPage(),
          _buildAppointmentPage(),
          _buildSchedulePage(), // Add Schedule Page
          _buildHealthBulletinPage(), // Add Health Bulletin Page
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              color: Colors.teal,
              height: 60, // Adjust height to make the box smaller
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,

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
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.person),
              title: const Text('User'),
              children: [
                ListTile(
                  title: const Text('Register User'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrationUser()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('List User'),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1; // Assuming this directs to List User
                    });
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserList()),
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Doctor'),
              children: [
                ListTile(
                  title: const Text('Register Doctor'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrationDoctor()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Doctor List'),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DoctorList()),
                    );
                  },
                ),
              ],
            ),

            
            ExpansionTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Appointment'),
              children: [
                ListTile(
                  title: const Text('Create Appointment'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateAppointment()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Appointment List'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AppointmentList()),
                    );
                  },
                ),
              ],

            ),


            ListTile(
              leading: const Icon(Icons.schedule), // Schedule icon
              title: const Text('Schedule'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.health_and_safety),
              title: const Text('Health Bulletin'),
              children: [
                ListTile(
                  title: const Text('Create Health Bulletin'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateBulletin()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Health Bulletin List'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BulletinList()),
                    );
                  },
                ),
              ],
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
          'Welcome Admin to the Dual Campus Booking',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildUserPage() {
    return const Center(
      child: Text(
        'User Management Page',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDoctorPage() {
    return const Center(
      child: Text(
        'Doctor Management Page',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildSchedulePage() {
    return const Center(
      child: Text(
        'Schedule Management Page',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHealthBulletinPage() {
    return const Center(
      child: Text(
        'Health Bulletin Page',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
