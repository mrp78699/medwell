import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/prescription.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

const String BASE_URL = "https://medwell-429166644600.asia-south1.run.app/api";
const Color primaryGreen = Color(0xFF4CAF50);

class PrescriptionListScreen extends StatefulWidget {
  @override
  _PrescriptionListScreenState createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen> {
  late Future<List<Prescription>> prescriptions;
  final AuthService apiService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchPrescriptionList();
  }

  void fetchPrescriptionList() {
    setState(() {
      prescriptions = apiService.fetchPrescriptions();
    });
  }

  void deletePrescription(int id) async {
    try {
      await apiService.deletePrescription(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prescription deleted successfully')),
      );
      fetchPrescriptionList();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete prescription')),
      );
    }
  }

  Future<void> _openFile(Prescription prescription) async {
    if (prescription.prescriptionFile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File not available')),
      );
      return;
    }

    final String fileUrl = "$BASE_URL${prescription.prescriptionFile}";

    if (fileUrl.toLowerCase().endsWith('.pdf')) {
      String? localPath = await _downloadPDF(fileUrl);
      if (localPath != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerScreen(localFilePath: localPath),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download PDF')),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    fileUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Failed to load image', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(fontSize: 16, color: primaryGreen)),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<String?> _downloadPDF(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var dir = await getApplicationDocumentsDirectory();
        File file = File('${dir.path}/prescription.pdf');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      print("Error downloading PDF: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Prescriptions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryGreen,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[300]!, Colors.green[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<Prescription>>(
          future: prescriptions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryGreen));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No prescriptions available.'));
            }

            final prescriptions = snapshot.data!;

            return ListView.builder(
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = prescriptions[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    title: Text("Prescription ${prescription.id}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Uploaded at: ${prescription.uploadedAt}"),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_red_eye, color: primaryGreen),
                          onPressed: () => _openFile(prescription),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deletePrescription(prescription.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/upload-prescription');
          if (result == true) {
            fetchPrescriptionList();
          }
        },
        backgroundColor: primaryGreen,
        child: Icon(Icons.upload_file, color: Colors.white),
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String localFilePath;
  PDFViewerScreen({required this.localFilePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Prescription"),
        backgroundColor: primaryGreen,
      ),
      body: PDFView(
        filePath: localFilePath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageSnap: true,
      ),
    );
  }
}
