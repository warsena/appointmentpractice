import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Appointmentpekan extends StatefulWidget {
  const Appointmentpekan({super.key});

  @override
  State<Appointmentpekan> createState() => _AppointmentgambangState();
}

class _AppointmentgambangState extends State<Appointmentpekan> {
  DateTime selectedDate = DateTime.now();
  String selectedService = 'Dental Service';
  String selectedSpecialization = '';
  String selectedTimeslot = '8:00 AM';
  String selectedCampus = 'Pekan';

  final List<String> services = [
    'Dental Service',
    'Medical Health Service',
    'Mental Health Service',
  ];

  final Map<String, List<String>> medicalSpecializations = {
    'Medical Service': ['Diabetes', 'Obesity', 'Hypertension', 'Physiotherapy'],
  };

  final Map<String, List<String>> serviceTimeslots = {
    'Dental Service': ['8:00 AM', '10:00 AM', '2:00 PM', '4:00 PM'],
    'Medical Health Service': ['8:00 AM', '10:00 AM', '2:00 PM', '4:00 PM'],
    'Mental Health Service': ['8:00 AM', '10:00 AM', '2:00 PM', '4:00 PM'],
  };

  List<String> availableTimeslots = [];
  List<String> availableSpecializations = [];

  @override
  void initState() {
    super.initState();
    availableTimeslots = serviceTimeslots[selectedService]!;
    if (selectedService == 'Medical Health Service') {
      availableSpecializations = medicalSpecializations[selectedService]!;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: const Color(0xFF009FA0),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
    try {
      // Generate a new document ID
      String appointmentId =
          FirebaseFirestore.instance.collection('Appointment').doc().id;

      // Save the appointment to Firestore
      await FirebaseFirestore.instance
          .collection('Appointment')
          .doc(appointmentId)
          .set({
        'Appointment_ID': appointmentId,
        'Appointment_Date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'Appointment_Time': selectedTimeslot,
        'Appointment_Status': '',
        'Appointment_Campus': selectedCampus,
        'Appointment_Service': selectedService,
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your booking is successfully confirmed.')),
      );

      // Navigate to the home page
      Navigator.pop(context);
    } catch (e) {
      print('Error booking appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gambang Appointment',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF009FA0),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Navigate to the home page
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDateSelection(context),
                _buildServiceDropdown(),
                if (selectedService == 'Medical Service')
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
                    onPressed: _bookAppointment,
                    child: const Text(
                      'Book Appointment',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
                  color: Color(0xFF009FA0)),
            ),
            const SizedBox(height: 12.0),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
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
                          fontSize: 16.0, fontWeight: FontWeight.w500),
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
                  color: Color(0xFF009FA0)),
            ),
            const SizedBox(height: 12.0),
            DropdownButtonFormField<String>(
              value: selectedService,
              icon:
                  Icon(Icons.keyboard_arrow_down, color: Colors.teal.shade700),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.teal.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      BorderSide(color: Colors.teal.shade100, width: 1.5),
                ),
              ),
              items: services.map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedService = newValue!;
                  availableTimeslots = serviceTimeslots[selectedService]!;
                  if (selectedService != 'Medical Service') {
                    selectedSpecialization = '';
                    availableSpecializations = [];
                  } else {
                    availableSpecializations =
                        medicalSpecializations[selectedService]!;
                    selectedSpecialization = availableSpecializations.first;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializationDropdown() {
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
                  color: Color(0xFF009FA0)),
            ),
            const SizedBox(height: 12.0),
            DropdownButtonFormField<String>(
              value: selectedSpecialization,
              icon:
                  Icon(Icons.keyboard_arrow_down, color: Colors.teal.shade700),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.teal.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      BorderSide(color: Colors.teal.shade100, width: 1.5),
                ),
              ),
              items: availableSpecializations.map((String specialization) {
                return DropdownMenuItem<String>(
                  value: specialization,
                  child: Text(specialization),
                );
              }).toList(),
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
                  color: Color(0xFF009FA0)),
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
