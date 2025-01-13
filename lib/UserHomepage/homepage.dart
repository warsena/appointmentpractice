// Importing necessary packages and files
import 'package:appointmentpractice/Profile/setting.dart'; // For user settings page
import 'package:appointmentpractice/Profile/userprofile.dart'; // For user profile page
import 'package:flutter/material.dart'; // Flutter UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore for database interaction
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:intl/intl.dart'; // For date formatting
import '../Appointment/appointmentgambang.dart'; // Gambang campus appointment page
import '../Appointment/appointmentpekan.dart'; // Pekan campus appointment page
import 'package:appointmentpractice/Appointment/rescheduleappointment.dart'; // Reschedule appointment page
import 'package:appointmentpractice/Appointment/appointmenthistory.dart'; // Appointment history page
import 'package:appointmentpractice/Reminder/setreminder.dart'; // Set reminder page
import 'dart:async'; // For asynchronous programming

// Homepage widget with state management
class Homepage extends StatefulWidget {
  const Homepage({super.key}); // Constructor

  @override
  State<Homepage> createState() =>
      _HomepageState(); // Creates the state for this widget
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0; // State variable for selected bottom navigation index
  String? notificationMessage; // Holds notification messages
  int appointmentCount = 0; // Tracks the number of appointments
  StreamSubscription?
      appointmentSubscription; // Subscription for Firestore real-time updates

