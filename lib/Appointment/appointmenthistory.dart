import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppointmentHistory extends StatefulWidget {
  const AppointmentHistory({super.key});

  @override
  State<AppointmentHistory> createState() => _AppointmentHistoryState();
}

class _AppointmentHistoryState extends State<AppointmentHistory> {
  String? selectedAttendance;
  String? selectedYear;

  Future<List<Map<String, dynamic>>> fetchAppointments() async {
  try {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Query query = FirebaseFirestore.instance
        .collection('Appointment')
        .where('User_ID', isEqualTo: currentUserId);

    // Only apply attendance filter if it's not "All" and not null
    if (selectedAttendance != null && selectedAttendance != 'All') {
      query = query.where('Appointment_Attendance', isEqualTo: selectedAttendance);
    }

    QuerySnapshot snapshot = await query.get();
    List<Map<String, dynamic>> appointments = snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // Filter by year if selected
    if (selectedYear != null && selectedYear!.isNotEmpty) {
      int year = int.parse(selectedYear!);
      appointments = appointments.where((appointment) {
        String? dateStr = appointment['Appointment_Date'];
        if (dateStr != null) {
          try {
            DateTime date = DateTime.parse(dateStr);
            return date.year == year;
          } catch (e) {
            debugPrint("Error parsing date: $e");
            return false;
          }
        }
        return false;
      }).toList();
    }

    return appointments;
  } catch (e) {
    debugPrint("Error fetching appointments: $e");
    return [];
  }
}

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value ?? 'Not specified',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Appointment History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedAttendance,
                            hint: const Text('Attendance'),
                            isExpanded: true,
                            items: ['All','Attend', 'Not Attend'].map((attendance) {
                              return DropdownMenuItem(
                                value: attendance,
                                child: Text(attendance),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedAttendance = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedYear,
                            hint: const Text('Year'),
                            isExpanded: true,
                            items: List.generate(
                              10,
                              (index) => (DateTime.now().year - index).toString(),
                            ).map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedYear = value;
                              });
                            },
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 100, 200, 185),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No appointments found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final appointments = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.medical_services,
                                    color: const Color.fromARGB(255, 100, 200, 185),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      appointment['Appointment_Service']?.toString() ?? 'No Service',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: appointment['Appointment_Attendance'] == 'Attend'
                                          ? Colors.green[50]
                                          : Colors.red[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      appointment['Appointment_Attendance']?.toString() ?? 'Unknown',
                                      style: TextStyle(
                                        color: appointment['Appointment_Attendance'] == 'Attend'
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.calendar_today,
                                "Date",
                                appointment['Appointment_Date']?.toString(),
                              ),
                              _buildInfoRow(
                                Icons.access_time,
                                "Time",
                                appointment['Appointment_Time']?.toString(),
                              ),
                              _buildInfoRow(
                                Icons.location_on,
                                "Campus",
                                appointment['Appointment_Campus']?.toString(),
                              ),
                              _buildInfoRow(
                                Icons.notes,
                                "Reason",
                                appointment['Appointment_Reason']?.toString(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}