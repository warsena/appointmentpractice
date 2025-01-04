import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalCertificate extends StatefulWidget {
  final String appointmentDate;
  final String appointmentService;
  final String appointmentTime;
  final String appointmentReason;
  final String userName;

  MedicalCertificate({
    required this.appointmentDate,
    required this.appointmentService,
    required this.appointmentTime,
    required this.appointmentReason,
    required this.userName,
  });

  @override
  _MedicalCertificateState createState() => _MedicalCertificateState();
}

class _MedicalCertificateState extends State<MedicalCertificate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _appointmentDateController = TextEditingController();
  final TextEditingController _appointmentTimeController = TextEditingController();
  final TextEditingController _appointmentServiceController = TextEditingController();
  final TextEditingController _appointmentReasonController = TextEditingController();
  final TextEditingController _mcDurationController = TextEditingController();
  final TextEditingController _mcDateController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController(); // Doctor's Name

  String? currentUserId;
  String? doctorName; // Store the doctor's name
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _getCurrentUser();
  }

  void _initializeFields() {
    _nameController.text = widget.userName;
    _appointmentDateController.text = widget.appointmentDate;
    _appointmentTimeController.text = widget.appointmentTime;
    _appointmentServiceController.text = widget.appointmentService;
    _appointmentReasonController.text = widget.appointmentReason;
  }

  Future<void> _getCurrentUser() async {
    setState(() => isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        currentUserId = user.uid;
        await _fetchDoctorDetails(user.uid);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchDoctorDetails(String userId) async {
    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(userId)
          .get();

      if (doctorDoc.exists) {
        var doctorData = doctorDoc.data() as Map<String, dynamic>;
        if (doctorData['User_Type'] == 'Doctor') {
          setState(() {
            doctorName = doctorData['User_Name']; // Set the doctor's name
            _doctorController.text = doctorName ?? ''; // Populate the text field
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching doctor details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Certificate',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle('Patient Information'),
                        _buildReadOnlyField(_nameController, 'Name', Icons.person),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Appointment Details'),
                        _buildReadOnlyField(_appointmentDateController, 'Appointment Date', Icons.calendar_today),
                        _buildReadOnlyField(_appointmentTimeController, 'Appointment Time', Icons.access_time),
                        _buildReadOnlyField(_appointmentServiceController, 'Service', Icons.medical_services),
                        _buildReadOnlyField(_appointmentReasonController, 'Reason', Icons.description),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Medical Certificate Details'),
                        _buildTextField(_mcDurationController, 'Duration (Days)', Icons.timer),
                        _buildTextField(_mcDateController, 'MC Date', Icons.event),
                        _buildTextField(_doctorController, 'Doctor\'s Name', Icons.person_outline, readOnly: true),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveMedicalCertificate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the $label';
          }
          if (label == 'Duration (Days)') {
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number of days';
            }
          }
          return null;
        },
      ),
    );
  }

  Future<void> _saveMedicalCertificate() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance.collection('MedicalCertificate').add({
          'User_ID': currentUserId,
          'Doctor_Name': _doctorController.text,
          'Appointment_Date': widget.appointmentDate,
          'Appointment_Service': widget.appointmentService,
          'Appointment_Time': widget.appointmentTime,
          'Reason': widget.appointmentReason,
          'Duration': _mcDurationController.text,
          'MC_Date': _mcDateController.text,
          'Created_At': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical Certificate saved successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving certificate: $e')),
        );
      }
    }
  }
}
