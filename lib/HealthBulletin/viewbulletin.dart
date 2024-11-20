import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewBulletin extends StatefulWidget {
  final String bulletinId; // Bulletin_ID passed to the screen

  const ViewBulletin({Key? key, required this.bulletinId}) : super(key: key);

  @override
  State<ViewBulletin> createState() => _ViewBulletinState();
}

class _ViewBulletinState extends State<ViewBulletin> {
  late Future<Map<String, dynamic>?> _bulletinFuture;

  @override
  void initState() {
    super.initState();
    _bulletinFuture = _fetchBulletin(); // Fetch bulletin on initialization
  }

  Future<Map<String, dynamic>?> _fetchBulletin() async {
    try {
      // Retrieve document from Firestore based on Bulletin_ID
      final doc = await FirebaseFirestore.instance
          .collection('Health_Bulletin')
          .doc(widget.bulletinId)
          .get();

      if (doc.exists) {
        return doc.data(); // Return the data if document exists
      } else {
        return null; // Return null if document doesn't exist
      }
    } catch (e) {
      debugPrint('Error fetching bulletin: $e');
      return null; // Return null on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Bulletin'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _bulletinFuture, // Use FutureBuilder to handle async fetch
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading spinner while waiting
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          } else if (snapshot.hasError) {
            // Handle any errors
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            // Show message if no data is found
            return const Center(
              child: Text('Bulletin not found'),
            );
          }

          // Extract bulletin data
          final data = snapshot.data!;
          final title = data['Bulletin_Title'] ?? 'No Title';
          final description = data['Bulletin_Description'] ?? 'No Description';
          final startDate = data['Bulletin_Start_Date'] ?? 'N/A';
          final endDate = data['Bulletin_End_Date'] ?? 'N/A';

          // Display the bulletin details
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(startDate),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(endDate),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to the previous screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
