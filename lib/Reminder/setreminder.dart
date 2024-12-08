import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetReminder extends StatefulWidget {
  final Map appointment;

  const SetReminder({Key? key, required this.appointment}) : super(key: key);

  @override
  State<SetReminder> createState() => _SetReminderState();
}

class _SetReminderState extends State<SetReminder> {
  String? selectedReminder;
  bool isLoading = false;

  Future<void> _saveReminder() async {
    if (selectedReminder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reminder option'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Generate a unique document reference
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('Reminder').doc();

      await docRef.set({
        'Reminder_ID': docRef.id, // Use the document ID as Reminder_ID
        'Reminder_Type': selectedReminder,
        'Appointment_ID': widget.appointment['Appointment_ID'],
        'Created_At': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder saved successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving reminder: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set Reminder',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal, // Set background color of the AppBar here
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
              16.0), // Reduce padding to fit mobile screens
          child: SingleChildScrollView(
            // To ensure the layout works for smaller screens
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        20.0), // Increased padding for spacing
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'When would you like to be reminded?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: selectedReminder,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                            ),
                            hint: const Text('Select reminder time'),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'On day appointment',
                                child: Text('On the day of appointment'),
                              ),
                              DropdownMenuItem(
                                value: '1 Day Before',
                                child: Text('1 day before'),
                              ),
                              DropdownMenuItem(
                                value: '3 Day Before',
                                child: Text('3 days before'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => selectedReminder = value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.teal, // Use backgroundColor instead of primary
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Reminder',
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
        ),
      ),
    );
  }
}