  // Handles bottom navigation item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Updates selected index
    });
  }

  // Returns the widget for the selected tab
  Widget _getTabWidget(int index) {
    switch (index) {
      case 0:
        return const HealthBulletinPage(); // Health Bulletin tab
      case 1:
        return const AppointmentPage(); // Appointment tab
      case 2:
        return NotificationPage(
            notificationMessage: notificationMessage ??
                'No Notifications Yet'); // Notification tab
      case 3:
        return const Setting(); // Settings tab
      default:
        return const Center(
            child: Text('Unknown Page')); // Fallback for unknown tabs
    }
  }

  // Listens for appointment updates in Firestore
  void startAppointmentListener() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Setting up real-time listener for appointments of the current user
      appointmentSubscription = FirebaseFirestore.instance
          .collection('Appointment')
          .where('User_ID', isEqualTo: currentUser.uid) // Query by user ID
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          // If there are appointments, update count and build notification message
          setState(() {
            appointmentCount = querySnapshot.docs.length;
          });

          // Build notification message from appointments
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
            notificationMessage = message.trim(); // Update notification message
          });
        } else {
          // No appointments found
          setState(() {
            appointmentCount = 0;
            notificationMessage = "No appointments found for this user.";
          });
        }
      }, onError: (error) {
        // Handle errors in the listener
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
    startAppointmentListener(); // Start listening for appointments
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Prevents the back arrow from being displayed
        title: const Text(
          'Dual Campus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true, // Centers the app bar title
        backgroundColor: Colors.teal, // Teal background for the app bar
      ),
      body: _getTabWidget(_selectedIndex), // Displays the selected tab's widget
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Sets the current selected tab
        onTap: _onItemTapped, // Calls _onItemTapped when a tab is tapped
        type: BottomNavigationBarType.fixed, // Fixed bottom navigation style
        selectedItemColor: Colors.teal, // Highlight color for selected tab
        unselectedItemColor: Colors.grey, // Color for unselected tabs
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // Home tab
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointment', // Appointment tab
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (appointmentCount > 0) // Show badge only if count > 0
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2), // Badge padding
                      decoration: BoxDecoration(
                        color: Colors.red, // Badge color
                        borderRadius:
                            BorderRadius.circular(10), // Rounded badge
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12, // Minimum width for badge
                        minHeight: 12, // Minimum height for badge
                      ),
                      child: Text(
                        '$appointmentCount', // Display appointment count
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10, // Font size for badge text
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notification', // Notification tab
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings', // Settings tab
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

// NotificationPage widget to display notifications
class NotificationPage extends StatefulWidget {
  final String notificationMessage; // Notification message to display

  const NotificationPage({Key? key, required this.notificationMessage})
      : super(key: key);

  @override
  _NotificationPageState createState() =>
      _NotificationPageState(); // State for NotificationPage
}

class _NotificationPageState extends State<NotificationPage> {
  // Parses notification messages into a list
  List<String> _parseMessages() {
    return widget.notificationMessage
        .split('\n') // Split by newline
        .where((message) => message.isNotEmpty) // Exclude empty messages
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _parseMessages(); // Get parsed messages

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
                        itemCount: messages.length, // Number of messages
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16), // Space between items
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.teal[50], // Background color
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.teal.shade100),
                            ),
                            padding: const EdgeInsets.all(16), // Item padding
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.notifications,
                                    color: Colors.teal[700]), // Icon
                                const SizedBox(
                                    width: 12), // Space between icon and text
                                Expanded(
                                  child: Text(
                                    messages[index], // Display message text
                                    style: TextStyle(
                                      color: Colors.teal[900],
                                      fontSize: 16, // Font size
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
                              size: 100, // Icon size for empty state
                              color: Colors.grey[300], // Icon color
                            ),
                            const SizedBox(height: 16), // Space below icon
                            Text(
                              'No Notifications', // Text for empty state
                              style: TextStyle(
                                color: Colors.grey[600], // Text color
                                fontSize: 18, // Font size
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

//display health bulletin for user
class HealthBulletinPage extends StatelessWidget {
  const HealthBulletinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Health_Bulletin')
          .orderBy('Bulletin_Start_Date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading health bulletins: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No health bulletins available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final bulletins = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final endDateStr = data['Bulletin_End_Date'];
          if (endDateStr == null) return false;

          final endDate = DateTime.tryParse(endDateStr);
          if (endDate == null) return false;

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
                    if (bulletin['Bulletin_Image_URL'] != null)
                      Container(
                        width: MediaQuery.of(context).size.width,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.network(
                          bulletin['Bulletin_Image_URL']!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.teal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
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

// Widget for displaying the appointment page with campus selection
class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Specifies three tabs: Appointment, Upcoming, and History
      child: Scaffold(
        backgroundColor:
            Colors.grey[100], // Sets the background color of the page
        appBar: AppBar(
          automaticallyImplyLeading:
              false, // Prevents the back arrow from being displayed
          backgroundColor: Colors.white, // Sets the app bar color
          elevation: 1, // Adds a slight shadow to the app bar
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(
                20), // Sets the height of the app bar's bottom
            child: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10), // Adds spacing around the tab bar
              decoration: BoxDecoration(
                color: Colors.grey[200], // Background color for the tab bar
                borderRadius: BorderRadius.circular(
                    30), // Rounded corners for the tab bar
              ),
              child: TabBar(
                indicatorPadding: EdgeInsets.zero,
                isScrollable: false, // Forces tabs to take equal width
                labelPadding: const EdgeInsets.symmetric(
                    horizontal: 10), // Adjusts padding
                indicator: BoxDecoration(
                  color: const Color(
                      0xFF009FA0), // Color for the active tab indicator
                  borderRadius:
                      BorderRadius.circular(20), // Rounds the indicator corners
                ),
                labelColor: Colors.white, // Color for active tab labels
                unselectedLabelColor:
                    Colors.blueGrey[600], // Color for inactive tab labels
                tabs: const [
                  Tab(
                    child: Text(
                      'Appointment', // First tab for campus selection
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Upcoming', // Second tab for upcoming appointments
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'History', // Third tab for appointment history
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
            // Tab for displaying the appointment campus selection
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User') // Fetches user data from Firestore
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueGrey, // Loading spinner color
                    ),
                  );
                }

                if (snapshot.hasError) {
                  // Displays error message when Firestore query fails
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[300], // Error icon color
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Oops! Something went wrong', // User-friendly error message
                          style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Error: ${snapshot.error}', // Displays specific error details
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  // Displays message when no user data is found
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_late_outlined,
                          color: Color(
                              0xFF009FA0), // Icon color for "no data" state
                          size: 60,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No User Data Found', // Informative message
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

                final userData = snapshot.data!.data()
                    as Map<String, dynamic>; // Extracts user data
                final userCampus =
                    userData['Campus'] as String; // Gets the user's campus

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Select Campus', // Header text for campus selection
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(
                          height: 20.0), // Spacing before campus buttons
                      if (userCampus ==
                          'Pekan') // Displays the Pekan campus button if applicable
                        _buildCampusButton(
                          context,
                          'UMPSA Pekan', // Button label
                          const Appointmentpekan(), // Navigates to Pekan appointment page
                          Icons.location_city, // Icon for Pekan
                        )
                      else if (userCampus ==
                          'Gambang') // Displays Gambang campus button if applicable
                        _buildCampusButton(
                          context,
                          'UMPSA Gambang', // Button label
                          const Appointmentgambang(), // Navigates to Gambang appointment page
                          Icons.school, // Icon for Gambang
                        ),
                    ],
                  ),
                );
              },
            ),
            const UpcomingTab(), // Tab for upcoming appointments
            const HistoryTab(), // Tab for appointment history
          ],
        ),
      ),
    );
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AppointmentHistory(),
        ),
      );
    });

    // Return an empty container or placeholder as this widget
    // will immediately navigate to another page.
    return Container();
  }
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

// History Tab Widget to show appointment history
class UpcomingTab extends StatefulWidget {
  const UpcomingTab({Key? key}) : super(key: key);

  @override
  _UpcomingTabState createState() => _UpcomingTabState();
}

