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
  const CreateAppointment({super.key});

  @override
  State<CreateAppointment> createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  String? selectedCampus;
  String? selectedServiceCategory;
  bool isLoading = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Service categories and campuses definition
  final List<ServiceCategory> serviceCategories = [
    ServiceCategory(
      title: 'Dental Service',
      services: ['Dental'],
      color: Colors.teal.shade100,
    ),
    ServiceCategory(
      title: 'Medical Health Service',
      services: ['Diabetes', 'Obesity', 'Hypertension', 'Physiotherapy'],
      color: Colors.teal.shade50,
    ),
    ServiceCategory(
      title: 'Mental Health Service',
      services: ['Stress Consultation'],
      color: Colors.teal.shade100,
    ),
  ];

  final Map<String, int> serviceLimits = {};
  final List<String> campuses = ['Pekan', 'Gambang'];

  @override
  void initState() {
    super.initState();
    loadServiceLimits();
  }

 Future<void> loadServiceLimits() async {
  if (selectedCampus == null || selectedServiceCategory == null) return;

  setState(() => isLoading = true);
  try {
    serviceLimits.clear();
    final snapshot = await _db
        .collection('Service')
        .where('Campus_Name', isEqualTo: selectedCampus)
        .where('Service_Category', isEqualTo: selectedServiceCategory)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final serviceName = data['Service_Name'] as String?;
      final serviceLimit = data['Service_Limit'] as int?;
      if (serviceName != null && serviceLimit != null) {
        serviceLimits[serviceName] = serviceLimit;
      }
    }
  } catch (e) {
    print('Error loading service limits: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading service limits: $e')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}

  Future<void> saveServiceLimits() async {
  if (selectedCampus == null || selectedServiceCategory == null || serviceLimits[selectedServiceCategory] == null) {
    return;
  }

  setState(() => isLoading = true);
  try {
    // Create a new document reference
    DocumentReference docRef = _db.collection('Service').doc();

    // Set the service data in the new document
    await docRef.set({
      'Service_ID': docRef.id,
      'Service_Limit': serviceLimits[selectedServiceCategory],
      'Service_Name': selectedServiceCategory,
      'Campus_Name': selectedCampus,
      'Service_Category': selectedServiceCategory,
      'timestamp': FieldValue.serverTimestamp(),
    });


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service limits saved successfully')),
    );
  } catch (e) {
    print('Error saving service limits: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving service limits: $e')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}

  Widget buildServiceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selectedCampus,
          decoration: const InputDecoration(labelText: 'Select Campus'),
          items: campuses.map((campus) {
            return DropdownMenuItem(value: campus, child: Text(campus));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCampus = value;
              selectedServiceCategory = null;
              serviceLimits.clear();
            });
          },
        ),
        if (selectedCampus != null) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedServiceCategory,
            decoration: const InputDecoration(labelText: 'Select Service Category'),
            items: serviceCategories.map((category) {
              return DropdownMenuItem(value: category.title, child: Text(category.title));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedServiceCategory = value;
                serviceLimits.clear();
                loadServiceLimits();
              });
            },
          ),
        ],
      ],
    );
  }

 Widget buildServiceLimitControl() {
    if (selectedServiceCategory == null) return Container();
    serviceLimits[selectedServiceCategory!] ??= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set limit for $selectedServiceCategory',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (serviceLimits[selectedServiceCategory!]! > 0) {
                    serviceLimits[selectedServiceCategory!] = serviceLimits[selectedServiceCategory!]! - 1;
                  }
                });
              },
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${serviceLimits[selectedServiceCategory] ?? 0}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  if (serviceLimits[selectedServiceCategory!]! < 4) {
                    serviceLimits[selectedServiceCategory!] = serviceLimits[selectedServiceCategory!]! + 1;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Maximum service limit is 4')),
                    );
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal.shade600,
        title: const Text('Create Appointment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                buildServiceSelector(),
                const SizedBox(height: 24),
                buildServiceLimitControl(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: saveServiceLimits,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}