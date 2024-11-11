import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Appointmentgambang extends StatefulWidget {
  const Appointmentgambang({super.key});

  @override
  State<Appointmentgambang> createState() => _AppointmentgambangState();
}

class _AppointmentgambangState extends State<Appointmentgambang> {
  DateTime selectedDate = DateTime.now();
  String selectedService = 'Dental(3)';
  String selectedTimeslot = '9:00 AM';

  final List<String> services = [
    'Dental(3)',
    'Hypertension(1)',
    'Obesity(2)',
    'Physiotherapy(3)',
    'Stress Consultation(1)',
    'Checkup(3)', //first time go to checkout without knowing their symptom
  ];

  // Map to hold timeslots for each service
  final Map<String, List<String>> serviceTimeslots = {
    'Dental(3)': ['9:00 AM', '2:00 PM', '5:00 PM'],
    'Hypertension(1)': ['10:00 AM'],
    'Obesity(2)': ['11:00 AM', '2.00 PM'],
    'Physiotherapy(3)': ['1:00 PM', '3:30 PM', '5:30 PM'],
    'Stress Consultation(1)': ['9:30 AM'],
    'Checkup(3)': ['9.00 AM', '12.00 PM', '3.00 PM'],
  };

  List<String> availableTimeslots = [];

  @override
  void initState() {
    super.initState();
    // Initialize available timeslots based on the default selected service
    availableTimeslots = serviceTimeslots[selectedService]!;
  }

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
        title: const Text('Services'),
        backgroundColor: const Color(0xFF009FA0), // Turquoise color for the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.teal[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('EEE, d MMMM yyyy').format(selectedDate),
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(width: 8.0),
                        const Icon(Icons.calendar_today, color: Colors.teal),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // Services dropdown
            const Text(
              'Select Services',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              value: selectedService,
              items: services.map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedService = newValue!;
                  // Update available timeslots based on selected service
                  availableTimeslots = serviceTimeslots[selectedService]!;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.teal[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // Timeslot selection
            const Text(
              'Select a timeslot',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: availableTimeslots.map((timeslot) {
                return ChoiceChip(
                  label: Text(timeslot),
                  selected: selectedTimeslot == timeslot,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedTimeslot = timeslot;
                    });
                  },
                  selectedColor: Colors.teal[200],
                  backgroundColor: Colors.teal[50],
                );
              }).toList(),
            ),
            const SizedBox(height: 20.0),

            // Book button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009FA0),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                // Action on book button press
              },
              child: const Text(
                'Book',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
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
