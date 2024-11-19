import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BulletinList extends StatelessWidget {
  const BulletinList({Key? key}) : super(key: key);

  // Function to delete a bulletin
  Future<void> _deleteBulletin(BuildContext context, String docId, String bulletinId) async {
    print('Attempting to delete document with ID: $docId or Bulletin_ID: $bulletinId');

    // Confirmation dialog before deleting the bulletin
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded dialog box
        title: const Text('Delete Bulletin'), // Title of the dialog
        content: const Text('Are you sure you want to delete this bulletin?'), // Dialog content
        actions: [
          // Cancel button to dismiss the dialog
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Close dialog with 'false'
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          // Delete button to confirm deletion
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Close dialog with 'true'
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // If the user confirms deletion
    if (confirm == true) {
      try {
        // Attempt to delete the document using the Firestore document ID
        await FirebaseFirestore.instance.collection('Health_Bulletin').doc(docId).delete();
        print('Document with ID: $docId deleted successfully');

        // Show success dialog to the user
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text('Success'),
            content: const Text('Bulletin deleted successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close the dialog
                child: const Text('OK', style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
        );
      } catch (e) {
        print('Error deleting by docId: $e');

        // If deletion by docId fails, try deleting using Bulletin_ID
        try {
          final query = await FirebaseFirestore.instance
              .collection('Health_Bulletin')
              .where('Bulletin_ID', isEqualTo: bulletinId) // Filter by Bulletin_ID
              .get();

          // Delete all matching documents
          for (var doc in query.docs) {
            await doc.reference.delete();
            print('Document with Bulletin_ID: $bulletinId deleted successfully');
          }

          // Show success dialog to the user
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text('Success'),
              content: const Text('Bulletin deleted successfully.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Close the dialog
                  child: const Text('OK', style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),
          );
        } catch (e) {
          print('Error deleting by Bulletin_ID: $e');
        }
      }
    } else {
      print('Delete operation cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current date in ISO format to compare with Bulletin_End_Date
    final String currentDate = DateTime.now().toIso8601String();

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // Remove shadow under the app bar
        title: const Text(
          'Health Bulletins',
          style: TextStyle(fontWeight: FontWeight.bold), // Bold app bar title
        ),
        backgroundColor: Colors.teal, // Teal background color for the app bar
      ),
      body: Container(
        decoration: BoxDecoration(
          // Gradient background for the page
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white], // Light teal to white gradient
          ),
        ),
        // StreamBuilder to listen to Firestore updates in real-time
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Health_Bulletin') // Target the Health_Bulletin collection
              .where('Bulletin_End_Date', isGreaterThan: currentDate) // Filter future bulletins
              .orderBy('Bulletin_End_Date', descending: false) // Order by end date
              .snapshots(),
          builder: (context, snapshot) {
            // Show loading indicator while waiting for data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              );
            }

            // Show "No active bulletins" if no data is found
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 60, color: Colors.grey[400]), // No bulletins icon
                    const SizedBox(height: 16), // Spacing
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

            // Get the list of bulletins from Firestore
            final bulletins = snapshot.data!.docs;

            // Render a list of bulletins
            return ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: bulletins.length, // Total number of bulletins
  itemBuilder: (context, index) {
    final bulletin = bulletins[index].data() as Map<String, dynamic>;
    final docId = bulletins[index].id; // Firestore document ID
    final bulletinId = bulletin['Bulletin_ID']; // Get Bulletin_ID

    // Debugging to ensure data is present
    print('Bulletin Data: $bulletin');
    print('Bulletin_ID: $bulletinId');

    // Parse the end date safely
    final endDate = DateTime.parse(bulletin['Bulletin_End_Date']);

    return Card(
      elevation: 3, // Shadow for the card
      margin: const EdgeInsets.only(bottom: 16), // Spacing between cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners for the card
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section with delete/edit actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50, // Light teal background for the title
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
                // Edit and Delete buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.teal),
                      onPressed: () {
                        // Add your edit navigation here
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Ensure Bulletin_ID is valid before deleting
                        if (bulletinId != null) {
                          _deleteBulletin(context, docId, bulletinId);
                        } else {
                          print('Bulletin_ID is null or invalid');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bulletin description and end date
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  bulletin['Bulletin_Description'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8), // Spacing
                // End date display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50, // Background for date
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(endDate), // Format end date
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
          }