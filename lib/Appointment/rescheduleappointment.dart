import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RescheduleAppointment extends StatefulWidget {
  final String appointmentId;

  const RescheduleAppointment({super.key, required this.appointmentId});

  @override
  State<RescheduleAppointment> createState() => _RescheduleAppointmentState();
}

class _RescheduleAppointmentState extends State<RescheduleAppointment> {
  DateTime selectedDate = DateTime.now();
  String selectedService = 'Dental Service';
  String selectedSpecialization = '';
  String selectedTimeslot = '8.00 AM';
  String selectedCampus = 'Gambang';
  List<String> availableTimeslots = [];

   void _showError(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  final List<String> services = [
    'Dental Service',
    'Medical Health Service',
    'Mental Health Service',
  ];

  final Map<String, List<String>> medicalSpecializations = {
    'Medical Health Service': ['Diabetes', 'Obesity', 'Hypertension', 'Physiotherapy'],
  };

  final Map<String, List<String>> serviceTimeslots = {
    'Dental Service': ['8:00 AM', '10:00 AM', '2:00 PM', '4:00 PM'],
    'Medical Health Service': ['8:00 AM', '10:00 AM', '2:00 PM', '4:00 PM'],
    'Mental Health Service': ['8:00 AM', '10:00 AM', '2:00 PM', '4:00 PM'],
  };

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
     print("Appointment ID: ${widget.appointmentId}"); // Debugging
    _fetchAppointmentDetails(context); // Now context is available
  });
  availableTimeslots = serviceTimeslots[selectedService] ?? [];
}


  // Fetch current appointment details
  Future<void> _fetchAppointmentDetails(BuildContext context) async {
  try {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showError(context, 'No user is logged in');
      return;
    }

    final String userId = currentUser.uid;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Appointment')
        .where('User_ID', isEqualTo: userId)
        .where('Appointment_ID', isEqualTo: widget.appointmentId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      _showError(context, 'No appointment found for the logged-in user');
      return;
    }

    // Get the first appointment document
    final DocumentSnapshot doc = snapshot.docs.first;
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      _showError(context, 'Appointment data is empty');
      return;
    }

    setState(() {
      selectedDate = data['Appointment_Date'] != null
          ? (data['Appointment_Date'] is Timestamp
              ? (data['Appointment_Date'] as Timestamp).toDate()
              : DateFormat('yyyy-MM-dd').parse(data['Appointment_Date']))
          : DateTime.now();
      selectedService = data['Appointment_Service'] ?? selectedService;
      selectedCampus = data['Appointment_Campus'] ?? selectedCampus;
      selectedTimeslot = data['Appointment_Time'] ?? selectedTimeslot;
    });

    await _fetchAvailableTimeslots();

    // Ensure the previously selected timeslot is included
    setState(() {
      if (!availableTimeslots.contains(selectedTimeslot)) {
        availableTimeslots.add(selectedTimeslot);
      }
    });
  } catch (e) {
    print('Error fetching appointment details: $e');
    _showError(context, 'Error fetching appointment details: $e');
  }
}

  // Fetch available timeslots
  Future<void> _fetchAvailableTimeslots() async {
  try {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    List<String> allTimeslots = serviceTimeslots[selectedService] ?? [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Appointment')
        .where('Appointment_Date', isEqualTo: formattedDate)
        .where('Appointment_Service', isEqualTo: selectedService)
        .where('Appointment_Campus', isEqualTo: selectedCampus)
        .get();

    List<String> bookedSlots = snapshot.docs
        .map((doc) => doc.get('Appointment_Time') as String)
        .toList();

    setState(() {
      availableTimeslots = allTimeslots
          .where((timeslot) => !bookedSlots.contains(timeslot))
          .toList();

      // Ensure the previously selected timeslot is included
      if (selectedTimeslot.isNotEmpty &&
          !availableTimeslots.contains(selectedTimeslot)) {
        availableTimeslots.add(selectedTimeslot);
      }
    });
  } catch (e) {
    print('Error fetching available timeslots: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading available timeslots: $e')),
      );
    }
  }
}


  // Update the appointment
 Future<void> _updateAppointment() async {
  try {
    print("Reschedule triggered for Appointment_ID: ${widget.appointmentId}");

    // Query the document ID using Appointment_ID
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Appointment')
        .where('Appointment_ID', isEqualTo: widget.appointmentId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception("No appointment found with Appointment_ID: ${widget.appointmentId}");
    }

    final doc = snapshot.docs.first;
    String documentId = doc.id;
    print("Document ID retrieved: $documentId");
    print("Document data before update: ${doc.data()}");

    // Validate update data
    if (selectedTimeslot.isEmpty) {
      throw Exception("Selected timeslot is empty.");
    }

    // Update the appointment document
    await FirebaseFirestore.instance
        .collection('Appointment')
        .doc(documentId)
        .update({
      'Appointment_Date': DateFormat('yyyy-MM-dd').format(selectedDate),
      'Appointment_Time': selectedTimeslot,
      'Appointment_Service': selectedService,
      'Appointment_Campus': selectedCampus,
      'Updated_At': FieldValue.serverTimestamp(),
    });

    print("Appointment updated successfully.");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment rescheduled successfully.')),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    print('Error updating document: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating appointment: $e')),
      );
    }
  }
}


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedTimeslot = '';
      });
      await _fetchAvailableTimeslots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reschedule Appointment',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF009FA0),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDateSelection(context),
                _buildServiceDropdown(),
                if (selectedService == 'Medical Health Service')
                  _buildSpecializationDropdown(),
                _buildTimeSlotsGrid(),
                const SizedBox(height: 32.0),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009FA0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: selectedTimeslot.isEmpty
                        ? null
                        : _updateAppointment,
                    child: const Text(
                      'Reschedule',
                      style: TextStyle(
                        fontSize: 18.0,
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
    );
  }

  Widget _buildDateSelection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF009FA0),
              ),
            ),
            const SizedBox(height: 12.0),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.teal.shade100, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEE, d MMMM yyyy').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: Colors.teal.shade700),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Service',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF009FA0),
              ),
            ),
            const SizedBox(height: 12.0),
            DropdownButtonFormField<String>(
              value: selectedService,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.teal.shade700),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.teal.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.teal.shade100, width: 1.5),
                ),
              ),
              items: services.map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (newValue) async {
                setState(() {
                  selectedService = newValue!;
                  selectedTimeslot = ''; // Clear selected timeslot when service changes
                });
                await _fetchAvailableTimeslots(); // Fetch new available timeslots
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializationDropdown() {
    // Initialize selectedSpecialization if it's empty
  if (selectedSpecialization.isEmpty && medicalSpecializations['Medical Health Service']?.isNotEmpty == true) {
    selectedSpecialization = medicalSpecializations['Medical Health Service']!.first;
  }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Specialization',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF009FA0),
              ),
            ),
            const SizedBox(height: 12.0),
            DropdownButtonFormField<String>(
              value: selectedSpecialization,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.teal.shade700),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.teal.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.teal.shade100, width: 1.5),
                ),
              ),
              items: medicalSpecializations['Medical Health Service']?.map((String specialization) {
                return DropdownMenuItem<String>(
                  value: specialization,
                  child: Text(specialization),
                );
              }).toList() ?? [],
              onChanged: (newValue) {
                setState(() {
                  selectedSpecialization = newValue!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsGrid() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Time',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF009FA0),
              ),
            ),
            const SizedBox(height: 16.0),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 2.2,
              physics: const NeverScrollableScrollPhysics(),
              children: availableTimeslots.map((timeslot) {
                return Container(
                  decoration: BoxDecoration(
                    color: selectedTimeslot == timeslot
                        ? const Color(0xFF009FA0)
                        : Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: selectedTimeslot == timeslot
                          ? const Color(0xFF009FA0)
                          : Colors.teal.shade100,
                      width: 1.0,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTimeslot = timeslot;
                      });
                    },
                    child: Center(
                      child: Text(
                        timeslot,
                        style: TextStyle(
                          color: selectedTimeslot == timeslot
                              ? Colors.white
                              : Colors.teal.shade700,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: 1,
      selectedItemColor: const Color(0xFF009FA0),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }
}
