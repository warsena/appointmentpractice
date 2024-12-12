// Importing necessary packages and files
// import 'package:appointmentpractice/Appointment/appointmentlist.dart'; // Appointment list page
// import 'package:appointmentpractice/Appointment/createappointment.dart'; // Create appointment page
import 'package:appointmentpractice/HealthBulletin/bulletinlist.dart'; // Health bulletin list page
import 'package:appointmentpractice/HealthBulletin/createbulletin.dart'; // Create health bulletin page
import 'package:flutter/material.dart'; // Flutter framework for UI design
import 'package:appointmentpractice/Registration/userlist.dart'; // User list page
import 'package:appointmentpractice/Registration/doctorlist.dart'; // Doctor list page
import 'package:appointmentpractice/Registration/registrationuser.dart'; // User registration page
import 'package:appointmentpractice/Registration/registrationdoctor.dart'; // Doctor registration page
import 'package:appointmentpractice/login_page.dart'; // Login page

// Main widget for the Admin Home Page
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key}); // Constructor for the AdminHomePage

  @override
  State<AdminHomePage> createState() => _AdminHomePageState(); // State management
}

// State class for Admin Home Page
class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0; // Variable to track the selected page in the navigation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard', // Title for the app bar
          style: TextStyle(fontWeight: FontWeight.bold), // Bold style for title
        ),
        backgroundColor: const Color.fromARGB(255, 100, 200, 185), // AppBar color
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.person), // Profile icon
            onSelected: (value) {
              if (value == 1) {
                // Log out action
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()), // Navigate to login page
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.logout), // Log out icon
                  title: Text('Log Out'), // Log out text
                ),
              ),
            ],
          ),
        ],
      ),

      // Body of the Scaffold with indexed pages
      body: IndexedStack(
        index: _selectedIndex, // Index determines which page is displayed
        children: [
          _buildHomePage(), // Home Page
          _buildUserPage(), // User Management Page
          _buildDoctorPage(), // Doctor Management Page
          // _buildAppointmentPage(), // Appointment Management Page
          _buildSchedulePage(), // Schedule Page
          _buildHealthBulletinPage(), // Health Bulletin Page
        ],
      ),

      // Drawer for navigation
      drawer: Drawer(
        child: ListView(
          children: [
            // Header for the drawer
            Container(
              color: const Color.fromARGB(255, 100, 200, 185), // Header background color
              height: 60, // Adjust height for a smaller header
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Padding for header
              alignment: Alignment.centerLeft,
              child: const Text(
                'Admin Menu', // Drawer header text
                style: TextStyle(color: Colors.white, fontSize: 24), // Text style for header
              ),
            ),
            // Home navigation item
            ListTile(
              leading: const Icon(Icons.home), // Icon for Home
              title: const Text('Home'), // Text for Home
              selected: _selectedIndex == 0, // Highlight if selected
              onTap: () {
                setState(() {
                  _selectedIndex = 0; // Set index to Home
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            // User navigation section
            ExpansionTile(
              leading: const Icon(Icons.person), // Icon for User
              title: const Text('User'), // Title for User section
              children: [
                ListTile(
                  title: const Text('Register User'), // Register User text
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationUser()), // Navigate to Register User
                    );
                  },
                ),
                ListTile(
                  title: const Text('List User'), // List User text
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1; // Set index for User List
                    });
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserList()), // Navigate to User List
                    );
                  },
                ),
              ],
            ),
            // Doctor navigation section
            ExpansionTile(
              leading: const Icon(Icons.medical_services), // Icon for Doctor
              title: const Text('Doctor'), // Title for Doctor section
              children: [
                ListTile(
                  title: const Text('Register Doctor'), // Register Doctor text
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationDoctor()), // Navigate to Register Doctor
                    );
                  },
                ),
                ListTile(
                  title: const Text('Doctor List'), // Doctor List text
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2; // Set index for Doctor List
                    });
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DoctorList()), // Navigate to Doctor List
                    );
                  },
                ),
              ],
            ),

            // Appointment navigation section
            // ExpansionTile(
            //   leading: const Icon(Icons.calendar_today), // Icon for Appointment
            //   title: const Text('Appointment'), // Title for Appointment section
            //   children: [
            //     ListTile(
            //       title: const Text('Create Appointment'), // Create Appointment text
            //       onTap: () {
            //         Navigator.of(context).pop(); // Close the drawer
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(builder: (context) => const CreateAppointment()), // Navigate to Create Appointment
            //         );
            //       },
            //     ),
            //     ListTile(
            //       title: const Text('Appointment List'), // Appointment List text
            //       onTap: () {
            //         Navigator.of(context).pop(); // Close the drawer
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(builder: (context) => const AppointmentList()), // Navigate to Appointment List
            //         );
            //       },
            //     ),
            //   ],
            // ),

            // Schedule navigation item
            // ListTile(
            //   leading: const Icon(Icons.schedule), // Icon for Schedule
            //   title: const Text('Schedule'), // Text for Schedule
            //   selected: _selectedIndex == 4, // Highlight if selected
            //   onTap: () {
            //     setState(() {
            //       _selectedIndex = 4; // Set index for Schedule
            //     });
            //     Navigator.of(context).pop(); // Close the drawer
            //   },
            // ),

            // Health Bulletin navigation section
            ExpansionTile(
              leading: const Icon(Icons.health_and_safety), // Icon for Health Bulletin
              title: const Text('Health Bulletin'), // Title for Health Bulletin
              children: [
                ListTile(
                  title: const Text('Create Health Bulletin'), // Create Health Bulletin text
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateBulletin()), // Navigate to Create Health Bulletin
                    );
                  },
                ),
                ListTile(
                  title: const Text('Health Bulletin List'), // Health Bulletin List text
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BulletinList()), // Navigate to Health Bulletin List
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

  // Widget for Home Page
  Widget _buildHomePage() {
    return const Center(
      child: Align(
        alignment: Alignment.center,
        child: Text(
          'Welcome Admin to the Dual Campus Booking', // Welcome message
          textAlign: TextAlign.center, // Center align text
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Text style
        ),
      ),
    );
  }

  // Widget for User Management Page
  Widget _buildUserPage() {
    return const Center(
      child: Text(
        'User Management Page', // User Management message
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Text style
      ),
    );
  }

  // Widget for Doctor Management Page
  Widget _buildDoctorPage() {
    return const Center(
      child: Text(
        'Doctor Management Page', // Doctor Management message
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Text style
      ),
    );
  }

  // Widget for Appointment Management Page
  // Widget _buildAppointmentPage() {
  //   return const Center(
  //     child: Text(
  //       'Appointment Management Page', // Appointment Management message
  //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Text style
  //     ),
  //   );
  // }

  // Widget for Schedule Page
  Widget _buildSchedulePage() {
    return const Center(
      child: Text(
        'Schedule Management Page', // Schedule Management message
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Text style
      ),
    );
  }

  // Widget for Health Bulletin Page
  Widget _buildHealthBulletinPage() {
    return const Center(
      child: Text(
        'Health Bulletin Page', // Health Bulletin message
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Text style
      ),
    );
  }
}
