import 'package:flutter/material.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  String? selectedCampus = 'Pekan';
  String? selectedUserType = 'Student';

  final List<Map<String, String>> users = [
    {
      'name': 'Adriana Binti Afandi',
      'email': 'adriana@gmail.com',
      'gender': 'Female',
      'contact': '010-9741562',
      'userType': 'Student',
      'campus': 'Pekan',
      'password': 'adriana123'
    },
    {
      'name': 'En. Hafiz Bin Ibrahim',
      'email': 'hafiz@gmail.com',
      'gender': 'Male',
      'contact': '014-2345678',
      'userType': 'Lecturer',
      'campus': 'Pekan',
      'password': 'hafiz123'
    },
  ];

  List<Map<String, String>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = users; // Initially show all users
  }

  void filterUsers() {
    setState(() {
      filteredUsers = users.where((user) {
        return (selectedCampus == null || user['campus'] == selectedCampus) &&
               (selectedUserType == null || user['userType'] == selectedUserType);
      }).toList();
    });
  }

  void deleteUser(int index) {
    setState(() {
      filteredUsers.removeAt(index);
    });
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
                  width: 120, // Set a small width for Campus dropdown
                  child: DropdownButtonFormField<String>(
                    value: selectedCampus,
                    onChanged: (value) {
                      setState(() {
                        selectedCampus = value;
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
                  width: 120, // Set a small width for User Type dropdown
                  child: DropdownButtonFormField<String>(
                    value: selectedUserType,
                    onChanged: (value) {
                      setState(() {
                        selectedUserType = value;
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
                  child: const Text(
                  'Search',
                  style: TextStyle(color: Colors.white),
                ),

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
                          DataCell(Text(user['name']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['email']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['gender']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['contact']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['userType']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['campus']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user['password']!, style: const TextStyle(fontSize: 12))),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  color: Colors.blue,
                                  onPressed: () {
                                    // Handle edit action here
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
