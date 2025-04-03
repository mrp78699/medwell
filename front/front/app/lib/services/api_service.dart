import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/pdf_report.dart';
import 'package:frontend/models/prescription.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://192.168.29.67:8000/api/";

  // ✅ Register User
  Future<bool> register(String name, String email, String phone, String password, String confirmpassword) async {
    final response = await http.post(
      Uri.parse("${baseUrl}auth/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        "confirm_password": confirmpassword
      }),
    );

    return response.statusCode == 201;
  }

  // ✅ Login User
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}auth/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final name1 = data['user']['name'];
        final email1 = data['user']['email'];

        // Save token locally
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('name', name1);
        await prefs.setString('email', email1);

        return {"success": true};
      } else {
        final errorData = jsonDecode(response.body);
        return {"success": false, "message": errorData['detail'] ?? "Invalid email or password"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error. Please try again."};
    }
  }

  // **Check if User is Logged In**
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("token"); // Check if token exists
  }
  // ✅ Fetch Dashboard (Protected Route)
  Future<Map<String, dynamic>?> fetchDashboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse("${baseUrl}auth/dashboard/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // ✅ Logout (Clear Token)
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // ✅ Fetch Reminders
  Future<List<dynamic>?> fetchReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse("${baseUrl}inhaler-reminders/"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("Fetch Reminders Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // ✅ Add Reminder (Fixing Time Format & Debugging)
Future<bool> addReminder(TimeOfDay time) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Error: No token found.");
      return false;
    }

    // Convert TimeOfDay to `HH:MM:SS` format
    String formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";

    print("Formatted Time: $formattedTime"); // Debugging

    final response = await http.post(
      Uri.parse("${baseUrl}inhaler-reminders/"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reminder_time': formattedTime,
        'is_active': true
      }),
    );
    await NotificationService.showNotification("Test Notification", "This should appear immediately!");


    print("Add Reminder Response: ${response.statusCode} - ${response.body}");
    return response.statusCode == 201;
  } catch (e) {
    print("Exception in addReminder: $e");
    return false;
  }
  
}

// ✅ Delete Reminder with Error Handling
Future<bool> deleteReminder(int reminderId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Error: No token found.");
      return false;
    }

    final response = await http.delete(
      Uri.parse("${baseUrl}inhaler-reminders/$reminderId/"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("Delete Reminder Response: ${response.statusCode}");

    return response.statusCode == 204; // 204 means successful deletion
  } catch (e) {
    print("Exception in deleteReminder: $e");
    return false;
  }
}



// ✅ Fetch Pain Entries
  Future<List<dynamic>?> fetchPainEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse("${baseUrl}pain-tracker/"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // ✅ Add Pain Entry
  Future<bool> addPainEntry(String painArea, int painLevel, String painNotes) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse("${baseUrl}pain-tracker/"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pain_area': painArea,
        'pain_level': painLevel,
        'pain_notes': painNotes,
      }),
    );

    return response.statusCode == 201;
  }

  // ✅ Delete a Pain Entry
Future<bool> deletePainEntry(int entryId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.delete(
    Uri.parse("${baseUrl}pain-tracker/$entryId/"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  return response.statusCode == 204;
}
// Upload prescription file (works on Web & Mobile)
  // Upload prescription file
  Future<void> uploadPrescription(PlatformFile file) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated.");
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${baseUrl}upload_prescription/'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'prescription_file',
        file.bytes!,
        filename: file.name,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 201) {
      print('Prescription uploaded successfully');
    } else {
      print('Failed to upload prescription: ${response.statusCode}');
    }
  }

  // Fetch prescriptions for the authenticated user
  Future<List<Prescription>> fetchPrescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Get the token from SharedPreferences

    final response = await http.get(
      Uri.parse("${baseUrl}prescriptions/"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((prescription) => Prescription.fromJson(prescription)).toList();
    } else {
      throw Exception('Failed to load prescriptions');
    }
  }

  Future<void> deletePrescription(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.delete(
    Uri.parse("${baseUrl}prescriptions/$id/"),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 204) {
    throw Exception('Failed to delete prescription');
  }
}
 // ✅ Generate PDF Report
  Future<void> generatePDFReport(String name, int age, String gender, double weight, String mobileNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse("${baseUrl}generate-pdf/"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'age': age,
        'gender': gender,
        'weight': weight,
        'phone_number': mobileNumber,
      }),
    );

    if (response.statusCode == 201) {
      print('PDF Generated successfully');
    } else {
      print('Failed to generate PDF: ${response.body}');
      throw Exception('Failed to generate PDF: ${response.statusCode}');
    }
  }

  // ✅ Fetch PDF Reports
  Future<List<PDFReport>> fetchPDFReports() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse("${baseUrl}list-pdfs/"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      if (jsonData is Map<String, dynamic> && jsonData.containsKey('pdfs')) {
        return (jsonData['pdfs'] as List)
            .map((report) => PDFReport.fromJson(report))
            .toList();
      } else {
        throw Exception("Unexpected API response format");
      }
    } else {
      throw Exception('Failed to load reports');
    }
  }



  // ✅ Delete PDF Report
  Future<void> deletePDFReport(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse("${baseUrl}delete-pdf/$id/"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete report');
    }
  }
}

