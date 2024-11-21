import 'package:appointmentpractice/Profile/setting.dart';
// import 'package:appointmentpractice/Profile/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../Appointment/appointmentgambang.dart';
import '../Appointment/appointmentpekan.dart';
import 'package:appointmentpractice/Appointment/rescheduleappointment.dart';
import 'package:appointmentpractice/Profile/setting.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getTabWidget(int index) {
    switch (index) {
      case 0:
        return const HealthBulletinPage();
      case 1:
        return const AppointmentPage();
      case 2:
        return const Center(
            child: Text('Notification', style: TextStyle(fontSize: 24)));
      case 3:
        return const Setting(); //Navigate to the Setting
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
        centerTitle: true,
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

class HealthBulletinPage extends StatelessWidget {
  const HealthBulletinPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current date at the start of the day
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Health_Bulletin')
          .orderBy('Bulletin_Start_Date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading health bulletins: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // No bulletins
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No health bulletins available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Filter and display active bulletins
        final bulletins = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final endDateStr = data['Bulletin_End_Date'];
          if (endDateStr == null) return false;

          final endDate = DateTime.tryParse(endDateStr);
          if (endDate == null) return false;

          // Set end date to end of day for comparison
          final endDateCompare = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
            23,
            59,
            59,
          );

          return endDateCompare.isAfter(currentDate);
        }).toList();

        if (bulletins.isEmpty) {
          return const Center(
            child: Text(
              'No active health bulletins available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: bulletins.length,
          itemBuilder: (context, index) {
            final bulletin = bulletins[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bulletin['Bulletin_Title'] ?? 'Untitled Bulletin',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bulletin['Bulletin_Description'] ??
                          'No description available',
                      style: const TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

//Widget for displaying the appointment page with campus selection
class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Appointment and History
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appointment'),
          // Tab bar for switching between Appointment and History views
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Appointment'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // StreamBuilder to listen to real-time updates from Firestore
            StreamBuilder<DocumentSnapshot>(
              // Get the current user's document from Firestore
              // Uses the logged-in user's UID to fetch their data
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                // Show loading indicator while fetching data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show error message if data fetch fails
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Show message if user data is not found
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('User data not found'));
                }

                // Extract user data from the snapshot
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                // Get the user's campus from the data
                final userCampus = userData['Campus'] as String;

                // Build the campus selection UI
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Select Campus',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20.0),
                    // Show campus button based on user's campus
                    if (userCampus == 'Pekan')
                      buildCampusButton(
                          context, 'UMPSA Pekan', const Appointmentpekan())
                    else if (userCampus == 'Gambang')
                      buildCampusButton(
                          context, 'UMPSA Gambang', const Appointmentgambang()),
                  ],
                );
              },
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
    // Add horizontal margin to the button
    margin: const EdgeInsets.symmetric(horizontal: 16.0),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        //Add vertical padding inside the button
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        backgroundColor: Colors.teal[100],
        // Remove button shadow
        elevation: 0,
        // Add rounded corners to the button
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
      // Button content layout
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, color: Colors.teal),
          const SizedBox(width: 10.0), // Space between icon and text
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
  const HistoryTab({Key? key}) : super(key: key);

//reschedule appointment
  // Function to reschedule the appointment
  Future<void> _rescheduleAppointment(
      BuildContext context, Map<String, dynamic> appointment) async {
    String campus = appointment['Appointment_Campus'];
    String appointmentId = appointment['Appointment_ID'];

    if (appointmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Appointment ID not found. Unable to reschedule.')),
      );
      return;
    }

    _navigateForReschedule(context, campus, appointmentId);
  }

// Navigation function to go to the appropriate appointment page based on campus
  void _navigateForReschedule(
      BuildContext context, String campus, String appointmentId) {
    if (campus == 'Gambang') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RescheduleAppointment(appointmentId: appointmentId),
        ),
      );
    } else if (campus == 'Pekan') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RescheduleAppointment(appointmentId: appointmentId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid campus for rescheduling')),
      );
    }
  }

  // Function to show the cancel dialog (delete appointnment from db)
  void _showCancelDialog(BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content:
              const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await _cancelAppointment(context, appointmentId);
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelAppointment(
      BuildContext context, String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Appointment')
          .doc(appointmentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling appointment: $e')),
      );
    }
  }

  Future<void> _setReminder(BuildContext context, Map appointment) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Reminder'),
        content: const Text('Reminder functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text('Please log in to view your appointment history.'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Appointment')
          .where('User_ID', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Show a loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle errors
        if (snapshot.hasError) {
          return Center(
            child: Text('An error occurred: ${snapshot.error}'),
          );
        }

        // Handle the case where there is no data
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No appointment history found.'),
          );
        }

        // If data exists, display the list of appointments
        final appointments = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index].data()
                as Map<String, dynamic>; // Explicit cast
            final appointmentId = appointments[index].id;

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center all content
                  children: [
                    Text(
                      'Service: ${appointment['Appointment_Service']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Date: ${appointment['Appointment_Date']}'),
                    Text('Time: ${appointment['Appointment_Time']}'),
                    Text('Campus: ${appointment['Appointment_Campus']}'),
                    const SizedBox(height: 16),
                    Container(
                      alignment: Alignment.center,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () =>
                                _rescheduleAppointment(context, appointment),
                            icon: const Icon(Icons.schedule, size: 16),
                            label: const Text('Reschedule'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _cancelAppointment(context, appointmentId),
                            icon: const Icon(Icons.cancel, size: 16),
                            label: const Text('Cancel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _setReminder(context, appointment),
                            icon: const Icon(Icons.alarm, size: 16),
                            label: const Text('Reminder'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
