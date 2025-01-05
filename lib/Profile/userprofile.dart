// Import necessary packages for Firebase functionality and UI components
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointmentpractice/Profile/usereditprofile.dart';

// StatefulWidget for User Profile page
class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Initialize Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store user data retrieved from Firebase
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    // Fetch user data when widget initializes
    _fetchUserData();
  }

  // Function to fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      // Get current logged-in user
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Fetch user document from Firestore
        DocumentSnapshot userSnapshot =
            await _firestore.collection('User').doc(currentUser.uid).get();

        if (userSnapshot.exists) {
          // Update state with fetched user data
          setState(() {
            _userData = userSnapshot.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      // Show error message if data fetch fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  // Widget to build individual information cards
  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      // Card decoration with shadow effect
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container with teal background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.teal, size: 20),
          ),
          const SizedBox(width: 12),
          // Information text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label text (field name)
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.teal,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // Value text (user data)
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // AppBar configuration
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      // Main body content
      body: _userData == null
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // User information cards
                  _buildInfoCard('Name', _userData!['User_Name'], Icons.person),
                  _buildInfoCard('Email', _userData!['User_Email'], Icons.email),
                  _buildInfoCard('Contact', _userData!['User_Contact'], Icons.phone),
                  _buildInfoCard('Gender', _userData!['User_Gender'], Icons.people),
                  _buildInfoCard('User Type', _userData!['User_Type'], Icons.school),
                  _buildInfoCard('Campus', _userData!['Campus'], Icons.location_city),
                  const SizedBox(height: 16),
                  // Edit Profile button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to edit profile page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserEditProfile(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Edit Profile'),
                    // Button styling
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}