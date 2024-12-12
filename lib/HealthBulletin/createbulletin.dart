import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Stateful widget for creating a health bulletin
class CreateBulletin extends StatefulWidget {
  const CreateBulletin({Key? key}) : super(key: key);

  @override
  State<CreateBulletin> createState() => _CreateBulletinState();
}

class _CreateBulletinState extends State<CreateBulletin> {
  // Global key for form validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for title and description input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Variables to store selected start and end dates
  DateTime? _startDate;
  DateTime? _endDate;

  // Method to show date picker and select start or end date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    // Show date picker with custom styling
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      // Initial date set to current date
      initialDate: DateTime.now(),
      // Allowed date range from year 2000 to 2100
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      // Custom theming for date picker
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            // Custom color scheme for date picker
            colorScheme: const ColorScheme.light(
              primary: Colors.teal, // Accent color
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    // Update state with selected date
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  // Method to create and submit bulletin to Firestore
  Future<void> _createBulletin() async {
    // Validate form and ensure dates are selected
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      try {
        // Generate a unique ID for the bulletin
        final bulletinId =
            FirebaseFirestore.instance.collection('Health_Bulletin').doc().id;

        // Add bulletin data to Firestore collection
        await FirebaseFirestore.instance
            .collection('Health_Bulletin')
            .doc(bulletinId)
            .set({
          'Bulletin_ID': bulletinId, // Store the unique ID
          'Bulletin_Title': _titleController.text,
          'Bulletin_Description': _descriptionController.text,
          // Convert dates to ISO 8601 string format for storage
          'Bulletin_Start_Date': _startDate!.toIso8601String(),
          'Bulletin_End_Date': _endDate!.toIso8601String(),
        });

        // Show success message with custom styling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bulletin created successfully!'),
            backgroundColor: Colors.blueGrey,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Reset form and clear input fields
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _startDate = null;
          _endDate = null;
        });
      } catch (e) {
        // Show error message if bulletin creation fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create bulletin: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light background color for overall screen
      backgroundColor: Colors.grey[100],

      // App bar with custom styling
      appBar: AppBar(
        title: const Text(
          'Create Bulletin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 100, 200, 185),
        elevation: 0,
      ),

      // Scrollable body to handle smaller screen sizes
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Card widget to create a card-like container for form
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // Form with validation
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title input field with custom decoration
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        prefixIcon: const Icon(Icons.title, color: Colors.teal),
                        // Outlined border with rounded corners
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // Focused border with teal color
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Validator to ensure title is not empty
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Description input field with custom decoration
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon:
                            const Icon(Icons.description, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 3, // Allow multiple lines for description
                      // Validator to ensure description is not empty
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Start Date selection with custom styling
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today,
                                  color: Colors.teal),
                              title: Text(
                                // Display selected start date or placeholder
                                _startDate == null
                                    ? 'Start Date'
                                    : _startDate!
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0],
                                style: TextStyle(
                                  color: _startDate == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_calendar,
                                    color: Colors.teal),
                                onPressed: () => _selectDate(context, true),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // End Date selection with custom styling
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today,
                                  color: Colors.teal),
                              title: Text(
                                // Display selected end date or placeholder
                                _endDate == null
                                    ? 'End Date'
                                    : _endDate!
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0],
                                style: TextStyle(
                                  color: _endDate == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_calendar,
                                    color: Colors.teal),
                                onPressed: () => _selectDate(context, false),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Create Bulletin button with custom styling
                    ElevatedButton(
                      onPressed: _createBulletin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 100, 200, 185),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Create Bulletin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Set text color to white
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}