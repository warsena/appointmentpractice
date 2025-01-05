import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserEditProfile extends StatefulWidget {
  // Create a stateful widget for the user edit profile page
  const UserEditProfile({super.key}); // Constructor with key parameter

  // Create the mutable state for this widget
  @override
  State<UserEditProfile> createState() => _UserEditProfileState();
}

class _UserEditProfileState extends State<UserEditProfile> {
  // Define the state for the UserEditProfile widget

  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Initialize Firebase Authentication instance

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Initialize Firebase Firestore instance

  // Create text controllers for each editable field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();
  final TextEditingController _campusController = TextEditingController();

  // Initialize state and load user data when widget is created
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      // Get current logged in user
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Fetch user document from Firestore
        DocumentSnapshot userSnapshot =
            await _firestore.collection('User').doc(currentUser.uid).get();

        // If user document exists, populate the text controllers
        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          setState(() {
            // Set text controller values from user data
            _nameController.text = userData['User_Name'] ?? '';
            _emailController.text = userData['User_Email'] ?? '';
            _contactController.text = userData['User_Contact'] ?? '';
            _genderController.text = userData['User_Gender'] ?? '';
            _userTypeController.text = userData['User_Type'] ?? '';
            _campusController.text = userData['Campus'] ?? '';
          });
        }
      }
    } catch (e) {
      // Show error message if data loading fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  // Function to save changes to Firestore
  Future<void> _saveChanges() async {
    try {
      // Get current user
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Update user document in Firestore
        await _firestore.collection('User').doc(currentUser.uid).update({
          'User_Name': _nameController.text.trim(),
          'User_Email': _emailController.text.trim(),
          'User_Contact': _contactController.text.trim(),
        });
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
        // Return to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message if update fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  // Widget builder for text fields
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isEditable = true,
    IconData? icon,
  }) {
    // Return a container with margin for spacing
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      // Choose between editable and read-only text field
      child: isEditable
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                // Prefix icon with custom container styling
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.teal,
                    size: 20,
                  ),
                ),
                // Border styling for normal state
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                // Border styling for enabled state
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                // Border styling for focused state
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.teal,
                  ),
                ),
                fillColor: Colors.white,
                filled: true,
                // Padding for text field content
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            )
          // Read-only text field styling
          : TextFormField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                labelText: label,
                // Similar styling as editable field but with grey background
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.teal,
                    size: 20,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                fillColor: Colors.grey[100],
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
    );
  }

  // Build the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set background color
      backgroundColor: Colors.grey[50],
      // App bar configuration
      appBar: AppBar(
        title: const Text(
          'User Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      // Main body content
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Editable fields
              _buildTextField(
                label: 'Name',
                controller: _nameController,
                isEditable: true,
                icon: Icons.person,
              ),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                isEditable: true,
                icon: Icons.email,
              ),
              _buildTextField(
                label: 'Contact',
                controller: _contactController,
                isEditable: true,
                icon: Icons.phone,
              ),
              // Read-only fields
              _buildTextField(
                label: 'Gender',
                controller: _genderController,
                isEditable: false,
                icon: Icons.people,
              ),
              _buildTextField(
                label: 'User Type',
                controller: _userTypeController,
                isEditable: false,
                icon: Icons.school,
              ),
              _buildTextField(
                label: 'Campus',
                controller: _campusController,
                isEditable: false,
                icon: Icons.location_city,
              ),
              const SizedBox(height: 24),
              // Save changes button
              Center(
                // Center widget to position the button
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Save Changes'),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
