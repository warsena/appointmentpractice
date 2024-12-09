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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Settings',
          style:
              TextStyle(color: Colors.teal[800], fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.teal[800]),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserProfile()),
                      );
                    },
                  ),

                  // Change Password Option
                  _buildSettingItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
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
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade100.withOpacity(0.3),
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
          // Cancel Button as ElevatedButton
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey, // Grey background for Cancel button
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white, // White text color
              ),
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
              backgroundColor: Colors.red, // Red button background
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.white, // Black text color
              ),
            ),
          ),
        ],
      );
    },
  );
}

}
