import 'package:flutter/material.dart'; // Import Flutter Material package for UI components.
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package for database operations.
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package for user authentication.

class DoctorEditProfile extends StatefulWidget {
  // Define a stateful widget for the edit profile screen.
  const DoctorEditProfile(
      {super.key}); // Constructor for the widget with a key for widget uniqueness.

  @override
  State<DoctorEditProfile> createState() =>
      _DoctorEditProfileState(); // Create the state for the widget.
}

class _DoctorEditProfileState extends State<DoctorEditProfile> {
  // Define the state class for the widget.
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Initialize FirebaseAuth for authentication.
  final FirebaseFirestore _firestore = FirebaseFirestore
      .instance; // Initialize Firestore for database operations.

  // Define controllers for managing text field inputs.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();
  final TextEditingController _campusController = TextEditingController();
  final TextEditingController _selectedServiceController =
      TextEditingController();

  @override
  void initState() {
    super.initState(); // Call the parent class' initState.
    _loadUserData(); // Load user data when the widget initializes.
  }

  // Method to fetch and load user data from Firestore.
  Future<void> _loadUserData() async {
    try {
      User? currentUser =
          _auth.currentUser; // Get the currently authenticated user.
      if (currentUser != null) {
        DocumentSnapshot userSnapshot = await _firestore
            .collection('User')
            .doc(currentUser.uid)
            .get(); // Fetch user data from Firestore.

        if (userSnapshot.exists) {
          // Check if the user document exists.
          Map<String, dynamic> userData = userSnapshot.data()
              as Map<String, dynamic>; // Cast user data to a map.

          setState(() {
            // Update the controllers with user data.
            _nameController.text = userData['User_Name'] ?? '';
            _emailController.text = userData['User_Email'] ?? '';
            _contactController.text = userData['User_Contact'] ?? '';
            _genderController.text = userData['User_Gender'] ?? '';
            _userTypeController.text = userData['User_Type'] ?? '';
            _selectedServiceController.text =
                userData['Selected_Service'] ?? ''; // Load selected service.
            _campusController.text = userData['Campus'] ?? '';
          });
        }
      }
    } catch (e) {
      // Catch and display errors if user data cannot be loaded.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  // Method to save changes to the user's profile in Firestore.
  Future<void> _saveChanges() async {
    try {
      User? currentUser =
          _auth.currentUser; // Get the currently authenticated user.
      if (currentUser != null) {
        await _firestore.collection('User').doc(currentUser.uid).update({
          'User_Name': _nameController.text.trim(),
          'User_Email': _emailController.text.trim(),
          'User_Contact': _contactController.text.trim(),
          'Selected_Service':
              _selectedServiceController.text.trim(), // Save selected service.
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Profile updated successfully.')), // Notify user of success.
        );
        Navigator.pop(context); // Return to the previous screen.
      }
    } catch (e) {
      // Catch and display errors if profile update fails.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error updating profile: $e')), // Corrected the extra parenthesis.
      );
    }
  }

  // Widget method to build a text field with customizable properties.
  Widget _buildTextField({
    required String label, // The label of the text field.
    required TextEditingController controller, // The text field's controller.
    bool isEditable = true, // Whether the field is editable or read-only.
    IconData? icon, // Icon to display in the prefix.
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 6), // Margin around the text field.
      child: isEditable
          ? TextFormField(
              // Editable text field.
              controller: controller,
              decoration: InputDecoration(
                // Define decoration for the text field.
                labelText: label,
                prefixIcon: Container(
                  // Define icon styling.
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    // Add the provided icon.
                    icon,
                    color: Colors.blue, // Set icon color to blue
                    size: 20,
                  ),
                ),
                border: OutlineInputBorder(
                  // Border styling.
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  // Border styling for enabled state.
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  // Border styling for focused state.
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.blue, // Focused border in blue
                  ),
                ),
                fillColor: Colors.white, // Background color for the field.
                filled: true,
                contentPadding: // Padding inside the text field.
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            )
          : TextFormField(
              // Read-only text field.
              controller: controller,
              readOnly: true, // Make the field non-editable.
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Container(
                  // Icon styling for read-only.
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    // Add the provided icon.
                    icon,
                    color: Colors.blue, // Set icon color to blue
                    size: 20,
                  ),
                ),
                border: OutlineInputBorder(
                  // Border styling for read-only field.
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  // Enabled border styling.
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                fillColor:
                    Colors.grey[100], // Light background for read-only fields.
                filled: true,
                contentPadding: // Padding inside the text field.
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build method for the widget.
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background color.
      appBar: AppBar(
        // App bar for the screen.
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold), // Bold title text.
        ),
        backgroundColor: Colors.blue, // App bar background color.
        elevation: 0, // Remove shadow.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding for the screen content.
        child: SingleChildScrollView(
          // Enable scrolling for content.
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align children to the start.
            children: [
              _buildTextField(
                // Text field for name.
                label: 'Name',
                controller: _nameController,
                isEditable: true,
                icon: Icons.person,
              ),

              _buildTextField(
                // Text field for email.
                label: 'Email',
                controller: _emailController,
                isEditable: true,
                icon: Icons.email,
              ),

              _buildTextField(
                // Text field for contact.
                label: 'Contact',
                controller: _contactController,
                isEditable: true,
                icon: Icons.phone,
              ),

              _buildTextField(
                // Read-only field for gender.
                label: 'Gender',
                controller: _genderController,
                isEditable: false,
                icon: Icons.people,
              ),

              _buildTextField(
                // Read-only field for user type.
                label: 'User Type',
                controller: _userTypeController,
                isEditable: false,
                icon: Icons.school,
              ),

              _buildTextField(
                // Read-only field for selected service.
                label: 'Selected Service',
                controller: _selectedServiceController,
                isEditable: false,
                icon: Icons.work,
              ),
              
              _buildTextField(
                // Read-only field for campus.
                label: 'Campus',
                controller: _campusController,
                isEditable: false,
                icon: Icons.location_city,
              ),
              const SizedBox(height: 24), // Add spacing before the save button.
              SizedBox( // Full-width button for saving changes.
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveChanges, // Call the save changes method.
                  icon: const Icon(Icons.save), // Save icon.
                  label: const Text('Save Changes'), // Button label.
                  style: ElevatedButton.styleFrom( // Button styling.
                    backgroundColor: const Color.fromRGBO(37, 163, 255, 1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
