import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

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
        DocumentSnapshot<Map<String, dynamic>> userDoc = 
            await firestore.collection('User').doc(user.uid).get();

        if (userDoc.exists && userDoc.data()?['User_Type'] == 'Doctor') {
          setState(() {
            doctorName = userDoc.data()?['User_Name'] ?? "Unknown";
            doctorService = userDoc.data()?['Selected_Service'] ?? "Unknown";
            doctorCampus = userDoc.data()?['Campus'] ?? "Unknown";
          });

          QuerySnapshot<Map<String, dynamic>> appointmentDocs = 
              await firestore
              .collection('Appointment')
              .where('Appointment_Service', isEqualTo: doctorService)
              .where('Appointment_Campus', isEqualTo: doctorCampus)
              .get();

          appointments = appointmentDocs.docs.map((doc) {
            return {
              'Appointment_Date': doc.data()['Appointment_Date'],
              'Appointment_Time': doc.data()['Appointment_Time'],
              'Appointment_Service': doc.data()['Appointment_Service'],
              'Appointment_Campus': doc.data()['Appointment_Campus'],
            };
          }).toList();

          // Sort appointments by date
          appointments.sort((a, b) {
            DateTime dateA = DateFormat('dd/MM/yyyy').parse(a['Appointment_Date']);
            DateTime dateB = DateFormat('dd/MM/yyyy').parse(b['Appointment_Date']);
            return dateA.compareTo(dateB);
          });
        }

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print('Error fetching data: $e');
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

  void _showAppointmentDetailsDialog(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: appointment['Appointment_Date'],
              ),
              _buildDetailRow(
                icon: Icons.access_time,
                label: 'Time',
                value: appointment['Appointment_Time'],
              ),
              _buildDetailRow(
                icon: Icons.medical_services,
                label: 'Service',
                value: appointment['Appointment_Service'],
              ),
              _buildDetailRow(
                icon: Icons.location_on,
                label: 'Campus',
                value: appointment['Appointment_Campus'],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(37, 163, 255, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromRGBO(37, 163, 255, 1), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Doctor\'s Schedule',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color.fromRGBO(37, 163, 255, 1),
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(37, 163, 255, 1),
              ),
            )
          : Column(
              children: [
                // Doctor Details Card
                if (doctorName.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(37, 163, 255, 1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color.fromRGBO(37, 163, 255, 1),
                          size: 30,
                        ),
                      ),
                      title: Text(
                        doctorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            "Service: $doctorService",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            "Campus: $doctorCampus",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Appointments List
                Expanded(
                  child: appointments.isEmpty
                      ? const Center(
                          child: Text(
                            "No appointments scheduled",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = appointments[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(37, 163, 255, 1).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today,
                                    color: Color.fromRGBO(37, 163, 255, 1),
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  appointment['Appointment_Date'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      "Time: ${appointment['Appointment_Time']}",
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    Text(
                                      "Service: ${appointment['Appointment_Service']}",
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                onTap: () => _showAppointmentDetailsDialog(appointment),
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