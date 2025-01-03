import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalCertificate extends StatefulWidget {
  const MedicalCertificate({Key? key}) : super(key: key);

  @override
  State<MedicalCertificate> createState() => _MedicalCertificateState();
}

class _MedicalCertificateState extends State<MedicalCertificate> {
  final TextEditingController _mcDurationController = TextEditingController();
  final TextEditingController _mcDateController = TextEditingController(); // Controller for MC Date
  final TextEditingController _manualUserNameController = TextEditingController();
  final TextEditingController _manualAppointmentDateController = TextEditingController();
  final TextEditingController _manualAppointmentServiceController = TextEditingController();
  final TextEditingController _manualAppointmentReasonController = TextEditingController();
  Map<String, dynamic>? appointmentDetails;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentDetails();
  }

  Future<void> _fetchAppointmentDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user is logged in.");
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Appointment')
          .where('User_ID', isEqualTo: user.uid)
          .orderBy('Appointment_Date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          appointmentDetails = querySnapshot.docs.first.data();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No appointments found for this user')),
        );
      }
    } catch (e) {
      print("Error fetching appointment details: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveMedicalCertificate() async {
    if (_mcDurationController.text.isEmpty || _mcDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all required fields')),
      );
      return;
    }

    try {
      final mcId = FirebaseFirestore.instance.collection('Medical_Certificate').doc().id;

      final mcData = {
        'MC_ID': mcId,
        'MC_Duration': int.parse(_mcDurationController.text),
        'MC_Date': _mcDateController.text,
      };

      if (appointmentDetails != null) {
        mcData.addAll({
          'Appointment_Date': appointmentDetails!['Appointment_Date'],
          'Appointment_Service': appointmentDetails!['Appointment_Service'],
          'User_ID': appointmentDetails!['User_ID'],
          'Appointment_Reason': appointmentDetails!['Appointment_Reason'],
        });
      } else {
        mcData.addAll({
          'Appointment_Date': _manualAppointmentDateController.text,
          'Appointment_Service': _manualAppointmentServiceController.text,
          'User_ID': _auth.currentUser?.uid ?? 'N/A',
          'Appointment_Reason': _manualAppointmentReasonController.text,
        });
      }

      await FirebaseFirestore.instance.collection('Medical_Certificate').doc(mcId).set(mcData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MC Created Successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error saving medical certificate: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create MC')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Certificate'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointmentDetails == null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No appointment found. Enter details manually:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _manualUserNameController,
                          decoration: const InputDecoration(
                            labelText: 'User Name',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _manualAppointmentDateController,
                          decoration: const InputDecoration(
                            labelText: 'Appointment Date',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _manualAppointmentServiceController,
                          decoration: const InputDecoration(
                            labelText: 'Appointment Service',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _manualAppointmentReasonController,
                          decoration: const InputDecoration(
                            labelText: 'Appointment Reason',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _mcDurationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'MC Duration (in days)',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _mcDateController,
                          decoration: const InputDecoration(
                            labelText: 'MC Date',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveMedicalCertificate,
                          child: const Text('Save MC'),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Medical Certificate',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'User Name: ${appointmentDetails!['User_Name'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Appointment Date: ${appointmentDetails!['Appointment_Date'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Service: ${appointmentDetails!['Appointment_Service'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reason: ${appointmentDetails!['Appointment_Reason'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _mcDurationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'MC Duration (in days)',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _mcDateController,
                        decoration: const InputDecoration(
                          labelText: 'MC Date',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveMedicalCertificate,
                        child: const Text('Save MC'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
