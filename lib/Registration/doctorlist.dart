import 'package:flutter/material.dart';

class DoctorList extends StatefulWidget {
  const DoctorList({Key? key}) : super(key: key);

  @override
  State<DoctorList> createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  String? selectedCampus = 'Pekan';

  final List<Map<String, String>> doctors = [
    {
      'name': 'Dr. Khairul Bin Karim',
      'email': 'khairul@gmail.com',
      'contact': '010-8995230',
      'service': 'Dental',
      'campus': 'Pekan',
      'password': 'khail123'
    },
    {
      'name': 'Dr. Erwina Binti Salleh',
      'email': 'erwina@gmail.com',
      'contact': '017-5642565',
      'service': 'Diabetes',
      'campus': 'Pekan',
      'password': 'erwina123'
    },
  ];

  List<Map<String, String>> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors; // Initially show all doctors
  }

  void filterDoctors() {
    setState(() {
      filteredDoctors = doctors.where((doctor) {
        return selectedCampus == null || doctor['campus'] == selectedCampus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor List'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
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
                ElevatedButton(
                  onPressed: filterDoctors,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(color: Colors.white), // White text color
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
                      DataColumn(label: Text('Email Address', style: TextStyle(fontSize: 14))),
                      DataColumn(label: Text('Contact', style: TextStyle(fontSize: 14))),
                      DataColumn(label: Text('Type of Services', style: TextStyle(fontSize: 14))),
                      DataColumn(label: Text('Campus', style: TextStyle(fontSize: 14))),
                      DataColumn(label: Text('Password', style: TextStyle(fontSize: 14))),
                      DataColumn(
                        label: Center(
                          child: Text('Action', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ],
                    rows: List.generate(
                      filteredDoctors.length,
                      (index) {
                        final doctor = filteredDoctors[index];
                        return DataRow(cells: [
                          DataCell(Text(doctor['name']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(doctor['email']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(doctor['contact']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(doctor['service']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(doctor['campus']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(doctor['password']!, style: const TextStyle(fontSize: 12))),
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
                                    setState(() {
                                      filteredDoctors.removeAt(index);
                                    });
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
