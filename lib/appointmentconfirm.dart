import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentConfirm extends StatefulWidget {
  final String selectedService;
  final String selectedTimeslot;
  final DateTime selectedDate;

  const AppointmentConfirm({
    super.key,
    required this.selectedService,
    required this.selectedTimeslot,
    required this.selectedDate,
  });

  @override
  State<AppointmentConfirm> createState() => _AppointmentConfirmState();
}

class _AppointmentConfirmState extends State<AppointmentConfirm> {
  bool isConfirmed = false; // Track confirmation status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment'),
        backgroundColor: const Color(0xFF009FA0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon and message based on confirmation status
            if (!isConfirmed)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Centers content vertically within the column
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 60,
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Kindly confirm your appointment details',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                      textAlign: TextAlign
                          .center, // Center aligns text within its container
                    ),
                  ],
                ),
              )
            else
              const Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 60,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Appointment Confirm',
                    style: TextStyle(fontSize: 16.0, color: Colors.green),
                  ),
                ],
              ),
            const SizedBox(height: 20.0),

            // Appointment details card
            Card(
              color: Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UMPSA Pekan',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Service: ${widget.selectedService}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      'Date: ${DateFormat('EEE, d MMM yyyy').format(widget.selectedDate)}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      'Time: ${widget.selectedTimeslot}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // Confirm or Close button based on confirmation status
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009FA0),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 40.0), // Adjusted padding for larger size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                setState(() {
                  isConfirmed = !isConfirmed; // Toggle confirmation status
                });
              },
              child: Text(
                isConfirmed ? 'CLOSE' : 'CONFIRM',
                style: const TextStyle(
                  fontSize: 18.0, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
        currentIndex: 1, // Set to calendar tab
        selectedItemColor: const Color(0xFF009FA0),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
