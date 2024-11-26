import 'package:flutter/material.dart';

class DoctorSchedule extends StatefulWidget {
  const DoctorSchedule({super.key});

  @override
  State<DoctorSchedule> createState() => _DoctorScheduleState();
}

class _DoctorScheduleState extends State<DoctorSchedule> {
  // Dummy data simulating data from the User table
  final Map<String, Map<String, String>> doctorSchedule = {
    'Gambang': {
      'Medical Health Service': 'Dr. Syed Anas Bin Syed Ismail',
      'Dental Service': 'Dr. Ainun Mardhiah Binti Fauzi',
      'Mental Health Service': 'Dr. Najihah Binti Mohd Azman',
    },
    'Pekan': {
      'Medical Health Service': 'Dr. Erwina Nursyaheera Binti Sulaiman',
      'Dental Service': 'Dr. Mohammad Syarbini Bin Saudi',
      'Mental Health Service': 'Dr. Norhilda Binti Abdul Karim',
    },
  };

  String selectedCampus = 'Gambang'; // Default campus
  String selectedService = 'Dental Service'; // Default service
  String doctorName = '';

  @override
  void initState() {
    super.initState();
    updateDoctorName();
  }

  void updateDoctorName() {
    setState(() {
      doctorName = doctorSchedule[selectedCampus]?[selectedService] ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown for campus selection
            Row(
              children: [
                const Text('Campus: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedCampus,
                  items: doctorSchedule.keys
                      .map((campus) => DropdownMenuItem(
                            value: campus,
                            child: Text(campus),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCampus = value!;
                      updateDoctorName();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Dropdown for service selection
            Row(
              children: [
                const Text('Service: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedService,
                  items: doctorSchedule[selectedCampus]!.keys
                      .map((service) => DropdownMenuItem(
                            value: service,
                            child: Text(service),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedService = value!;
                      updateDoctorName();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display the doctor name
            Text('Doctor in Charge: $doctorName',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Schedule Calendar (Static example, customize as needed)
            Expanded(
              child: Column(
                children: [
                  const Text('May, 2024',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    children: [
                      // Days of the week
                      TableRow(
                        children: List.generate(
                          7,
                          (index) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Example schedule rows
                      ...List.generate(
                        5,
                        (weekIndex) => TableRow(
                          children: List.generate(
                            7,
                            (dayIndex) => Container(
                              height: 60,
                              alignment: Alignment.center,
                              color: weekIndex == 1 && dayIndex == 2
                                  ? Colors.blue
                                  : Colors.white,
                              child: Text(
                                (weekIndex * 7 + dayIndex + 1).toString(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: DoctorSchedule()));
}
