import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Main widget to update the bulletin
class UpdateBulletin extends StatefulWidget {
  final String docId; // ID of the bulletin being updated

  const UpdateBulletin({Key? key, required this.docId}) : super(key: key);

  @override
  State<UpdateBulletin> createState() => _UpdateBulletinState();
}

class _UpdateBulletinState extends State<UpdateBulletin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBulletinData(); // Use docId here
  }

  Future<void> _loadBulletinData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Health_Bulletin')
          .doc(widget.docId) // Use docId to fetch the bulletin
          .get();

      if (doc.exists) {
        setState(() {
          _titleController.text = doc['Bulletin_Title'];
          _imageUrlController.text = doc['Bulletin_Image_URL'];
          _startDate = DateTime.parse(doc['Bulletin_Start_Date']);
          _endDate = DateTime.parse(doc['Bulletin_End_Date']);
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
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

  Future<void> _updateBulletin() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Health_Bulletin')
            .doc(widget.docId) // Use docId to update the bulletin
            .update({
          'Bulletin_Title': _titleController.text,
          'Bulletin_Image_URL': _imageUrlController.text,
          'Bulletin_Start_Date': _startDate!.toIso8601String(),
          'Bulletin_End_Date': _endDate!.toIso8601String(),
        });

        _showSuccessMessage('Bulletin updated successfully');
        Navigator.pop(context);
      } catch (e) {
        _showErrorMessage('Error updating bulletin: $e');
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blueGrey),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Update Bulletin',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 100, 200, 185),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            prefixIcon:
                                const Icon(Icons.title, color: Colors.teal),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.teal, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a title'
                              : null,
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: InputDecoration(
                            labelText: 'Image URL',
                            prefixIcon: const Icon(Icons.description,
                                color: Colors.teal),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.teal, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          maxLines: 3,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a description'
                              : null,
                        ),
                        const SizedBox(height: 16.0),
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
                                    onPressed: () =>
                                        _selectDate(context, false),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        ElevatedButton(
                          onPressed: _updateBulletin,
                          child: const Text(
                            'Update Bulletin',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold, // Makes the text bold
                              color: Colors.black, // Makes the text white
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 100, 200, 185),// Background color of the button
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0), // Padding
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Button shape
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
}
