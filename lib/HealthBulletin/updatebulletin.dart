import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateBulletin extends StatefulWidget {
  // Unique identifier for the bulletin being updated
  final String bulletinId;

  const UpdateBulletin({Key? key, required this.bulletinId}) : super(key: key);

  @override
  State<UpdateBulletin> createState() => _UpdateBulletinState();
}

class _UpdateBulletinState extends State<UpdateBulletin> {
  // Global key for form validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for each input field
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Loading state to show progress indicator
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBulletinData();
  }

  // Fetch existing bulletin data from Firestore
  Future<void> _loadBulletinData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Health_Bulletin')
          .doc(widget.bulletinId)
          .get();
      
      if (doc.exists) {
        setState(() {
          // Populate text controllers with existing data
          _titleController.text = doc['Bulletin_Title'];
          _startDateController.text = doc['Bulletin_Start_Date'].split(' ')[0];
          _endDateController.text = doc['Bulletin_End_Date'].split(' ')[0];
          _descriptionController.text = doc['Bulletin_Description'];
          _isLoading = false;
        });
      } else {
        _showErrorMessage('Bulletin not found');
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorMessage('Error loading bulletin: $e');
    }
  }

  // Update bulletin data in Firestore
  Future<void> _updateBulletin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('Health_Bulletin')
            .doc(widget.bulletinId)
            .update({
          'Bulletin_Title': _titleController.text,
          'Bulletin_Start_Date': _startDateController.text,
          'Bulletin_End_Date': _endDateController.text,
          'Bulletin_Description': _descriptionController.text,
        });

        _showSuccessMessage('Bulletin updated successfully');
        Navigator.pop(context);
      } catch (e) {
        _showErrorMessage('Error updating bulletin: $e');
      }
    }
  }

  // Display success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Display error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Improved app bar with better styling
      appBar: AppBar(
        title: Text(
          'Update Bulletin', 
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      // Body with improved design
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
                strokeWidth: 4,
              ),
            )
          : GestureDetector(
              // Dismiss keyboard when tapping outside
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.deepPurple.shade50,
                      Colors.deepPurple.shade100,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title input with enhanced styling
                        _buildTextField(
                          controller: _titleController,
                          labelText: 'Bulletin Title',
                          prefixIcon: Icons.title,
                          validator: (value) => value == null || value.isEmpty 
                              ? 'Please enter the title' 
                              : null,
                        ),
                        const SizedBox(height: 20),
                        // Start date input
                        _buildTextField(
                          controller: _startDateController,
                          labelText: 'Start Date',
                          prefixIcon: Icons.calendar_today,
                          hintText: 'YYYY-MM-DD',
                          validator: (value) => value == null || value.isEmpty 
                              ? 'Please enter the start date' 
                              : null,
                        ),
                        const SizedBox(height: 20),
                        // End date input
                        _buildTextField(
                          controller: _endDateController,
                          labelText: 'End Date',
                          prefixIcon: Icons.calendar_month,
                          hintText: 'YYYY-MM-DD',
                          validator: (value) => value == null || value.isEmpty 
                              ? 'Please enter the end date' 
                              : null,
                        ),
                        const SizedBox(height: 20),
                        // Description input with multiple lines
                        _buildTextField(
                          controller: _descriptionController,
                          labelText: 'Bulletin Description',
                          prefixIcon: Icons.description,
                          maxLines: 5,
                          validator: (value) => value == null || value.isEmpty 
                              ? 'Please enter the description' 
                              : null,
                        ),
                        const SizedBox(height: 30),
                        // Update button with improved styling
                        ElevatedButton(
                          onPressed: _updateBulletin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Update Bulletin', 
                            style: TextStyle(
                              fontSize: 18,
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

  // Enhanced text field with consistent and attractive styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? prefixIcon,
    int? maxLines,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.deepPurple) : null,
        // Enhanced border and focus styling
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.deepPurple.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.deepPurple.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: Colors.deepPurple.shade900),
    );
  }
}