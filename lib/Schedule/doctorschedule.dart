import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSchedule extends StatefulWidget {
  const DoctorSchedule({super.key});

  @override
  State<DoctorSchedule> createState() => _DoctorScheduleState();
}

class _DoctorScheduleState extends State<DoctorSchedule> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedCampus = 'Gambang'; // Default campus
  String selectedService = 'Dental Service'; // Default service
  String doctorName = ''; // Doctor's name
  Map<int, bool> markedDates = {}; // Dates with appointments
  DateTime selectedMonth = DateTime.now(); // Default to current month

  final List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  // Generate years for the dropdown (adjust the range as needed)
  final List<int> years = List.generate(20, (index) => DateTime.now().year - 10 + index);

  // Doctor assignment
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

  @override
  void initState() {
    super.initState();
    updateDoctorName();
    fetchAppointments(); // Load appointments from Firebase
  }

  void updateDoctorName() {
    setState(() {
      doctorName = doctorSchedule[selectedCampus]?[selectedService] ?? 'Unknown';
    });
  }

  Future<void> fetchAppointments() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Appointment')
          .where('Appointment_Campus', isEqualTo: selectedCampus)
          .where('Appointment_Service', isEqualTo: selectedService)
          .get();

      Map<int, bool> tempMarkedDates = {};

      for (var doc in snapshot.docs) {
        String dateStr = doc['Appointment_Date']; // e.g., "2024-05-25"
        DateTime date = DateTime.parse(dateStr);
        if (date.year == selectedMonth.year && date.month == selectedMonth.month) {
          tempMarkedDates[date.day] = true;
        }
      }

      setState(() {
        markedDates = tempMarkedDates;
      });
    } catch (e) {
      print('Error fetching appointments: $e');
    }
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
                const Text('Campus:', style: TextStyle(fontSize: 16)),
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
                      fetchAppointments(); // Update appointments
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Dropdown for service selection
            Row(
              children: [
                const Text('Service:', style: TextStyle(fontSize: 16)),
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
                      fetchAppointments(); // Update appointments
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
            // Month and Year Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  value: selectedMonth.year,
                  items: years
                      .map((year) => DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = DateTime(
                        value!,
                        selectedMonth.month,
                      );
                      fetchAppointments(); // Update appointments
                    });
                  },
                ),
                DropdownButton<String>(
                  value: months[selectedMonth.month - 1],
                  items: months
                      .map((month) => DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      int monthIndex = months.indexOf(value!) + 1;
                      selectedMonth = DateTime(
                        selectedMonth.year,
                        monthIndex,
                      );
                      fetchAppointments(); // Update appointments
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Schedule Calendar
            Expanded(
              child: Table(
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
                  // Generate rows for the calendar
                  ..._generateCalendarRows(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _generateCalendarRows() {
    List<TableRow> rows = [];
    DateTime firstDayOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month, 1);
    int daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    int startWeekday = firstDayOfMonth.weekday;

    int day = 1 - (startWeekday - 1);

    for (int i = 0; i < 6; i++) {
      List<Widget> week = [];
      for (int j = 0; j < 7; j++) {
        if (day < 1 || day > daysInMonth) {
          week.add(Container()); // Empty cell
        } else {
          bool hasAppointment = markedDates[day] ?? false;
          week.add(
            GestureDetector(
              onTap: () {
                if (hasAppointment) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'You have an appointment on ${months[selectedMonth.month - 1]} $day'),
                    ),
                  );
                }
              },
              child: Container(
                height: 60,
                alignment: Alignment.center,
                color: hasAppointment
                    ? Colors.blue.withOpacity(0.6)
                    : Colors.white,
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: hasAppointment ? Colors.white : Colors.black,
                    fontWeight: hasAppointment ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }
        day++;
      }
      rows.add(TableRow(children: week));
    }
    return rows;
  }
}
