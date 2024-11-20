import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Main widget to update the bulletin
class UpdateBulletin extends StatefulWidget {
  final String bulletinId;  // ID of the bulletin being updated

  const UpdateBulletin({Key? key, required this.bulletinId}) : super(key: key);

  @override
  State<UpdateBulletin> createState() => _UpdateBulletinState();
}

class _UpdateBulletinState extends State<UpdateBulletin> {
  final _formKey = GlobalKey<FormState>();  // Key for form validation
  final TextEditingController _titleController = TextEditingController();  // Controller for title input
  final TextEditingController _descriptionController = TextEditingController();  // Controller for description input

  DateTime? _startDate;  // Store the selected start date
  DateTime? _endDate;  // Store the selected end date
  bool _isLoading = true;  // Loading state to show a loading spinner while fetching data

  @override
  void initState() {
    super.initState();
    _loadBulletinData();  // Fetch the bulletin data on initialization
  }

  // Load the data of the bulletin from Firestore
  Future<void> _loadBulletinData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Health_Bulletin')
          .doc(widget.bulletinId)
          .get();

      if (doc.exists) {
        setState(() {
          _titleController.text = doc['Bulletin_Title'];  // Set the title from Firestore
          _descriptionController.text = doc['Bulletin_Description'];  // Set the description from Firestore
          _startDate = DateTime.parse(doc['Bulletin_Start_Date']);  // Parse and set the start date
          _endDate = DateTime.parse(doc['Bulletin_End_Date']);  // Parse and set the end date
          _isLoading = false;  // Stop loading once the data is fetched
        });
      } else {
        _showErrorMessage('Bulletin not found');  // Show error if bulletin doesn't exist
        Navigator.pop(context);  // Go back to the previous screen
      }
    } catch (e) {
      _showErrorMessage('Error loading bulletin: $e');  // Handle any errors
    }
  }

  // Show a date picker for selecting the start or end date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),  // Default to current date
      firstDate: DateTime(2000),  // Allow dates from the year 2000
      lastDate: DateTime(2100),  // Allow dates up to the year 2100
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,  // Custom color for the date picker
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,  // Set background color of the dialog
          ),
          child: child!,  // Return the date picker child widget
        );
      },
    );

    // If a date is selected, update the respective start or end date
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;  // Set start date
        } else {
          _endDate = pickedDate;  // Set end date
        }
      });
    }
  }

  // Update the bulletin data in Firestore
  Future<void> _updateBulletin() async {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Health_Bulletin')
            .doc(widget.bulletinId)
            .update({
          'Bulletin_Title': _titleController.text,  // Update title
          'Bulletin_Description': _descriptionController.text,  // Update description
          'Bulletin_Start_Date': _startDate!.toIso8601String(),  // Update start date
          'Bulletin_End_Date': _endDate!.toIso8601String(),  // Update end date
        });

        _showSuccessMessage('Bulletin updated successfully');  // Show success message
        Navigator.pop(context);  // Go back to the previous screen
      } catch (e) {
        _showErrorMessage('Error updating bulletin: $e');  // Handle update errors
      }
    }
  }

  // Show a success message using a SnackBar
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blueGrey),  // Green background for success
    );
  }

  // Show an error message using a SnackBar
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),  // Red background for errors
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Bulletin', style: TextStyle(fontWeight: FontWeight.bold)),  // AppBar title
        backgroundColor: Colors.teal,  // AppBar background color
        elevation: 0,  // Remove shadow from AppBar
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))  // Show a loading spinner while fetching data
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),  // Padding around the content
              child: Card(
                elevation: 4,  // Card shadow elevation
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),  // Rounded corners for the card
                child: Padding(
                  padding: const EdgeInsets.all(16.0),  // Padding inside the card
                  child: Form(
                    key: _formKey,  // Set form key for validation
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,  // Stretch content to full width
                      children: [
                        // Title input field
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',  // Label text
                            prefixIcon: const Icon(Icons.title, color: Colors.teal),  // Icon before the input
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),  // Border style
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.teal, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a title'  // Validation message
                              : null,
                        ),
                        const SizedBox(height: 16.0),  // Spacing
                        // Description input field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: const Icon(Icons.description, color: Colors.teal),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.teal, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          maxLines: 3,  // Multi-line description
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a description'  // Validation message
                              : null,
                        ),
                        const SizedBox(height: 16.0),
                        // Start Date selection row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),  // Border for the date picker field
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.calendar_today, color: Colors.teal),  // Calendar icon
                                  title: Text(
                                    _startDate == null
                                        ? 'Start Date'  // Placeholder text if no date selected
                                        : _startDate!.toLocal().toString().split(' ')[0],  // Format selected date
                                    style: TextStyle(
                                      color: _startDate == null ? Colors.grey : Colors.black,  // Change text color if no date selected
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit_calendar, color: Colors.teal),  // Edit icon to trigger date picker
                                    onPressed: () => _selectDate(context, true),  // Call date picker for start date
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),  // Spacing
                        // End Date selection row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.calendar_today, color: Colors.teal),
                                  title: Text(
                                    _endDate == null
                                        ? 'End Date'  // Placeholder text if no date selected
                                        : _endDate!.toLocal().toString().split(' ')[0],  // Format selected date
                                    style: TextStyle(
                                      color: _endDate == null ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit_calendar, color: Colors.teal),
                                    onPressed: () => _selectDate(context, false),  // Call date picker for end date
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        // Update button to save changes
                        ElevatedButton(
                          onPressed: _updateBulletin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Update Bulletin',  // Button text
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
    _titleController.dispose();  // Dispose the controller for title
    _descriptionController.dispose();  // Dispose the controller for description
    super.dispose();
  }
}
