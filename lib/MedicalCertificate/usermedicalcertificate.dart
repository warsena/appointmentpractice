import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'dart:io';

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
    _certificatesStream = FirebaseFirestore.instance
        .collection('Medical_Certificate')
        .where('User_Name', isEqualTo: name)
        .snapshots()
        .handleError((error) {
      print('Stream error: $error');
      if (error.toString().contains('indexes?create_composite=')) {
        setState(() {
          isIndexBuilding = true;
          errorMessage =
              'Database is being optimized. This may take a few minutes. You can still view your certificates below.';
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
      await FirebaseFirestore.instance
          .collection('Medical_Certificate')
          .where('User_Name', isEqualTo: name)
          .orderBy('Created_At', descending: true)
          .limit(1)
          .get();

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

  Future<void> _generateAndDownloadPDF(
      Map<String, dynamic> data, String documentId) async {
    final pdf = pw.Document();

    // Load fonts with error handling
    pw.Font font;
    pw.Font boldFont;
    try {
      font = await PdfGoogleFonts.nunitoRegular();
      boldFont = await PdfGoogleFonts.nunitoBold();
    } catch (e) {
      // Fallback to default font if Google Fonts fail to load
      font = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Medical Certificate',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 24,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                          _buildPDFInfoRow(
                          'Doctor',
                          data['Doctor_Name'] ?? 'Not specified',
                          font,
                          boldFont),
                      _buildPDFInfoRow('Duration',
                          '${data['MC_Duration']} days', font, boldFont),
                      _buildPDFInfoRow(
                          'Start Date',
                          data['MC_Start_Date'] ?? 'Not specified',
                          font,
                          boldFont),
                      _buildPDFInfoRow(
                          'End Date',
                          data['MC_End_Date'] ?? 'Not specified',
                          font,
                          boldFont),
                      pw.SizedBox(height: 15),
                      pw.Text(
                        'Appointment Details',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 16,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      _buildPDFInfoRow(
                          'Date',
                          data['Appointment_Date'] ?? 'Not specified',
                          font,
                          boldFont),
                      _buildPDFInfoRow(
                          'Time',
                          data['Appointment_Time'] ?? 'Not specified',
                          font,
                          boldFont),
                      _buildPDFInfoRow(
                          'Service',
                          data['Appointment_Service'] ?? 'Not specified',
                          font,
                          boldFont),
                      _buildPDFInfoRow(
                          'Reason',
                          data['Appointment_Reason'] ?? 'Not specified',
                          font,
                          boldFont),
                      pw.SizedBox(height: 20),
                      pw.Text(
                        'Generated on: ${DateTime.now().toString().split('.')[0]}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      // Get temporary directory
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/MC_${documentId.substring(0, 6)}.pdf');

      // Save the PDF
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;

      // Share with platform-specific handling
      if (Platform.isAndroid) {
        final result = await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Medical Certificate for ${data['User_Name']}',
          subject: 'MC_${data['User_Name']}.pdf',
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 10, 10),
        );

        // Handle share result
        if (result.status == ShareResultStatus.dismissed) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sharing cancelled'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Medical Certificate for ${data['User_Name']}',
          subject: 'MC_${data['User_Name']}.pdf',
        );
      }
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildPDFInfoRow(
      String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 12,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMCCard(DocumentSnapshot document) {
    try {
      final data = document.data() as Map<String, dynamic>;
      String documentId = document.id;

      // Add these debug prints
      print('Document Data: $data'); // Let's see what's in the data
      print('User Name: ${data['User_Name']}'); // Check if User_Name exists

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
                      'MC ${data['User_Name'] ?? 'Unknown'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['MC_Duration']?.toString() != null
                              ? '${data['MC_Duration']} days'
                              : 'Duration N/A',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.teal),
                        onPressed: () =>
                            _generateAndDownloadPDF(data, documentId),
                        tooltip: 'Share MC',
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow('Doctor', _getDataSafely(data, 'Doctor_Name')),
              const SizedBox(height: 8),
              _buildInfoRow(
                  'Start Date', _getDataSafely(data, 'MC_Start_Date')),
              const SizedBox(height: 4),
              _buildInfoRow('End Date', _getDataSafely(data, 'MC_End_Date')),
              const Divider(height: 24),
              const Text(
                'Appointment Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Date', _getDataSafely(data, 'Appointment_Date')),
              const SizedBox(height: 4),
              _buildInfoRow('Time', _getDataSafely(data, 'Appointment_Time')),
              const SizedBox(height: 4),
              _buildInfoRow(
                  'Service', _getDataSafely(data, 'Appointment_Service')),
              const SizedBox(height: 4),
              _buildInfoRow(
                  'Reason', _getDataSafely(data, 'Appointment_Reason')),
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
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.teal,
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
                            ? _buildErrorWidget(
                                'Unable to initialize certificates stream')
                            : RefreshIndicator(
                                onRefresh: _getCurrentUser,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: _certificatesStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    if (snapshot.hasError && !isIndexBuilding) {
                                      return _buildErrorWidget(
                                          'Error loading certificates: ${snapshot.error}');
                                    }

                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .medical_information_outlined,
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

                                    List<DocumentSnapshot> docs =
                                        snapshot.data!.docs;
                                    if (!isIndexBuilding) {
                                      // Sort manually if index is not being built
                                      docs.sort((a, b) {
                                        final aData =
                                            a.data() as Map<String, dynamic>;
                                        final bData =
                                            b.data() as Map<String, dynamic>;
                                        final aDate =
                                            aData['Created_At'] as Timestamp?;
                                        final bDate =
                                            bData['Created_At'] as Timestamp?;
                                        if (aDate == null || bDate == null)
                                          return 0;
                                        return bDate.compareTo(aDate);
                                      });
                                    }

                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
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
