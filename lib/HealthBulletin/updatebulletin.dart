import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Updatebulletin extends StatefulWidget {
  const Updatebulletin({super.key});

  @override
  State<Updatebulletin> createState() => _UpdatebulletinState();
}

class _UpdatebulletinState extends State<Updatebulletin> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _dateStartController.dispose();
    _dateEndController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Health Bulletin'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Title:'),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter Title',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Date Start:'),
            TextField(
              controller: _dateStartController,
              decoration: InputDecoration(
                hintText: 'Select start date',
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context, _dateStartController);
                  },
                ),
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _dateStartController),
            ),
            const SizedBox(height: 16),
            const Text('Date End:'),
            TextField(
              controller: _dateEndController,
              decoration: InputDecoration(
                hintText: 'Select end date',
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context, _dateEndController);
                  },
                ),
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _dateEndController),
            ),
            const SizedBox(height: 16),
            const Text('File Name:'),
            TextField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                hintText: 'stress.pdf',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Turquoise color
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onPressed: () {
                    // Handle the create action here
                    final title = _titleController.text;
                    final dateStart = _dateStartController.text;
                    final dateEnd = _dateEndController.text;
                    final fileName = _fileNameController.text;

                    // Print or save data as needed
                    print('Title: $title');
                    print('Date Start: $dateStart');
                    print('Date End: $dateEnd');
                    print('File Name: $fileName');
                  },
                  child: const Text(
                    'Update', //admin update bulletin info
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white, // White text color
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
