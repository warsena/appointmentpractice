import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserMedicalCertificate extends StatefulWidget {
  const UserMedicalCertificate({super.key});

  @override
  State<UserMedicalCertificate> createState() => _UserMedicalCertificateState();
}

class _UserMedicalCertificateState extends State<UserMedicalCertificate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  String? userName;
  Stream<QuerySnapshot>? _certificatesStream;
  String? errorMessage;
  bool isIndexBuilding = false;
  int retryCount = 0;
  static const maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      isIndexBuilding = false;
    });
    
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();
            
        if (userDoc.exists) {
          final name = (userDoc.data() as Map<String, dynamic>)['User_Name'];
          setState(() {
            userName = name;
            _initializeCertificatesStream(name);
          });
        } else {
          setState(() {
            errorMessage = 'User profile not found';
          });
        }
      } else {
        setState(() {
          errorMessage = 'No user logged in';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading user data: $e';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _initializeCertificatesStream(String name) {
    // First try without orderBy
    _certificatesStream = FirebaseFirestore.instance
        .collection('Medical_Certificate')
        .where('User_Name', isEqualTo: name)
        .snapshots()
        .handleError((error) {
          print('Stream error: $error');
          if (error.toString().contains('indexes?create_composite=')) {
            setState(() {
              isIndexBuilding = true;
              errorMessage = 'Database is being optimized. This may take a few minutes. You can still view your certificates below.';
            });
          } else {
            setState(() {
              errorMessage = 'Error loading certificates: $error';
            });
          }
          return Stream.error(error);
        });
  }

  Future<void> _retryWithOrderBy(String name) async {
    try {
      // Try the query with orderBy
      await FirebaseFirestore.instance
          .collection('Medical_Certificate')
          .where('User_Name', isEqualTo: name)
          .orderBy('Created_At', descending: true)
          .limit(1)
          .get();

      // If successful, update the stream
      setState(() {
        _certificatesStream = FirebaseFirestore.instance
            .collection('Medical_Certificate')
            .where('User_Name', isEqualTo: name)
            .orderBy('Created_At', descending: true)
            .snapshots();
        isIndexBuilding = false;
        errorMessage = null;
      });
    } catch (e) {
      if (e.toString().contains('indexes?create_composite=')) {
        if (retryCount < maxRetries) {
          retryCount++;
          Future.delayed(Duration(seconds: 30), () => _retryWithOrderBy(name));
        }
      }
    }
  }

  Widget _buildMCCard(DocumentSnapshot document) {
    try {
      final data = document.data() as Map<String, dynamic>;
      String documentId = document.id;
      
      return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'MC #${documentId.length >= 6 ? documentId.substring(0, 6) : documentId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data['MC_Duration']?.toString() != null 
                          ? '${data['MC_Duration']} days'
                          : 'Duration N/A',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              _buildInfoRow('Doctor', _getDataSafely(data, 'Doctor_Name')),
              const SizedBox(height: 8),
              _buildInfoRow('Start Date', _getDataSafely(data, 'MC_Start_Date')),
              const SizedBox(height: 4),
              _buildInfoRow('End Date', _getDataSafely(data, 'MC_End_Date')),
              
              const Divider(height: 24),
              
              Text(
                'Appointment Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Date', _getDataSafely(data, 'Appointment_Date')),
              const SizedBox(height: 4),
              _buildInfoRow('Time', _getDataSafely(data, 'Appointment_Time')),
              const SizedBox(height: 4),
              _buildInfoRow('Service', _getDataSafely(data, 'Appointment_Service')),
              const SizedBox(height: 4),
              _buildInfoRow('Reason', _getDataSafely(data, 'Appointment_Reason')),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('Error building MC card: $e\n$stackTrace');
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[300]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Error displaying this medical certificate',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _getDataSafely(Map<String, dynamic> data, String key) {
    try {
      final value = data[key];
      if (value == null) return 'Not specified';
      return value.toString();
    } catch (e) {
      return 'Not specified';
    }
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              message.contains('index') 
                  ? Icons.hourglass_empty 
                  : Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getCurrentUser,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndexingBanner() {
    if (!isIndexBuilding) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blue[50],
      child: Row(
        children: [
          const SizedBox(width: 16),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Optimizing database... Your certificates are shown below but may not be in order.',
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Certificates',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 2,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildIndexingBanner(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null && !isIndexBuilding
                    ? _buildErrorWidget(errorMessage!)
                    : userName == null
                        ? _buildErrorWidget('Unable to load user information')
                        : _certificatesStream == null
                            ? _buildErrorWidget('Unable to initialize certificates stream')
                            : RefreshIndicator(
                                onRefresh: _getCurrentUser,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: _certificatesStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }

                                    if (snapshot.hasError && !isIndexBuilding) {
                                      return _buildErrorWidget(
                                        'Error loading certificates: ${snapshot.error}'
                                      );
                                    }

                                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.medical_information_outlined,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No Medical Certificates Found',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Medical certificates issued to you will appear here',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    List<DocumentSnapshot> docs = snapshot.data!.docs;
                                    if (!isIndexBuilding) {
                                      // Sort manually if index is not being built
                                      docs.sort((a, b) {
                                        final aData = a.data() as Map<String, dynamic>;
                                        final bData = b.data() as Map<String, dynamic>;
                                        final aDate = aData['Created_At'] as Timestamp?;
                                        final bDate = bData['Created_At'] as Timestamp?;
                                        if (aDate == null || bDate == null) return 0;
                                        return bDate.compareTo(aDate);
                                      });
                                    }

                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      itemCount: docs.length,
                                      itemBuilder: (context, index) {
                                        return _buildMCCard(docs[index]);
                                      },
                                    );
                                  },
                                ),
                              ),
          ),
        ],
      ),
    );
  }
}