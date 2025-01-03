import 'package:flutter/material.dart';

class MedicalCertificate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Certificate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Medical Certificate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Reason for MC'),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'MC Duration'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle save MC functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('MC Created Successfully')),
                );
                Navigator.pop(context); // Navigate back after saving
              },
              child: const Text('Save MC'),
            ),
          ],
        ),
      ),
    );
  }
}
