import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  String? selectedCampus;
  String? selectedUserType;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }


  Future<void> fetchUsers() async {
    try {

      final snapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('User_Type', whereIn: ['Student', 'Lecturer'])
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


  void filterUsers() {
    setState(() {
      filteredUsers = users.where((user) {
        return (selectedCampus == null || user['campus'] == selectedCampus) &&
               (selectedUserType == null || user['userType'] == selectedUserType);
      }).toList();
    });
  }


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
          content: Text('User deleted successfully'),
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

  String maskPassword(String password) {
    return '•' * password.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
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
                    ),
                    const SizedBox(width: 8),
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
                                filterUsers();
                              });
                            },
                            items: const [
                              DropdownMenuItem(value: 'Student', child: Text('Student')),
                              DropdownMenuItem(value: 'Lecturer', child: Text('Lecturer')),
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredUsers.length,
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
                            _buildInfoRow('Password', maskPassword(user['password'] ?? '')),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  onPressed: () => deleteUser(index),
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
}

