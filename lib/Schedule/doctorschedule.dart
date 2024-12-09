import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor\'s Schedule',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: DoctorSchedule(),
    );
  }
}

class DoctorSchedule extends StatefulWidget {
  @override
  _DoctorScheduleState createState() => _DoctorScheduleState();
}

class _DoctorScheduleState extends State<DoctorSchedule> {
  String selectedCampus = "Pekan"; // Default campus filter
  String formattedDate = "2024-11-22"; // Example date filter
  String selectedTimeslot = "8:00 AM"; // Example timeslot filter
  String selectedService = "Mental Health Service"; // Example service filter
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments(); // Fetch appointments when the screen loads
  }

  Future<void> fetchAppointments() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Query Firestore with multiple filters
      QuerySnapshot<Map<String, dynamic>> existingBookings = await firestore
          .collection('Appointment')
          .where('Appointment_Date', isEqualTo: formattedDate)
          .where('Appointment_Time', isEqualTo: selectedTimeslot)
          .where('Appointment_Service', isEqualTo: selectedService)
          .where('Appointment_Campus', isEqualTo: selectedCampus)
          .get();

      // Set the appointments to the state
      setState(() {
        appointments = existingBookings.docs.map((doc) {
          return {
            'Appointment_Date': doc['Appointment_Date'],
            'Appointment_Time': doc['Appointment_Time'],
            'Appointment_Service': doc['Appointment_Service'],
            'Appointment_Campus': doc['Appointment_Campus'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor's Schedule"),
      ),
      body: Column(
        children: [
          // Filter Dropdown for campus selection
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedCampus,
              decoration: InputDecoration(
                labelText: 'Filter by Campus',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: ['Pekan', 'Gambang'].map((campus) {
                return DropdownMenuItem(
                  value: campus,
                  child: Text(campus),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCampus = value!;
                  fetchAppointments(); // Refresh appointments when filter changes
                });
              },
            ),
          ),

          // Appointments List
          Expanded(
            child: appointments.isEmpty
                ? Center(child: Text("No appointments found."))
                : ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            appointment['Appointment_Date'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Time: ${appointment['Appointment_Time']}"),
                              Text("Service: ${appointment['Appointment_Service']}"),
                              Text("Campus: ${appointment['Appointment_Campus']}"),
                            ],
                          ),
                          leading: Icon(Icons.calendar_today, color: Colors.teal),
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
