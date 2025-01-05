import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListMedicalCertificate extends StatefulWidget {
  const ListMedicalCertificate({super.key});

  @override
  State<ListMedicalCertificate> createState() => _ListMedicalCertificateState();
}

class _ListMedicalCertificateState extends State<ListMedicalCertificate> {
  // Initialize variables and controllers
  String? currentUserId;
  final TextEditingController _mcDurationController = TextEditingController();
  final TextEditingController _mcStartDateController = TextEditingController();
  final TextEditingController _mcEndDateController = TextEditingController();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Get current user's ID
  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  // Delete MC function
  Future<void> _deleteMC(String mcId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Medical_Certificate')
          .doc(mcId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medical Certificate deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting certificate: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show delete confirmation dialog
 Future<void> _showDeleteConfirmation(String mcId) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning_rounded, // Changed to rounded warning icon
              color: Color(0xFFDC2626), // Warmer red color
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Confirm Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this Medical Certificate? This action cannot be undone.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4B5563),
            height: 1.5,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centers the buttons
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16), // Space between buttons
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteMC(mcId);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Color(0xFFFEE2E2), // Light red background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Color(0xFFDC2626), // Matching red color
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 16), // Added bottom padding
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      );
    },
  );
}

  // Show edit confirmation dialog
 Future<void> _showEditConfirmation(DocumentSnapshot doc) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.edit_note,
              color: Color(0xFF2196F3),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Confirm Edit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to edit this Medical Certificate?',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4B5563),
            height: 1.5,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        actions: [
          // Wrap actions in a Row with mainAxisAlignment
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // This centers the buttons
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16), // Add spacing between buttons
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _editMC(context, doc);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      );
    },
  );
}

  // Date picker function
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? selectedStartDate ?? DateTime.now()
          : selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
          _mcStartDateController.text = _formatDate(picked);
          _updateEndDate();
        } else {
          selectedEndDate = picked;
          _mcEndDateController.text = _formatDate(picked);
          if (selectedStartDate != null) {
            int duration =
                selectedEndDate!.difference(selectedStartDate!).inDays + 1;
            _mcDurationController.text = duration.toString();
          }
        }
      });
    }
  }

  // Format date to string
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Update end date based on duration
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

  // Helper widget to build section titles in the edit dialog
  Widget _buildEditSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  // Helper widget to build read-only information rows in the edit dialog
  Widget _buildEditInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Edit MC function with enhanced UI
  Future<void> _editMC(BuildContext context, DocumentSnapshot doc) async {
    // Get the current data from the document
    final data = doc.data() as Map<String, dynamic>;

    // Initialize the controllers with current values
    _mcDurationController.text = data['MC_Duration'].toString();
    _mcStartDateController.text = data['MC_Start_Date'];
    _mcEndDateController.text = data['MC_End_Date'];

    // Parse the dates for date picker
    selectedStartDate = DateTime.parse(data['MC_Start_Date']);
    selectedEndDate = DateTime.parse(data['MC_End_Date']);

    // Show the edit dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // In the _editMC method, update the Dialog widget:
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width - 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header - Removed the close (x) button
                const Padding(
                  padding: EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Text(
                    'Edit Medical Certificate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Patient information section
                        _buildEditSectionTitle('Patient Information'),
                        _buildEditInfoRow(
                            'Patient Name', data['User_Name'] ?? 'Unknown'),
                        const SizedBox(height: 12), // Reduced spacing

                        // Appointment information section
                        _buildEditSectionTitle('Appointment Details'),
                        _buildEditInfoRow(
                            'Service', data['Appointment_Service'] ?? 'N/A'),
                        _buildEditInfoRow('Appointment Date',
                            data['Appointment_Date'] ?? 'N/A'),
                        _buildEditInfoRow('Appointment Time',
                            data['Appointment_Time'] ?? 'N/A'),
                        const SizedBox(height: 12),

                        // MC Duration input field
                        _buildEditSectionTitle('Medical Certificate Details'),
                        TextField(
                          controller: _mcDurationController,
                          decoration: InputDecoration(
                            labelText: 'Duration (Days)',
                            prefixIcon:
                                const Icon(Icons.timer, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _updateEndDate(),
                        ),
                        const SizedBox(height: 12),

                        // Date fields
                        TextField(
                          controller: _mcStartDateController,
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            prefixIcon: const Icon(Icons.calendar_today,
                                color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, true),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _mcEndDateController,
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            prefixIcon: const Icon(Icons.calendar_today,
                                color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, false),
                        ),
                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: Colors.blue),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('Medical_Certificate')
                                        .doc(doc.id)
                                        .update({
                                      'MC_Duration': _mcDurationController.text,
                                      'MC_Start_Date':
                                          _mcStartDateController.text,
                                      'MC_End_Date': _mcEndDateController.text,
                                    });
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Medical Certificate updated successfully'),
                                        backgroundColor: Colors.grey,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Error updating certificate: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Certificates',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Medical_Certificate')
                  .where('User_ID', isEqualTo: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No medical certificates found.'));
                }

                // Build list of medical certificates
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // In the ListView.builder, update the Card widget:
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ExpansionTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MC for ${data['User_Name'] ?? 'Unknown'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // Handle long names
                                ),
                                Text(
                                  'Date: ${data['MC_Start_Date']} to ${data['MC_End_Date']}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            trailing: SizedBox(
                              width: 96, // Fixed width for buttons
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 20, color: Colors.blue),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: () => _showEditConfirmation(doc),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 20, color: Colors.red),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: () =>
                                        _showDeleteConfirmation(doc.id),
                                  ),
                                ],
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow('Duration',
                                        '${data['MC_Duration']} days'),
                                    _buildInfoRow(
                                        'Doctor', data['Doctor_Name'] ?? 'N/A'),
                                    _buildInfoRow('Service',
                                        data['Appointment_Service'] ?? 'N/A'),
                                    _buildInfoRow('Reason',
                                        data['Appointment_Reason'] ?? 'N/A'),
                                    _buildInfoRow('Appointment Date',
                                        data['Appointment_Date'] ?? 'N/A'),
                                    _buildInfoRow('Appointment Time',
                                        data['Appointment_Time'] ?? 'N/A'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Helper widget to build info rows in the list view
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mcDurationController.dispose();
    _mcStartDateController.dispose();
    _mcEndDateController.dispose();
    super.dispose();
  }
}
