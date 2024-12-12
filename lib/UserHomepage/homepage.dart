import 'package:appointmentpractice/Profile/setting.dart';
import 'package:appointmentpractice/Profile/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../Appointment/appointmentgambang.dart';
import '../Appointment/appointmentpekan.dart';
import 'package:appointmentpractice/Appointment/rescheduleappointment.dart';
import 'package:appointmentpractice/Profile/setting.dart';
import 'package:appointmentpractice/Reminder/setreminder.dart';
import 'dart:async';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  String? notificationMessage;
  int appointmentCount = 0; // State variable for appointment count
  StreamSubscription? appointmentSubscription;

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
        return NotificationPage(
            notificationMessage: notificationMessage ?? 'No Notifications Yet');
      case 3:
        return const Setting();
      default:
        return const Center(child: Text('Unknown Page'));
    }
  }

  void startAppointmentListener() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Set up a real-time listener for the user's appointments
      appointmentSubscription = FirebaseFirestore.instance
          .collection('Appointment')
          .where('User_ID', isEqualTo: currentUser.uid)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          // Update the appointment count
          setState(() {
            appointmentCount = querySnapshot.docs.length;
          });

          // Build a message for all appointments
          String message = '';
          for (var doc in querySnapshot.docs) {
            final appointmentData = doc.data();
            final appointmentDate = appointmentData['Appointment_Date'];
            final appointmentTime = appointmentData['Appointment_Time'];

            if (appointmentDate != null && appointmentTime != null) {
              final date = DateTime.parse(appointmentDate);
              final formattedDate = DateFormat('d MMM yyyy').format(date);
              message +=
                  "You have an appointment on $formattedDate at $appointmentTime.\n";
            } else {
              message += "An appointment has incomplete details.\n";
            }
          }

          setState(() {
            notificationMessage = message.trim();
          });
        } else {
          setState(() {
            appointmentCount = 0; // No appointments
            notificationMessage = "No appointments found for this user.";
          });
        }
      }, onError: (error) {
        print("Error in listener: $error");
        setState(() {
          notificationMessage = "Error retrieving appointment details: $error";
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    startAppointmentListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dual Campus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
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
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (appointmentCount > 0) // Show badge only if count > 0
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(
                          2), // Smaller padding for a compact badge
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                            10), // Smaller radius for a compact shape
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12, // Smaller width for a smaller badge
                        minHeight: 12, // Smaller height for a smaller badge
                      ),
                      child: Text(
                        '$appointmentCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10, // Smaller font size for the badge
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notification',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    appointmentSubscription?.cancel(); // Cancel the subscription on dispose
    super.dispose();
  }
}

class NotificationPage extends StatefulWidget {
  final String notificationMessage;

  const NotificationPage({Key? key, required this.notificationMessage})
      : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<String> _parseMessages() {
    return widget.notificationMessage
        .split('\n')
        .where((message) => message.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _parseMessages();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0), // Space from top of screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: messages.isNotEmpty
                    ? ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: messages.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.teal.shade100),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.notifications,
                                    color: Colors.teal[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    messages[index],
                                    style: TextStyle(
                                      color: Colors.teal[900],
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off,
                              size: 100,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Notifications',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
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
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: const Color(0xFF009FA0),
                  borderRadius: BorderRadius.circular(30),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.blueGrey[600],
                tabs: const [
                  Tab(
                    child: Text(
                      'Upcoming',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'History',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueGrey,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[300],
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_late_outlined,
                          color: Color(0xFF009FA0),
                          size: 60,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No User Data Found',
                          style: TextStyle(
                            color: Color(0xFF009FA0),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final userCampus = userData['Campus'] as String;

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Select Campus',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(
                          height:
                              20.0), //spacing between select campus and button (UMPSA Campus)
                      if (userCampus == 'Pekan')
                        _buildCampusButton(
                          context,
                          'UMPSA Pekan',
                          const Appointmentpekan(),
                          Icons.location_city,
                        )
                      else if (userCampus == 'Gambang')
                        _buildCampusButton(
                          context,
                          'UMPSA Gambang',
                          const Appointmentgambang(),
                          Icons.school,
                        ),
                    ],
                  ),
                );
              },
            ),
            const HistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusButton(
    BuildContext context,
    String campusName,
    Widget page,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF009FA0),
            Color(0xFF009FA0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey[300]!.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 15.0),
            Text(
              campusName,
              style: const TextStyle(
                fontSize: 15.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetReminder(appointment: appointment),
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
