import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointmentpractice/login_page.dart';
import 'package:appointmentpractice/Password/changepassword.dart';
import 'package:appointmentpractice/Profile/userprofile.dart';
import 'package:appointmentpractice/Profile/doctorprofile.dart';
import 'package:appointmentpractice/MedicalCertificate/usermedicalcertificate.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String? userType;
  String? userName;
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      userId = currentUser?.uid;

      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .get();

        setState(() {
          userType = userDoc['User_Type'];
          userName = userDoc['User_Name'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // In your _SettingState class, modify the _navigateToMedicalCertificate function:

  void _navigateToMedicalCertificate() async {
    try {
      // First, get the current user's ID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Query Firestore for medical certificates where the user ID matches
      final QuerySnapshot mcSnapshot = await FirebaseFirestore.instance
          .collection('Medical_Certificate')
          .where('User_ID',
              isEqualTo: currentUser.uid) // Changed from 'userId' to 'User_ID'
          .get();

      if (!mounted) return;

      // Navigate to UserMedicalCertificate regardless of whether there are certificates or not
      // The UserMedicalCertificate widget will handle the empty state
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserMedicalCertificate(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      print('Error navigating to medical certificate: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color itemBackgroundColor =
        userType == 'Doctor' ? Colors.blue.shade100 : Colors.teal.shade100;

    return Scaffold(
      // Only show AppBar for Doctor, remove it for Student and Lecturer
      appBar: userType == 'Doctor'
          ? AppBar(
              title: const Text(
                'Dual Campus',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color.fromRGBO(37, 163, 255, 1),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            )
          : null, // No AppBar for Student and Lecturer
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userName != null)
              Padding(
                padding: const EdgeInsets.only(
                    top: 28.0), //spacing text hey dengan dual campus
                child: Text(
                  'Hey $userName, welcome to the Dual Campus Application!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
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
                  if (userType == 'Student' || userType == 'Lecturer')
                    _buildSettingItem(
                      icon: Icons.medical_services,
                      title: 'Medical Certificate',
                      backgroundColor: itemBackgroundColor,
                      onTap: _navigateToMedicalCertificate,
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
