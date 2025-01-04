import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserMedicalCertificate extends StatefulWidget {
  final String mcId; // Medical Certificate ID passed to the widget

  const UserMedicalCertificate({Key? key, required this.mcId}) : super(key: key);

  @override
  _UserMedicalCertificateState createState() => _UserMedicalCertificateState();
}

class _UserMedicalCertificateState extends State<UserMedicalCertificate> {
  bool isLoading = true;
  Map<String, dynamic>? certificateData;

  @override
  void initState() {
    super.initState();
    _fetchCertificateData();
  }

  // Fetch the certificate data from Firestore based on the MC_ID
  Future<void> _fetchCertificateData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Medical_Certificate')
          .doc(widget.mcId) // Use the MC_ID passed from the widget
          .get();

      if (docSnapshot.exists) {
        setState(() {
          certificateData = docSnapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        // Handle the case where no certificate is found
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical certificate not found.')),
        );
      }
    } catch (e) {
      // Handle any errors
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching certificate: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Certificate'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : certificateData == null
              ? const Center(child: Text('No data available.')) // Show if no data
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient Name: ${certificateData!['User_Name']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doctor: ${certificateData!['Doctor_Name']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Appointment Date: ${certificateData!['Appointment_Date']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Appointment Time: ${certificateData!['Appointment_Time']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Service: ${certificateData!['Appointment_Service']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reason: ${certificateData!['Appointment_Reason']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duration: ${certificateData!['MC_Duration']} days',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MC Start Date: ${certificateData!['MC_Start_Date']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MC End Date: ${certificateData!['MC_End_Date']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
    );
  }
}
