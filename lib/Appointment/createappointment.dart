import 'package:flutter/material.dart';
import 'package:appointmentpractice/Appointment/appointmentlist.dart';

class CreateAppointment extends StatefulWidget {
  const CreateAppointment({Key? key}) : super(key: key);

  @override
  State<CreateAppointment> createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  String? selectedCampus = 'Pekan';
  String? selectedService = 'Services';

  final List<Map<String, dynamic>> appointments = [
    {'no': 1, 'service': 'Dental', 'appointmentsPerDay': 5},
    {'no': 2, 'service': 'Physiotherapy', 'appointmentsPerDay': 4},
    {'no': 3, 'service': 'Diabetes', 'appointmentsPerDay': 3},
  ];

  List<Map<String, dynamic>> filteredAppointments = [];

  @override
  void initState() {
    super.initState();
    filteredAppointments = appointments;
  }

  void filterAppointments() {
    setState(() {
      filteredAppointments = appointments.where((appointment) {
        return (selectedService == 'Services' ||
                appointment['service'] == selectedService) &&
            (selectedCampus == 'Pekan'); // Assuming all are in 'Pekan' for this example
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Appointment'),
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
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedService,
                    onChanged: (value) {
                      setState(() {
                        selectedService = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: 'Services', child: Text('Services')),
                      DropdownMenuItem(value: 'Dental', child: Text('Dental')),
                      DropdownMenuItem(value: 'Physiotherapy', child: Text('Physiotherapy')),
                      DropdownMenuItem(value: 'Diabetes', child: Text('Diabetes')),
                      DropdownMenuItem(value: 'Obesity', child: Text('Obesity')),
                      DropdownMenuItem(value: 'Stress Consultation', child: Text('Stress Consultation')),
                      DropdownMenuItem(value: 'Checkup', child: Text('Checkup')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Services',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: filterAppointments,
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
                child: DataTable(
                  columnSpacing: 10,
                  headingRowHeight: 40,
                  dataRowHeight: 60,
                  columns: const [
                    DataColumn(label: Text('No', style: TextStyle(fontSize: 12))),
                    DataColumn(label: Text('Services', style: TextStyle(fontSize: 12))),
                    DataColumn(label: Text('Total Appointment Per Day', style: TextStyle(fontSize: 12))),
                    DataColumn(label: Text('Action', style: TextStyle(fontSize: 12))),
                  ],
                  rows: filteredAppointments.map((appointment) {
                    return DataRow(cells: [
                      DataCell(Text(appointment['no'].toString(), style: const TextStyle(fontSize: 12))),
                      DataCell(Text(appointment['service'], style: const TextStyle(fontSize: 12))),
                      DataCell(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () {
                                setState(() {
                                  if (appointment['appointmentsPerDay'] > 0) {
                                    appointment['appointmentsPerDay']--;
                                  }
                                });
                              },
                            ),
                            Text(
                              appointment['appointmentsPerDay'].toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () {
                                setState(() {
                                  appointment['appointmentsPerDay']++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AppointmentList()),
                            );
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
