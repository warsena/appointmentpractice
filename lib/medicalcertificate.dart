import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalCertificate extends StatefulWidget {
  const MedicalCertificate({super.key});

  @override
  State<MedicalCertificate> createState() => _MedicalCertificateState();
}

class _MedicalCertificateState extends State<MedicalCertificate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _appointmentDateController =
      TextEditingController();
  final TextEditingController _appointmentServiceController =
      TextEditingController();
  final TextEditingController _appointmentReasonController =
      TextEditingController();
  final TextEditingController _mcDurationController = TextEditingController();
  final TextEditingController _mcDateController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();

  // Save the form data to Firestore
  Future<void> _saveMedicalCertificate() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a new document in Firestore under 'Medical_Certificate' collection
        await FirebaseFirestore.instance.collection('Medical_Certificate').add({
          'MC_ID': DateTime.now()
              .millisecondsSinceEpoch
              .toString(), // Unique ID for the medical certificate
          'Name': _nameController.text,
          'Appointment_Date': _appointmentDateController.text,
          'Appointment_Service': _appointmentServiceController.text,
          'Appointment_Reason': _appointmentReasonController.text,
          'MC_Duration': _mcDurationController.text,
          'MC_Date': _mcDateController.text,
          'Doctor': _doctorController.text,
        });

        // Clear the form fields after submission
        _nameController.clear();
        _appointmentDateController.clear();
        _appointmentServiceController.clear();
        _appointmentReasonController.clear();
        _mcDurationController.clear();
        _mcDateController.clear();
        _doctorController.clear();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Medical Certificate saved successfully')),
        );
      } catch (e) {
        // Show an error message if something goes wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Certificate Form',
          style: TextStyle(fontWeight: FontWeight.bold), // Make the text bold
        ),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFormField(_nameController, 'Name'),
              _buildTextFormField(
                  _appointmentDateController, 'Appointment Date'),
              _buildTextFormField(
                  _appointmentServiceController, 'Appointment Service'),
              _buildTextFormField(
                  _appointmentReasonController, 'Appointment Reason'),
              _buildTextFormField(_mcDurationController, 'MC Duration'),
              _buildTextFormField(_mcDateController, 'MC Date'),
              _buildTextFormField(_doctorController, 'Doctor'),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveMedicalCertificate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Button color
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white, // Text color
                      fontWeight: FontWeight.bold, // Bold text
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }
}
