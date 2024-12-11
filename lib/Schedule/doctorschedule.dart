import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DoctorSchedule extends StatefulWidget {
  const DoctorSchedule({Key? key}) : super(key: key);

  @override
  _DoctorScheduleState createState() => _DoctorScheduleState();
}

class _DoctorScheduleState extends State<DoctorSchedule> {
  String doctorName = "";
  String doctorService = "";
  String doctorCampus = "";
  Map<DateTime, List<Map<String, dynamic>>> appointments = {};
  bool isLoading = true;

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  // Color palette
  final Color primaryColor = const Color(0xFF2196F3);
  final Color accentColor = const Color(0xFF03A9F4);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color textColor = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    fetchDoctorDetailsAndAppointments();
  }

  Future<void> fetchDoctorDetailsAndAppointments() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Fetch doctor details
        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await firestore.collection('User').doc(user.uid).get();

        if (userDoc.exists && userDoc.data()?['User_Type'] == 'Doctor') {
          final userData = userDoc.data();
          setState(() {
            doctorName = userData?['User_Name'] ?? "Unknown";
            doctorService = userData?['Selected_Service'] ?? "Unknown";
            doctorCampus = userData?['Campus'] ?? "Unknown";
          });

          // Fetch appointments for this doctor
          QuerySnapshot<Map<String, dynamic>> appointmentDocs = await firestore
              .collection('Appointment')
              .where('Appointment_Service', isEqualTo: doctorService)
              .where('Appointment_Campus', isEqualTo: doctorCampus)
              .get();

          Map<DateTime, List<Map<String, dynamic>>> tempAppointments = {};
          for (var doc in appointmentDocs.docs) {
            final data = doc.data();
            print('Appointment Data: $data'); // Debugging log

            DateTime? appointmentDate;
            if (data['Appointment_Date'] is String) {
              appointmentDate = DateTime.parse(data['Appointment_Date']);
            }

            if (appointmentDate != null) {
              final dayKey = DateTime(appointmentDate.year,
                  appointmentDate.month, appointmentDate.day);

              String userName = "Unknown";
              if (data['User_ID'] != null) {
                DocumentSnapshot<Map<String, dynamic>> userDoc = await firestore
                    .collection('User')
                    .doc(data['User_ID'])
                    .get();
                if (userDoc.exists) {
                  userName = userDoc.data()?['User_Name'] ?? "Unknown";
                }
              }

              if (tempAppointments[dayKey] == null) {
                tempAppointments[dayKey] = [];
              }

              tempAppointments[dayKey]?.add({
                'User_Name': userName,
                'Appointment_Name': data['Appointment_Service'] ?? "Unknown",
                'Appointment_Date': data['Appointment_Date'] ?? "Unknown",
                'Appointment_Time': data['Appointment_Time'] ?? "Unknown",
                'Campus': data['Appointment_Campus'] ?? "Unknown",
              });
            }
          }

          setState(() {
            appointments = tempAppointments;
          });
        }
      } catch (e) {
        print('Error fetching data: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getAppointmentsForDay(DateTime date) {
    // Ensure day precision (strip time)
    final dayKey = DateTime(date.year, date.month, date.day);
    return appointments[dayKey] ?? [];
  }

  // Improved Year Picker
  Future<void> _selectYear() async {
    final DateTime? selectedYear = await showDatePicker(
      context: context,
      initialDate: focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.input,
      currentDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: primaryColor,        // Header background color
              onPrimary: Colors.white,       // Header text color
              surface: Colors.white,         // Background color of dialog
              onSurface: textColor,          // Text color of dialog
            ),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (selectedYear != null) {
      setState(() {
        focusedDay = DateTime(selectedYear.year, focusedDay.month, focusedDay.day);
      });
    }
  }

  // Show Day Appointments Method
  void _showDayAppointments(DateTime day) {
    final dayAppointments = _getAppointmentsForDay(day);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Appointments on ${DateFormat('dd MMM yyyy').format(day)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  dayAppointments.isEmpty
                      ? const Text(
                          'No appointments on this day',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: dayAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment = dayAppointments[index];
                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    'User: ${appointment['User_Name']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Time: ${appointment['Appointment_Time']}',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                      Text(
                                        'Service: ${appointment['Appointment_Name']}',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                      Text(
                                        'Campus: ${appointment['Campus']}',
                                        style: TextStyle(color: Colors.grey[700]),
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Doctor\'s Schedule', 
          style: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Doctor Info Card
                  if (doctorName.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            doctorName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Service: $doctorService',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Campus: $doctorCampus',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Year Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton.icon(
                      onPressed: _selectYear,
                      icon: const Icon(Icons.calendar_month_outlined, color: Colors.white),
                      label: const Text(
                        'Select Year', 
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  // Calendar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2100, 12, 31),
                          focusedDay: focusedDay,
                          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                          eventLoader: _getAppointmentsForDay,
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              this.selectedDay = selectedDay;
                              this.focusedDay = focusedDay;
                            });
                            // Show appointments for the selected day
                            _showDayAppointments(selectedDay);
                          },
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: accentColor.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
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