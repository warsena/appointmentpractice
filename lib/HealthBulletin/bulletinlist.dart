import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:appointmentpractice/HealthBulletin/updatebulletin.dart';

// Stateless widget for displaying a list of Health Bulletins
class BulletinList extends StatelessWidget {
  const BulletinList({Key? key}) : super(key: key);

  // Method to delete a bulletin from Firestore
  Future<void> _deleteBulletin(BuildContext context, String docId) async {
    // Show confirmation dialog before deleting
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Bulletin'), // Dialog title
        content: const Text('Are you sure you want to delete this bulletin?'), // Confirmation message
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          // Delete button
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Delete the document if confirmed
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('Health_Bulletin') // Specify the Firestore collection
          .doc(docId) // Reference the document by its ID
          .delete(); // Delete the document
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current date as a string in ISO 8601 format
    final String currentDate = DateTime.now().toIso8601String();

    return Scaffold(
      // App bar with title and custom background color
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Health Bulletins',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),

      // Main body with a gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          // Firestore query to retrieve active bulletins
          stream: FirebaseFirestore.instance
              .collection('Health_Bulletin') // Specify the Firestore collection
              .where('Bulletin_End_Date', isGreaterThan: currentDate) // Filter by end date (show active bulletin to user that why not retrieve by Bulletin_ID)
              .orderBy('Bulletin_End_Date', descending: false) // Order by ascending end date
              .snapshots(), // Get real-time updates
          builder: (context, snapshot) {
            // Show a loading spinner while the data is being fetched
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              );
            }

            // Show a message if no data is found
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off,
                        size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No active bulletins',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Retrieve and store the list of bulletins
            final bulletins = snapshot.data!.docs;

            // Build a list view to display bulletins
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bulletins.length,
              itemBuilder: (context, index) {
                // Extract bulletin data as a map
                final bulletin =
                    bulletins[index].data() as Map<String, dynamic>;
                final docId = bulletins[index].id; // Document ID
                final endDate = DateTime.parse(bulletin['Bulletin_End_Date']); // Parse end date

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section with title and action buttons
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Bulletin title
                            Expanded(
                              child: Text(
                                bulletin['Bulletin_Title'] ?? 'Untitled',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Edit and delete buttons
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.teal),
                                  onPressed: () {
                                    // Navigate to the update bulletin screen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateBulletin(bulletinId: docId),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteBulletin(context, docId),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Bulletin details section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bulletin description
                            Text(
                              bulletin['Bulletin_Description'] ?? 'No description',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // End date
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(endDate),
                                style: TextStyle(
                                  color: Colors.teal[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
