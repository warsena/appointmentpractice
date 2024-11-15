import 'package:flutter/material.dart';
import 'package:appointmentpractice/Password/changepassword.dart';
import 'package:appointmentpractice/login_page.dart';
// import 'editprofile.dart';  // Make sure you import the EditProfilePage

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
            // // User Profile Section
            // Container(
            //   padding: const EdgeInsets.all(16.0),
            //   decoration: BoxDecoration(
            //     color: Colors.teal[50],
            //     borderRadius: BorderRadius.circular(8.0),
            //   ),
            //   child: GestureDetector(
            //     onTap: () {
            //       // Navigate to the Edit Profile page when tapped
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => const EditProfilePage()),
            //       );
            //     },
            //     child: const Row(
            //       children: [
            //         // Profile Image Placeholder
            //         CircleAvatar(
            //           radius: 30,
            //           backgroundColor: Colors.teal,
            //           child: Icon(
            //             Icons.person,
            //             size: 40,
            //             color: Colors.white,
            //           ),
            //         ),
            //         SizedBox(width: 16.0),
            //         // User Name and Profile Label
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               'Amira Sofea Binti Othman',
            //               style: TextStyle(
            //                 fontSize: 18,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.black,
            //               ),
            //             ),
            //             Text(
            //               'Profile',
            //               style: TextStyle(
            //                 fontSize: 14,
            //                 color: Colors.grey,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
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
                    leading: const Icon(Icons.lock_outline, color: Colors.black),
                    title: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      // Handle edit profile
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Changepassword()),
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
