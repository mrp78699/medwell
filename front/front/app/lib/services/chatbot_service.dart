import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String apiUrl = "http://192.168.29.67:8000/api/chat/";

  static Future<Map<String, String>> getChatbotResponse(String question, String language) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": question, "language": language}),
      );

      print("API Response: ${response.body}");  // Debugging

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"answer": data["answer"]};
      } else {
        print("Error: ${response.statusCode}");  // Debugging
        return {"answer": "Error: Unable to fetch response."};
      }
    } catch (e) {
      print("Request Error: $e");  // Debugging
      return {"answer": "Error: $e"};
    }
  }
}