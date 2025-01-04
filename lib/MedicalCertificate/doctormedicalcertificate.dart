import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalCertificate extends StatefulWidget {
  final String appointmentDate;
  final String appointmentService;
  final String appointmentTime;
  final String appointmentReason;
  final String? userName;

  const MedicalCertificate({
    Key? key,
    required this.appointmentDate,
    required this.appointmentService,
    required this.appointmentTime,
    required this.appointmentReason,
    required this.userName,
  }) : super(key: key);

  @override
  _MedicalCertificateState createState() => _MedicalCertificateState();
}

class _MedicalCertificateState extends State<MedicalCertificate> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _mcDurationController = TextEditingController();
  final TextEditingController _mcStartDateController = TextEditingController();
  final TextEditingController _mcEndDateController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();

  String? currentUserId;
  String? doctorName;
  bool isLoading = true;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _mcDurationController.addListener(_updateEndDate);
    _mcStartDateController.addListener(_updateEndDate);
  }

  // Show success dialog
  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Success'),
            ],
          ),
          content: const Text('Medical Certificate has been successfully created.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
            ),
          ],
        );
      },
    );
  }

  void _updateEndDate() {
    if (selectedStartDate != null && _mcDurationController.text.isNotEmpty) {
      try {
        int duration = int.parse(_mcDurationController.text);
        selectedEndDate = selectedStartDate!.add(Duration(days: duration - 1));
        _mcEndDateController.text = _formatDate(selectedEndDate!);
      } catch (e) {
        print('Invalid duration input: $e');
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
            doctorName = doctorData['User_Name'];
            _doctorController.text = doctorName ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching doctor details: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (selectedStartDate ?? DateTime.now()) : (selectedEndDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime date) {
        if (!isStartDate && selectedStartDate != null) {
          return date.isAfter(selectedStartDate!) || date.isAtSameMomentAs(selectedStartDate!);
        }
        return true;
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
          _mcStartDateController.text = _formatDate(picked);
          if (selectedEndDate != null && picked.isAfter(selectedEndDate!)) {
            selectedEndDate = null;
            _mcEndDateController.text = '';
          }
          _updateEndDate();
        } else {
          selectedEndDate = picked;
          _mcEndDateController.text = _formatDate(picked);
          if (selectedStartDate != null) {
            int duration = selectedEndDate!.difference(selectedStartDate!).inDays + 1;
            _mcDurationController.text = duration.toString();
          }
        }
      });
    }
  }

 Future<void> _saveMedicalCertificate() async {
  if (_formKey.currentState?.validate() ?? false) {
    try {
      // Ensure the user is logged in and `currentUserId` is set
      if (currentUserId == null) {
        throw 'User is not logged in';
      }

      final docRef = FirebaseFirestore.instance.collection('Medical_Certificate').doc();
      final mcId = docRef.id;

      // Save the medical certificate document with User_ID
      await docRef.set({
        'MC_ID': mcId,
        'User_ID': currentUserId,  // Add User_ID to the document
        'Doctor_Name': _doctorController.text,
        'User_Name': widget.userName,
        'Appointment_Date': widget.appointmentDate,
        'Appointment_Service': widget.appointmentService,
        'Appointment_Time': widget.appointmentTime,
        'Appointment_Reason': widget.appointmentReason,
        'MC_Duration': _mcDurationController.text,
        'MC_Start_Date': _mcStartDateController.text,
        'MC_End_Date': _mcEndDateController.text,
        'Created_At': FieldValue.serverTimestamp(),
      });

      await _showSuccessDialog();  // Show success dialog instead of SnackBar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving certificate: $e')),
      );
    }
  }
}


  // [Rest of the widget building methods remain the same...]
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

  Widget _buildReadOnlyField(String value, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePickerField(bool isStartDate) {
    final controller = isStartDate ? _mcStartDateController : _mcEndDateController;
    final label = isStartDate ? 'MC Start Date' : 'MC End Date';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context, isStartDate),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select the $label';
          }
          return null;
        },
        onTap: () => _selectDate(context, isStartDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Certificate',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                        _buildReadOnlyField(
                          widget.userName ?? 'Unknown',
                          'Name',
                          Icons.person,
                        ),
                      
                        const SizedBox(height: 16),

                        _buildSectionTitle('Appointment Details'),
                        _buildReadOnlyField(widget.appointmentDate, 'Appointment Date', Icons.calendar_today),
                        _buildReadOnlyField(widget.appointmentTime, 'Appointment Time', Icons.access_time),
                        _buildReadOnlyField(widget.appointmentService, 'Service', Icons.medical_services),
                        _buildReadOnlyField(widget.appointmentReason, 'Reason', Icons.description),

                        const SizedBox(height: 16),

                        _buildSectionTitle('Medical Certificate Details'),
                        _buildTextField(
                          _mcDurationController,
                          'Duration (Days)',
                          Icons.timer,
                          keyboardType: TextInputType.number,
                        ),
                        _buildDatePickerField(true),
                        _buildDatePickerField(false),
                        _buildTextField(
                          _doctorController,
                          'Doctor\'s Name',
                          Icons.person_outline,
                          readOnly: true,
                        ),

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

  @override
  void dispose() {
    _mcDurationController.removeListener(_updateEndDate);
    _mcDurationController.dispose();
    _mcStartDateController.dispose();
    _mcEndDateController.dispose();
    _doctorController.dispose();
    super.dispose();
  }
}