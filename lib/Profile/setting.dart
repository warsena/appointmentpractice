import 'package:flutter/material.dart';
import 'package:appointmentpractice/login_page.dart';
import 'package:appointmentpractice/Password/changepassword.dart';
import 'package:appointmentpractice/Profile/userprofile.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(), // Empty container to remove the title
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            // Profile Options
            Container(
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  // Profile
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.black),
                    title: const Text(
                      'Profile',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      // Navigate to the UserProfile page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserProfile()),
                      );
                    },
                  ),

                  // Change Password Option
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: Colors.black),
                    title: const Text(
                      'Change My Password',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      // Handle Change Password tap, navigate to the change password page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Changepassword()),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  // Log Out Option
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.black),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      // Handle Log Out tap, navigate to the login page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
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
}
