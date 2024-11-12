import 'package:appointmentpractice/Password/changepassword.dart';
import 'package:appointmentpractice/Profile/usereditprofile.dart';
import 'package:appointmentpractice/login_page.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
           
            const SizedBox(height: 16.0),
            // Settings Options
            Container(
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  //Edit profile
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.black),
                    title: const Text(
                      'Change My Password',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      // Handle edit profile
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const UserEditProfile()),
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
                      Navigator.pushReplacement(
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
