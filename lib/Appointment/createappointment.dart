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
            (selectedCampus == 'Pekan');
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal.shade600,
        title: const Text(
          'Create Appointment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.teal.shade600,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCampus,
                      decoration: InputDecoration(
                        labelText: 'Campus',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedCampus = value;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 'Pekan', child: Text('Pekan')),
                        DropdownMenuItem(value: 'Gambang', child: Text('Gambang')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedService,
                      decoration: InputDecoration(
                        labelText: 'Services',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedService = value;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 'Services', child: Text('Services')),
                        DropdownMenuItem(value: 'Dental', child: Text('Dental')),
                        DropdownMenuItem(value: 'Physiotherapy', child: Text('Physiotherapy')),
                        DropdownMenuItem(value: 'Diabetes', child: Text('Diabetes')),
                        DropdownMenuItem(value: 'Obesity', child: Text('Obesity')),
                        DropdownMenuItem(
                            value: 'Stress Consultation', child: Text('Stress Consultation')),
                        DropdownMenuItem(value: 'Checkup', child: Text('Checkup')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: filterAppointments,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredAppointments.length,
              itemBuilder: (context, index) {
                final appointment = filteredAppointments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appointment['service'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'No. ${appointment['no']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Appointments Per Day:',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.teal.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (appointment['appointmentsPerDay'] > 0) {
                                          appointment['appointmentsPerDay']--;
                                        }
                                      });
                                    },
                                    color: Colors.teal,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      appointment['appointmentsPerDay'].toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        appointment['appointmentsPerDay']++;
                                      });
                                    },
                                    color: Colors.teal,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AppointmentList()),
                              );
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        
      ),
    );
  }
}
