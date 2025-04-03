import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

const String BASE_URL = "http://192.168.29.67:8000/api/";

class PDFViewerScreen extends StatefulWidget {
  final String fileUrl;

  const PDFViewerScreen({Key? key, required this.fileUrl}) : super(key: key);

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localFilePath;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAndLoadPDF();
  }

  String _getFullPdfUrl(String url) {
    return url.startsWith("http") ? url : "$BASE_URL${url.startsWith('/') ? url.substring(1) : url}";
  }

  Future<void> _fetchAndLoadPDF() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    String fullUrl = _getFullPdfUrl(widget.fileUrl);
    try {
      var response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        var dir = await getApplicationDocumentsDirectory();
        File file = File('${dir.path}/downloaded_pdf.pdf');
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          localFilePath = file.path;
          isLoading = false;
        });
      } else {
        _handleError('Failed to load PDF (Status Code : ${response.statusCode})');
      }
    } catch (e) {
      _handleError("An error occurred while loading the PDF.");
    }
  }

  Future<void> _downloadPDF() async {
    if (localFilePath == null) return;
    if (await Permission.storage.request().isGranted) {
      Directory? directory = await getExternalStorageDirectory();
      String savePath = '${directory?.path}/saved_pdf.pdf';
      File file = File(savePath);
      await file.writeAsBytes(File(localFilePath!).readAsBytesSync());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF saved to $savePath")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission denied")),
      );
    }
  }

  void _handleError(String message) {
    setState(() {
      errorMessage = message;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        actions: [
          if (localFilePath != null)
            IconButton(
              icon: Icon(Icons.download),
              onPressed: _downloadPDF,
            )
        ],
      ),
      body: _buildBody(),
      backgroundColor: Colors.green.shade50,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.green.shade700));
    } else if (errorMessage != null) {
      return _buildErrorUI();
    } else if (localFilePath != null) {
      return _buildPdfView();
    } else {
      return Center(child: Text("No PDF available", style: TextStyle(color: Colors.green.shade800, fontSize: 18)));
    }
  }

  Widget _buildPdfView() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5)],
      ),
      child: PDFView(
        filePath: localFilePath!,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageSnap: true,
        fitPolicy: FitPolicy.BOTH,
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 16)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchAndLoadPDF,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Retry", style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}