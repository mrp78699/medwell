import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/pdf_report.dart';

class PDFReportListScreen extends StatefulWidget {
  @override
  _PDFReportListScreenState createState() => _PDFReportListScreenState();
}

class _PDFReportListScreenState extends State<PDFReportListScreen> {
  late Future<List<PDFReport>> reports;
  final AuthService apiService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchPDFReports();
  }

  void fetchPDFReports() {
    setState(() {
      reports = apiService.fetchPDFReports();
    });
  }

  void deletePDFReport(int id) async {
    try {
      await apiService.deletePDFReport(id);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report deleted successfully')));
      fetchPDFReports();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete report')));
    }
  }

  void _openPDF(PDFReport report) {
    if (report.fileUrl.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('File not available')));
      return;
    }

    Navigator.pushNamed(
      context,
      '/pdf-viewer',
      arguments: {'fileUrl': report.fileUrl},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated Reports', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
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
        child: FutureBuilder<List<PDFReport>>(
          future: reports,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 50),
                    SizedBox(height: 10),
                    Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insert_drive_file, size: 60, color: Colors.green.shade400),
                    SizedBox(height: 10),
                    Text('No reports available.', style: TextStyle(fontSize: 18, color: Colors.black54)),
                  ],
                ),
              );
            }

            final reports = snapshot.data!;

            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      "Report ${report.id} - ${report.name}",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]),
                    ),
                    subtitle: Text("Generated at: ${report.generatedAt}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_red_eye, color: Colors.green),
                          onPressed: () {
                            _openPDF(report);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deletePDFReport(report.id);
                          },
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
        backgroundColor: Colors.green.shade700,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/pdf-generation');
          if (result == true) {
            fetchPDFReports();
          }
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}