import 'package:flutter/material.dart';

class AppointmentList extends StatefulWidget {
  const AppointmentList({super.key});

  @override
  State<AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  String selectedLocation = 'Select Campus';
  String selectedService = 'Select Service'; // Keeping as placeholder
  final List<String> locations = ['Select Campus', 'Gambang', 'Pekan'];
  final List<String> services = ['Select Service', 'Dental', 'Physiotherapy', 'Obesity', 'Checkup', 'Stress Consultation', 'Hypertension', 'Diabetes']; // Added placeholder

  final List<Map<String, dynamic>> appointmentData = [
    {
      'no': 1,
      'service': 'Dental',
      'totalPerDay': 5,
      'booked': 3,
      'available': 2,
    },
    {
      'no': 2,
      'service': 'Physiotherapy',
      'totalPerDay': 4,
      'booked': 3,
      'available': 2,
    },
    {
      'no': 3,
      'service': 'Diabetes',
      'totalPerDay': 4,
      'booked': 4,
      'available': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: const Text(
          'Appointment List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              children: [
                // Filters section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Location Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedLocation,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: locations.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Service Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedService,
                        decoration: InputDecoration(
                          labelText: 'Service',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: services.map((service) {
                          return DropdownMenuItem(
                            value: service,
                            child: Text(service),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedService = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Search Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Appointment Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointmentData.length,
              itemBuilder: (context, index) {
                final appointment = appointmentData[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appointment['service'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.black45),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.black45),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        _buildInfoRow('Total Per Day', appointment['totalPerDay'].toString()),
                        _buildInfoRow('Booked', appointment['booked'].toString()),
                        _buildInfoRow(
                          'Available',
                          appointment['available'].toString(),
                          textColor: appointment['available'] > 0 ? Colors.green : Colors.red,
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
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],

      ),
    );
  }
}
