import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorList extends StatefulWidget {
  const DoctorList({super.key});

  @override
  State<DoctorList> createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  String? selectedCampus;
  String? selectedService;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users when the widget is initialized
  }

  // Fetch users from Firebase Firestore
  Future<void> fetchUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('User_Type', whereIn: ['Doctor'])
          .get();

      final fetchedUsers = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'docId': doc.id,
          'name': data['User_Name'] ?? '',
          'email': data['User_Email'] ?? '',
          'gender': data['User_Gender'] ?? '',
          'contact': data['User_Contact'] ?? '',
          'userType': data['User_Type'] ?? '',
          'campus': data['Campus'] ?? '',
          'service': data['Selected_Service'] ?? '',
          'password': data['User_Password'] ?? '',
        };
      }).toList();

      setState(() {
        users = fetchedUsers;
        filteredUsers = users;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch users: $e')),
      );
    }
  }

  // Filter users based on campus and service selection
  void filterUsers() {
    setState(() {
      filteredUsers = users.where((user) {
        return (selectedCampus == null || user['campus'] == selectedCampus) &&
               (selectedService == null || user['service'] == selectedService);
      }).toList();
    });
  }

  // Delete a user (doctor) from Firebase Firestore
  Future<void> deleteUser(int index) async {
    try {
      String? docId = filteredUsers[index]['docId'] as String?;
      if (docId == null) {
        throw Exception('Document ID is null. Unable to delete user.');
      }

      await FirebaseFirestore.instance.collection('User').doc(docId).delete();

      setState(() {
        filteredUsers.removeAt(index);
        users.removeWhere((user) => user['docId'] == docId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor deleted successfully'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mask the password with bullets
  String maskPassword(String password) {
    return '•' * password.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Doctor List',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the title bold
            color: Colors.black, // Title text color black
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 100, 200, 185), // AppBar background color
        elevation: 2,
      ),
      body: Container(
        color: Colors.white, // Background color for the entire screen
        child: Column(
          children: [
            // Filter and selection options (Campus and Service)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, // White background for the filter section
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCampus,
                        isExpanded: true,
                        hint: const Text('Select Campus'),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onChanged: (value) {
                          setState(() {
                            selectedCampus = value;
                            filterUsers();
                          });
                        },
                        items: const [
                          DropdownMenuItem(value: 'Pekan', child: Text('Pekan')),
                          DropdownMenuItem(value: 'Gambang', child: Text('Gambang')),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedService,
                        isExpanded: true,
                        hint: const Text('Select Service'),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onChanged: (value) {
                          setState(() {
                            selectedService = value;
                            filterUsers();
                          });
                        },
                        items: const [
                          DropdownMenuItem(value: 'Dental Service', child: Text('Dental Service')),
                          DropdownMenuItem(value: 'Medical Health Service', child: Text('Medical Health Service')),
                          DropdownMenuItem(value: 'Mental Health Service', child: Text('Mental Health Service')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ExpansionTile(
                      title: Text(
                        user['name'] ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, // Doctor name bold text
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
                              _buildInfoRow('Service', user['service'] ?? 'N/A'),
                              _buildInfoRow('Campus', user['campus'] ?? 'N/A'),
                              _buildInfoRow('Password', maskPassword(user['password'] ?? '')),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    onPressed: () async {
                                      bool confirmDeletion = await _showDeleteConfirmationDialog(context);
                                      if (confirmDeletion) {
                                        deleteUser(index);
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
      ),
    );
  }

  // Helper method to display a row with label and value
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
              style: const TextStyle(fontSize: 14),
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
              Text('Delete Doctor'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this doctor? This action cannot be undone.',
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
