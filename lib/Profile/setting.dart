import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointmentpractice/login_page.dart';
import 'package:appointmentpractice/Password/changepassword.dart';
import 'package:appointmentpractice/Profile/userprofile.dart';
import 'package:appointmentpractice/Profile/doctorprofile.dart';
import 'package:appointmentpractice/MedicalCertificate/usermedicalcertificate.dart'; // Import the new page

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String? userType; // Variable to store the user type
  String? userName; // Variable to store the user name

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch the user data when the widget initializes
  }

  Future<void> _fetchUserData() async {
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
          userName = userDoc['User_Name']; // Get the User_Name field
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the background color for Profile and Change Password items
    Color itemBackgroundColor =
        userType == 'Doctor' ? Colors.blue.shade100 : Colors.teal.shade100;

    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Dual Campus',
    style: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
  centerTitle: true, // Ensures the title stays in the center
  backgroundColor: userType == 'Doctor'
      ? const Color.fromRGBO(37, 163, 255, 1)
      : Colors.transparent,
  elevation: 0,
  iconTheme: userType == 'Doctor'
      ? const IconThemeData(color: Colors.black)
      : const IconThemeData(color: Colors.transparent),
  leading: userType == 'Doctor' ? null : null,
),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the personalized welcome message
            if (userName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Hey $userName, welcome to the Dual Campus Application!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Settings Options
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
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
                  // Medical Certificate Box (conditionally rendered)
                  if (userType == 'Student' || userType == 'Lecturer')
                    _buildSettingItem(
                      icon: Icons.medical_services,
                      title: 'Medical Certificate',
                      backgroundColor: itemBackgroundColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserMedicalCertificate(mcId: 
"C15vBwlxTMxf0wgILnSb"),
                          ),
                        );
                      },
                    ),
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
