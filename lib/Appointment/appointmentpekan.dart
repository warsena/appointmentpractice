import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication


class Appointmentpekan extends StatefulWidget {
  const Appointmentpekan({super.key});

  @override
  State<Appointmentpekan> createState() => _AppointmentpekanState();
}

class _AppointmentpekanState extends State<Appointmentpekan> {
  DateTime selectedDate = DateTime.now();
  String selectedService = 'Dental Service';
  String selectedSpecialization = '';
  String selectedTimeslot = '8.00 AM'; //letak sbb tk blh kosong
  String selectedCampus = 'Pekan';
  List<String> availableTimeslots = [];

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
    availableTimeslots = serviceTimeslots[selectedService] ?? [];
    _fetchAvailableTimeslots();
  }

  // In _fetchAvailableTimeslots() - we want ALL booked slots for the day
  Future<void> _fetchAvailableTimeslots() async {
    try {
      // Format the selected date to match Firestore storage format
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      // Get all possible timeslots for the selected service
      List<String> allTimeslots = serviceTimeslots[selectedService] ?? [];
      

      // Query Firestore for booked appointments
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Appointment')
          .where('Appointment_Date', isEqualTo: formattedDate)
          .where('Appointment_Service', isEqualTo: selectedService)
          .where('Appointment_Campus', isEqualTo: selectedCampus)
          .get();

      // Get list of booked timeslots
      List<String> bookedSlots = snapshot.docs
          .map((doc) => doc.get('Appointment_Time') as String)
          .toList();

     

      // Update state with available timeslots
      setState(() {
        availableTimeslots = allTimeslots
            .where((timeslot) => !bookedSlots.contains(timeslot))
            .toList();

        // Clear selected timeslot if it's no longer available
       if (!availableTimeslots.contains(selectedTimeslot)) {
          selectedTimeslot = '';
        }
      });
    } catch (e) {
      print('Error fetching timeslots: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading available timeslots: $e')),
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
        selectedTimeslot = ''; // Clear selected timeslot when date changes
      });
      await _fetchAvailableTimeslots();
    }
  }

Future<void> _bookAppointment() async {
  try {
    // Check if the user is logged in
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to book an appointment')),
        );
      }
      return;
    }

    if (selectedTimeslot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a timeslot')),
      );
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Check for existing bookings
    QuerySnapshot existingBookings = await FirebaseFirestore.instance
        .collection('Appointment')
        .where('Appointment_Date', isEqualTo: formattedDate)
        .where('Appointment_Time', isEqualTo: selectedTimeslot)
        .where('Appointment_Service', isEqualTo: selectedService)
        .where('Appointment_Campus', isEqualTo: selectedCampus)
        .get();

    if (existingBookings.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This timeslot has just been booked. Please select another timeslot.'),
        ),
      );
      await _fetchAvailableTimeslots();
      return;
    }

    // Add a new appointment to Firestore
    final newAppointmentRef = FirebaseFirestore.instance.collection('Appointment').doc();

    // Create the appointment data
    final appointmentData = {
      'Appointment_ID': newAppointmentRef.id, // Use the document ID as Appointment_ID
      'Appointment_Date': formattedDate,
      'Appointment_Time': selectedTimeslot,
      'Appointment_Campus': selectedCampus,
      'Appointment_Service': selectedService,
      'Created_At': FieldValue.serverTimestamp(),
      'User_ID': currentUser.uid, // Use the current user's UID
    };

    // Add the appointment to Firestore
    await newAppointmentRef.set(appointmentData); // Use set() with the document reference

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your booking is successfully confirmed.')),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    print('Error booking appointment: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking appointment: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pekan Appointment',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
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
                      backgroundColor: Colors.teal,
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
