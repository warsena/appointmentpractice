import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointmentpractice/login_page.dart';
import 'package:appointmentpractice/Password/changepassword.dart';
import 'package:appointmentpractice/Profile/userprofile.dart';
import 'package:appointmentpractice/Profile/doctorprofile.dart'; // Import DoctorProfile

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String? userType; // Variable to store the user type

  @override
  void initState() {
    super.initState();
    _fetchUserType(); // Fetch the user type when the widget initializes
  }

  Future<void> _fetchUserType() async {
    try {
      // Get the current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Fetch the user's data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .get();

        setState(() {
          userType = userDoc['User_Type']; // Get the User_Type field
        });
      }
    } catch (e) {
      print('Error fetching user type: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the background color for Profile and Change Password items
    Color itemBackgroundColor =
        userType == 'Doctor' ? Colors.blue.shade100 : Colors.teal.shade100;

    return Scaffold(
      appBar: AppBar(
        title: userType == 'Doctor' // Only display title for Doctor
            ? const Text(
                'Dual Campus',
                style: TextStyle(
                  color: Colors.black, // Set the text color to black
                  fontWeight: FontWeight.bold, // Set the text to bold
                ),
              )
            : null, // If user is Student or Lecturer, no title will be displayed
        backgroundColor: userType == 'Doctor'
            ? const Color.fromRGBO(
                37, 163, 255, 1) // Set background color for Doctor
            : Colors
                .transparent, // Transparent background for Student and Lecturer
        elevation: 0,
        iconTheme: userType == 'Doctor'
            ? const IconThemeData(
                color: Colors.black) // Set the icon color for Doctor
            : const IconThemeData(
                color: Colors
                    .transparent), // Set icon color to transparent for Student and Lecturer
        leading: userType == 'Doctor'
            ? null // Show the back arrow for Doctor (null removes the back arrow here)
            : null, // No back arrow for Student or Lecturer
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Options
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Profile Option
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    backgroundColor: itemBackgroundColor,
                    onTap: () {
                      if (userType == 'Doctor') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DoctorProfile()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserProfile()),
                        );
                      }
                    },
                  ),

                  // Change Password Option
                  _buildSettingItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    backgroundColor: itemBackgroundColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Changepassword()),
                      );
                    },
                  ),

                  // Log Out Option
                  _buildSettingItem(
                    icon: Icons.logout,
                    title: 'Log Out',
                    isDestructive: true,
                    backgroundColor: Colors.red.shade100,
                    onTap: () {
                      _showLogoutConfirmationDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom widget for setting items
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color backgroundColor = Colors.teal,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.teal[800],
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  // Logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            // Cancel Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            // Log Out Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
