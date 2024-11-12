import 'package:appointmentpractice/Registration/updateuser.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  String? selectedCampus = 'Pekan';
  String? selectedUserType = 'Student';

  List<Map<String, dynamic>> users = []; // This will store users fetched from Firestore
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users from Firestore on widget initialization
  }

  // Function to fetch users from Firestore based on userType
  Future<void> fetchUsers() async {
    try {
      // Fetching documents in 'User' collection where 'User_Type' is either 'Student' or 'Lecturer'
      final snapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('User_Type', whereIn: ['Student', 'Lecturer'])
          .get();

      // Map snapshot data to List of Maps, using null-aware operators to handle missing fields
      final fetchedUsers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'docId': doc.id, // Store the document ID for deletion
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
        filteredUsers = users; // Show all fetched users initially
      });
    } catch (e) {
      print('Error fetching users: $e');
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

  // Function to delete a user from Firestore and update the UI
  Future<void> deleteUser(int index) async {
    try {
      // Retrieve the document ID of the user to delete
      String? docId = filteredUsers[index]['docId'] as String?;

      // Check if docId is not null before proceeding
      if (docId == null) {
        throw Exception('Document ID is null. Unable to delete user.');
      }

      // Delete the user from Firestore
      await FirebaseFirestore.instance.collection('User').doc(docId).delete();

      // Remove the user from the filtered list and update the UI
      setState(() {
        filteredUsers.removeAt(index);
        // Also remove from the main users list to keep it in sync
        users.removeWhere((user) => user['docId'] == docId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      print('Error deleting user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    value: selectedCampus, // No initial value set; hint will be shown
                    hint: const Text('Select Campus'), // Displays "Select Campus" until an option is chosen
                    onChanged: (value) {
                      setState(() {
                        selectedCampus = value;
                        filterUsers(); // Update list immediately
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: 'Pekan', child: Text('Pekan')),
                      DropdownMenuItem(value: 'Gambang', child: Text('Gambang')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Campus',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    value: selectedUserType,
                    onChanged: (value) {
                      setState(() {
                        selectedUserType = value;
                        filterUsers(); // Update list immediately
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: 'Student', child: Text('Student')),
                      DropdownMenuItem(value: 'Lecturer', child: Text('Lecturer')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'User Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: filterUsers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 10,
                    headingRowHeight: 40,
                    dataRowHeight: 50,
                    columns: const [
                      DataColumn(label: Text('Name', style: TextStyle(fontSize: 14))),
                      DataColumn(label: Text('Email', style: TextStyle(fontSize: 14))),
                      DataColumn(label: Text('Gender', style: TextStyle(fontSize: 14))),
                      DataColumn(label: Text('Contact', style: TextStyle(fontSize: 14))),
                      DataColumn(label: Text('User Type', style: TextStyle(fontSize: 14))),
                      DataColumn(label: Text('Campus', style: TextStyle(fontSize: 14))),
                      DataColumn(label: Text('Password', style: TextStyle(fontSize: 14))),
                      DataColumn(
                        label: Center(
                          child: Text('Action', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ],
                    rows: List.generate(
                      filteredUsers.length,
                      (index) {
                        final user = filteredUsers[index];
                        return DataRow(cells: [
                          DataCell(Text(user['name'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['email'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['gender'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['contact'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['userType'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['campus'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['password'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                 icon: const Icon(Icons.edit, size: 18),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const UpdateUser(),
                                        ),
                                      );
                                    },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 18),
                                  color: Colors.red,
                                  onPressed: () {
                                    deleteUser(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
