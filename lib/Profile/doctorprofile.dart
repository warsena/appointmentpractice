import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointmentpractice/Profile/usereditprofile.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
   final FirebaseAuth _auth = FirebaseAuth.instance;
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Map<String, dynamic>? _userData;

   @override
   void initState() {
     super.initState();
     _fetchUserData();
   }

   Future<void> _fetchUserData() async {
     try {
       User? currentUser = _auth.currentUser;
       if (currentUser != null) {
         DocumentSnapshot userSnapshot =
             await _firestore.collection('User').doc(currentUser.uid).get();

         if (userSnapshot.exists) {
           setState(() {
             _userData = userSnapshot.data() as Map<String, dynamic>;
           });
         }
       }
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error fetching user data: $e')),
       );
     }
   }

   Widget _buildInfoCard(String label, String value, IconData icon) {
     return Container(
       margin: const EdgeInsets.symmetric(vertical: 6),
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(10),
         boxShadow: [
           BoxShadow(
             color: Colors.grey.withOpacity(0.1),
             spreadRadius: 1,
             blurRadius: 3,
             offset: const Offset(0, 2),
           ),
         ],
       ),
       child: Row(
         children: [
           Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: const Color.fromRGBO(37, 163, 255, 0.1), // Blue with opacity
               borderRadius: BorderRadius.circular(8),
             ),
             child: Icon(icon, color: const Color.fromRGBO(37, 163, 255, 1), size: 20), // Blue icon
           ),
           const SizedBox(width: 12),
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 label,
                 style: const TextStyle(
                   fontWeight: FontWeight.w500,
                   color: Color.fromRGBO(37, 163, 255, 1), // Blue text
                   fontSize: 14,
                 ),
               ),
               const SizedBox(height: 4),
               Text(
                 value,
                 style: const TextStyle(
                   fontSize: 15,
                   fontWeight: FontWeight.w500,
                   color: Colors.black87,
                 ),
               ),
             ],
           ),
         ],
       ),
     );
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.grey[50],
       appBar: AppBar(
         title: const Text(
           'Doctor Profile',
           style: TextStyle(fontWeight: FontWeight.bold),
         ),
         backgroundColor: const Color.fromRGBO(37, 163, 255, 1),
         elevation: 0,
       ),
       body: _userData == null
           ? const Center(child: CircularProgressIndicator())
           : SingleChildScrollView(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 children: [
                   const SizedBox(height: 8),
                   _buildInfoCard('Name', _userData!['User_Name'], Icons.person),
                   _buildInfoCard('Email', _userData!['User_Email'], Icons.email),
                   _buildInfoCard('Contact', _userData!['User_Contact'], Icons.phone),
                   _buildInfoCard('Gender', _userData!['User_Gender'], Icons.people),
                   _buildInfoCard('User Type', _userData!['User_Type'], Icons.school),
                   _buildInfoCard('Selected Service', _userData!['Selected_Service'], Icons.work),
                   _buildInfoCard('Campus', _userData!['Campus'], Icons.location_city),
                   const SizedBox(height: 16),
                   ElevatedButton.icon(
                     onPressed: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => const UserEditProfile(),
                         ),
                       );
                     },
                     icon: const Icon(Icons.edit),
                     label: const Text('Edit Profile'),
                     style: ElevatedButton.styleFrom(
                       foregroundColor: Colors.white,
                       backgroundColor: const Color.fromRGBO(37, 163, 255, 1), // Blue button
                       padding: const EdgeInsets.symmetric(
                         horizontal: 24,
                         vertical: 12,
                       ),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(10),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
     );
   }
}