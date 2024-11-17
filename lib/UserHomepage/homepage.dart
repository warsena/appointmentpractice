import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; //
import '../Appointment/appointmentgambang.dart';
import '../Appointment/appointmentpekan.dart';
import '../profile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  // Define navigation logic for each bottom bar item
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Define widgets for each tab
  Widget _getTabWidget(int index) {
    switch (index) {
      case 0:
        return const Center(
            child: Text('Homepage', style: TextStyle(fontSize: 24)));
      case 1:
        return const AppointmentPage();
      case 2:
        return const Center(
            child: Text('Notification', style: TextStyle(fontSize: 24)));
      case 3:
        return const Profile(); // Navigate to the Profile page
      default:
        return const Center(child: Text('Unknown Page'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dual Campus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true, // This centers the title
        backgroundColor: Colors.teal,
      ),
      body: _getTabWidget(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appointment'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Appointment'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select Campus',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20.0),
                buildCampusButton(context, 'UMPSA Gambang', const Appointmentgambang()), //navigate to the Appointmentgambang page
                const SizedBox(height: 10.0),
                buildCampusButton(context, 'UMPSA Pekan', const Appointmentpekan()), //navigate to the Appointmentpekan page
              ],
            ),
            const HistoryTab(), // Add HistoryTab here
          ],
        ),
      ),
    );
  }
}

Widget buildCampusButton(BuildContext context, String campusName, Widget page) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16.0),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        backgroundColor: Colors.teal[100], // Light turquoise background color
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, color: Colors.teal),
          const SizedBox(width: 10.0),
          Text(
            campusName,
            style: const TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ],
      ),
    ),
  );
}

// History Tab Widget to show appointment history
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the currently logged-in user's ID
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Please log in to view your appointment history.'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Appointment')
          .where('User_ID', isEqualTo: user.uid) // Filter by User ID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No appointment history found.'));
        }

        final appointments = snapshot.data!.docs;

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment =
                appointments[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text('Service: ${appointment['Appointment_Service']}'),
                subtitle: Text(
                  'Date: ${appointment['Appointment_Date']}\n'
                  'Time: ${appointment['Appointment_Time']}\n'
                  'Campus: ${appointment['Appointment_Campus']}',
                ),
                trailing: Text('ID: ${appointments[index].id}'),
              ),
            );
          },
        );
      },
    );
  }
}