class _UpcomingTabState extends State<UpcomingTab> {
  bool isBookingConfirmed = false;
  final Map<String, bool> confirmedAppointments = {};

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
    if (campus == 'Gambang' || campus == 'Pekan') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RescheduleAppointment(appointmentId: appointmentId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid campus for rescheduling.')),
      );
    }
  }

  // Function to display confirmation dialog for canceling the appointment
  void _showCancelConfirmationDialog(
      BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text(
              'Cancel Appointment',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
          style: TextStyle(color: Colors.black87, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text(
              'No',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _cancelAppointment(context, appointmentId); // Cancel appointment
            },
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to show a generic confirmation dialog
  void _showConfirmationDialog(BuildContext context, String title,
      String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Cancel the appointment
  Future<void> _cancelAppointment(
      BuildContext context, String appointmentId) async {
    if (appointmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Appointment ID')),
      );
      return;
    }
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

  // Function to set a reminder
  Future<void> _setReminder(BuildContext context, Map appointment) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetReminder(appointment: appointment),
      ),
    );
  }

  // Function to check if the appointment date is in the past
  bool _isAppointmentPast(String appointmentDate) {
    DateTime appointmentDateTime = DateTime.parse(appointmentDate);
    DateTime currentDateTime = DateTime.now();

    // Create DateTime for 11:59 PM of the appointment date
    DateTime appointmentEndTime = DateTime(
      appointmentDateTime.year,
      appointmentDateTime.month,
      appointmentDateTime.day,
      23,
      59,
    );

    return currentDateTime.isAfter(appointmentEndTime);
  }

  // Function to check if today is the appointment date
  bool _isAppointmentToday(String appointmentDate) {
    DateTime appointmentDateTime = DateTime.parse(appointmentDate);
    DateTime currentDateTime = DateTime.now();

    return appointmentDateTime.year == currentDateTime.year &&
        appointmentDateTime.month == currentDateTime.month &&
        appointmentDateTime.day == currentDateTime.day;
  }

  // Function to confirm booking with date check
  void _confirmBooking(
      BuildContext context, Map<String, dynamic> appointment) async {
    if (appointment['Appointment_ID'] == null ||
        appointment['Appointment_ID'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Invalid appointment data. Unable to confirm booking.')),
      );
      return;
    }

    // Check if today is the appointment date
    if (!_isAppointmentToday(appointment['Appointment_Date'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Booking can only be confirmed on the appointment date')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Appointment')
          .doc(appointment['Appointment_ID'])
          .update({
        'Appointment_Attendance': 'Attend',
        'isAttendanceConfirmed': true,
      });

      setState(() {
        confirmedAppointments[appointment['Appointment_ID']] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance confirmed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error confirming booking: $e')),
      );
    }
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('An error occurred: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No appointment history found.'),
          );
        }

        final appointments = snapshot.data!.docs;

        // Sort appointments: latest upcoming first, past ones last
        appointments.sort((a, b) {
          DateTime dateA =
              DateTime.parse((a['Appointment_Date'] ?? '').toString());
          DateTime dateB =
              DateTime.parse((b['Appointment_Date'] ?? '').toString());

          bool isPastA = _isAppointmentPast(a['Appointment_Date']);
          bool isPastB = _isAppointmentPast(b['Appointment_Date']);

          // If both are past or both are upcoming, sort by date descending
          if (isPastA == isPastB) {
            return dateB.compareTo(dateA);
          }

          // Place upcoming appointments before past ones
          return isPastA ? 1 : -1;
        });

        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment =
                appointments[index].data() as Map<String, dynamic>;
            final appointmentId = appointments[index].id;
            final appointmentDate = appointment['Appointment_Date'];

            bool isPastAppointment = _isAppointmentPast(appointmentDate);
            bool isConfirmed =
                appointment['isAttendanceConfirmed'] ?? false; // Check Firestore

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              // Add color property with conditional check
              color: isPastAppointment ? Colors.blueGrey[100] : Colors.white,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    Text(
                        'Service Reason: ${appointment['Appointment_Reason']}'),
                    const SizedBox(height: 16),
                    Container(
                      alignment: Alignment.center,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ElevatedButton.icon(
                            onPressed: isPastAppointment || isConfirmed
                                ? null
                                : () => _navigateForReschedule(
                                    context,
                                    appointment['Appointment_Campus'],
                                    appointment['Appointment_ID']),
                            icon: const Icon(Icons.schedule,
                                size: 16, color: Colors.white),
                            label: const Text('Reschedule'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: isPastAppointment || isConfirmed
                                ? null
                                : () => _showCancelConfirmationDialog(
                                    context, appointment['Appointment_ID']),
                            icon: const Icon(Icons.cancel,
                                size: 16, color: Colors.white),
                            label: const Text('Cancel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: isPastAppointment ||
                                    isConfirmed ||
                                    !_isAppointmentToday(
                                        appointment['Appointment_Date'])
                                ? null
                                : () => _confirmBooking(context, appointment),
                            icon: const Icon(Icons.check,
                                size: 16, color: Colors.white),
                            label: isConfirmed
                                ? const Text('Attendance Confirmed')
                                : const Text('Confirm Attendance'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            // Check both Firestore data and local state
                            onPressed: isPastAppointment ||
                                    isConfirmed ||
                                    confirmedAppointments[
                                            appointment['Appointment_ID']] ==
                                        true
                                ? null
                                : () => _setReminder(context, appointment),
                            icon: const Icon(Icons.notifications,
                                size: 16, color: Colors.white),
                            label: const Text('Set Reminder'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
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
