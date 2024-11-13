import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appointmentpractice/Appointment/appointmentlist.dart';

class ServiceCategory {
  final String title;
  final List<String> services;
  final Color color;

  ServiceCategory({
    required this.title,
    required this.services,
    required this.color,
  });
}

class CreateAppointment extends StatefulWidget {
  const CreateAppointment({Key? key}) : super(key: key);

  @override
  State<CreateAppointment> createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  String? selectedCampus = 'Pekan';
  String? selectedService = 'Services';
  bool isLoading = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Service categories definition
  final List<ServiceCategory> serviceCategories = [
    ServiceCategory(
      title: 'Dental Services',
      services: ['Dental'],
      color: Colors.teal.shade100,
    ),
    ServiceCategory(
      title: 'Medical Services',
      services: ['Diabetes', 'Obesity', 'Hypertension', 'Physiotherapy'],
      color: Colors.teal.shade50,
    ),
    ServiceCategory(
      title: 'Mental Health Services',
      services: ['Stress Consultation'],
      color: Colors.teal.shade100,
    ),
  ];

  // Map to store service limits
  final Map<String, int> serviceLimits = {
    'Dental': 0,
    'Diabetes': 0,
    'Obesity': 0,
    'Hypertension': 0,
    'Physiotherapy': 0,
    'Stress Consultation': 0,
  };

  final List<String> campuses = ['Pekan', 'Gambang'];

  @override
  void initState() {
    super.initState();
    loadServiceLimits();
  }

  Future<void> loadServiceLimits() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await _db
          .collection('services')
          .where('campusName', isEqualTo: selectedCampus)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (serviceLimits.containsKey(data['serviceName'])) {
          setState(() {
            serviceLimits[data['serviceName']] = data['serviceLimit'] ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error loading service limits: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading service limits: $e')),
        );
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> saveServiceLimits() async {
    setState(() => isLoading = true);
    try {
      final batch = _db.batch();

      final existingDocs = await _db
          .collection('services')
          .where('campusName', isEqualTo: selectedCampus)
          .get();

      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      // Save all services from all categories
      for (var category in serviceCategories) {
        for (var service in category.services) {
          final docRef = _db.collection('services').doc();
          batch.set(docRef, {
            'Service_ID': '${selectedCampus!.substring(0, 3).toUpperCase()}_${service.substring(0, 3).toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}',
            'Service_Limit': serviceLimits[service],
            'Service_Name': service,
            'Campus_Name': selectedCampus,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service limits saved successfully')),
        );
      }
    } catch (e) {
      print('Error saving service limits: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving service limits: $e')),
        );
      }
    }
    setState(() => isLoading = false);
  }

  Widget buildServiceCategory(ServiceCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...category.services.map((service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.teal.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (serviceLimits[service]! > 0) {
                                  serviceLimits[service] = serviceLimits[service]! - 1;
                                }
                              });
                            },
                            color: Colors.teal,
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${serviceLimits[service]}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                serviceLimits[service] = serviceLimits[service]! + 1;
                              });
                            },
                            color: Colors.teal,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal.shade600,
        title: const Text(
          'Create Appointment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.shade600,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      value: selectedCampus,
                      decoration: InputDecoration(
                        labelText: 'Campus',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedCampus = value;
                        });
                        loadServiceLimits();
                      },
                      items: campuses.map((campus) {
                        return DropdownMenuItem(
                          value: campus,
                          child: Text(campus),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...serviceCategories.map((category) => buildServiceCategory(category)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: saveServiceLimits,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AppointmentList(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'View Appointments',
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
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}