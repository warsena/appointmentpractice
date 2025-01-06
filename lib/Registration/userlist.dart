import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  String? selectedCampus; // Variable to store selected campus
  String? selectedUserType; // Variable to store selected user type
  List<Map<String, dynamic>> users = []; // List to store all users
  List<Map<String, dynamic>> filteredUsers = []; // List to store filtered users

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users when the widget is initialized
  }

  // Fetch users from Firebase Firestore
  Future<void> fetchUsers() async {
    try {
      // Get users from the 'User' collection where the 'User_Type' is 'Student' or 'Lecturer'
      final snapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('User_Type', whereIn: ['Student', 'Lecturer']).get();

      // Map the fetched documents into a list of users
      final fetchedUsers = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'docId': doc.id, // Store the document ID
          'name': data['User_Name'] ?? '',
          'email': data['User_Email'] ?? '',
          'gender': data['User_Gender'] ?? '',
          'contact': data['User_Contact'] ?? '',
          'userType': data['User_Type'] ?? '',
          'campus': data['Campus'] ?? '',
          'password': data['User_Password'] ?? '',
        };
      }).toList();

      setState(() {
        users = fetchedUsers; // Set the users list with fetched data
        filteredUsers = users; // Initially, filtered users is the same as all users
      });
    } catch (e) {
      // Show error if fetching users fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch users: $e')),
      );
    }
  }

  // Function to filter users based on selected campus and user type
  void filterUsers() {
    setState(() {
      filteredUsers = users.where((user) {
        return (selectedCampus == null || user['campus'] == selectedCampus) &&
            (selectedUserType == null || user['userType'] == selectedUserType);
      }).toList();
    });
  }

  // Function to delete a user from Firestore
  Future<void> deleteUser(int index) async {
    try {
      String? docId = filteredUsers[index]['docId'] as String?;

      // If document ID is null, throw an error
      if (docId == null) {
        throw Exception('Document ID is null. Unable to delete user.');
      }

      // Delete the user from the Firestore collection
      await FirebaseFirestore.instance.collection('User').doc(docId).delete();

      // Remove the user from the local list
      setState(() {
        filteredUsers.removeAt(index); // Remove from filtered list
        users.removeWhere((user) => user['docId'] == docId); // Remove from all users list
      });

      // Show success message after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      // Show error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to mask the user's password (display only masked characters)
  String maskPassword(String password) {
    return '•' * password.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'User List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 100, 200, 185), 
        elevation: 2,
      ),
      body: Column(
        children: [
          // Filter options section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Campus selection dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCampus,
                            isExpanded: true,
                            hint: const Text('Select Campus'),
                            onChanged: (value) {
                              setState(() {
                                selectedCampus = value;
                                filterUsers(); // Filter users after selection
                              });
                            },
                            items: const [
                              DropdownMenuItem(
                                  value: 'Pekan', child: Text('Pekan')),
                              DropdownMenuItem(
                                  value: 'Gambang', child: Text('Gambang')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // User type selection dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedUserType,
                            isExpanded: true,
                            hint: const Text('Select User'),
                            onChanged: (value) {
                              setState(() {
                                selectedUserType = value;
                                filterUsers(); // Filter users after selection
                              });
                            },
                            items: const [
                              DropdownMenuItem(
                                  value: 'Student', child: Text('Student')),
                              DropdownMenuItem(
                                  value: 'Lecturer', child: Text('Lecturer')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Display filtered user list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredUsers.length, // Display filtered users count
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                  child: ExpansionTile(
                    title: Text(
                      user['name'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      user['userType'] ?? 'N/A',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        (user['name'] as String).isNotEmpty
                            ? (user['name'] as String)[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Email', user['email'] ?? 'N/A'),
                            _buildInfoRow('Gender', user['gender'] ?? 'N/A'),
                            _buildInfoRow('Contact', user['contact'] ?? 'N/A'),
                            _buildInfoRow('Campus', user['campus'] ?? 'N/A'),
                            _buildInfoRow('Password',
                                maskPassword(user['password'] ?? '')),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(width: 8),
                                // Delete button with confirmation
                                TextButton.icon(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  label: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () async {
                                    bool confirmDeletion =
                                        await _showDeleteConfirmationDialog(
                                            context);

                                    if (confirmDeletion) {
                                      deleteUser(index); // Delete the user
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build information rows for user details
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Show delete confirmation dialog
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          surfaceTintColor: Colors.white, // Prevent unintended color tinting
          title: const Row(
            children: [
              Icon(
                Icons.warning_rounded, 
                color: Colors.red, 
                size: 24,
              ),
              SizedBox(width: 8),
              Text('Delete User'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this user? This action cannot be undone.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ??
    false;
  }
}
