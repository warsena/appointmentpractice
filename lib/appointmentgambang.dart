import 'package:flutter/material.dart';

class Appointmentgambang extends StatefulWidget {
  const Appointmentgambang({super.key});

  @override
  State<Appointmentgambang> createState() => _AppointmentgambangState();
}

class _AppointmentgambangState extends State<Appointmentgambang> {
  DateTime selectedDate = DateTime.now();
  String selectedService = 'Select Services';
  final List<String> services = [
    'Dental(3)',
    'Hypertension(1)',
    'Obesity(2)',
    'Physiotherapy(0)',
    'Stress Consultation(1)'
  ];
  final List<String> timeslots = ['9:00 AM', '2:00 PM', '5:00 PM'];
  String? selectedTimeslot;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
        backgroundColor: const Color(0xFF009FA0), // Turquoise color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Selector
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Select Date',
                      hintText:
                          '${selectedDate.day}, ${selectedDate.month} ${selectedDate.year}',
                      filled: true,
                      fillColor: Colors.teal[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.teal),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Select Services Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedService,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedService = newValue!;
                  });
                },
                items: services.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Services List
            Column(
              children: services.map((service) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: Colors.teal[100],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      service,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),

            // Select Timeslot
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Select a timeslot',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 10.0,
              children: timeslots.map((timeslot) {
                return ChoiceChip(
                  label: Text(timeslot),
                  selected: selectedTimeslot == timeslot,
                  selectedColor: Colors.teal[200],
                  onSelected: (bool selected) {
                    setState(() {
                      selectedTimeslot = selected ? timeslot : null;
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009FA0),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // Add booking logic here
                },
                child: const Text(
                  'BOOK',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
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
        currentIndex: 1,
        selectedItemColor: const Color(0xFF009FA0),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
