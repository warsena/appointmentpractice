import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointmentconfirm.dart';

class Appointmentpekan extends StatefulWidget {
  const Appointmentpekan({super.key});

  @override
  State<Appointmentpekan> createState() => _AppointmentpekanState();
}

class _AppointmentpekanState extends State<Appointmentpekan> {
  DateTime selectedDate = DateTime.now();
  String selectedService = 'Dental Service';
  String selectedSpecialization = 'Diabetes';
  String selectedTimeslot = '8:00 AM';

  final List<String> services = [
    'Dental Service',
    'Medical Service',
    'Mental Health Service',
  ];

  final Map<String, List<String>> medicalSpecializations = {
    'Medical Service': ['Diabetes', 'Obesity', 'Hypertension', 'Physiotherapy'],
  };

  final Map<String, List<String>> serviceTimeslots = {
    'Dental Service': ['8:00 AM', '10:00 AM', '2:00 PM', '4:00 PM'],
    'Medical Service': ['8:00 AM', '10:00 AM', '2:00 PM', '4:00 PM'],
    'Mental Health Service': ['8:00 AM', '10:00 AM', '2:00 PM', '4:00 PM'],
  };

  List<String> availableTimeslots = [];
  List<String> availableSpecializations = [];

  @override
  void initState() {
    super.initState();
    availableTimeslots = serviceTimeslots[selectedService]!;
    if (selectedService == 'Medical Service') {
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
            colorScheme: ColorScheme.light(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF009FA0),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                              border: Border.all(
                                color: Colors.teal.shade100,
                                width: 1.5,
                              ),
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
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.teal.shade700,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),

                // Services Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: Colors.teal.shade100, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                                availableSpecializations = medicalSpecializations[selectedService]!;
                                selectedSpecialization = availableSpecializations.first;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                if (selectedService == 'Medical Service') ...[
                  const SizedBox(height: 20.0),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: Colors.teal.shade100, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                  ),
                ],

                const SizedBox(height: 20.0),

                // Time Slots Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                ),


                const SizedBox(height: 32.0),

                // Book Button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009FA0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentConfirm(
                            selectedService: selectedService,
                            selectedSpecialization: selectedSpecialization,
                            selectedTimeslot: selectedTimeslot,
                            selectedDate: selectedDate,
                          ),
                        ),
                      );
                    },
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
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
        ),
      ),
    );
  }
}