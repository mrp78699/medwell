import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  String selectedLanguage = "en";

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _loadLanguagePreference();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? chatHistory = prefs.getString('chat_history');
    if (chatHistory != null) {
      setState(() {
        _messages = List<Map<String, String>>.from(jsonDecode(chatHistory));
      });
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', jsonEncode(_messages));
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lang = prefs.getString('selected_language');
    if (lang != null) {
      setState(() {
        selectedLanguage = lang;
      });
    }
  }

  Future<void> _saveLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', selectedLanguage);
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      String userQuestion = _controller.text;

      setState(() {
        _messages.add({"sender": "user", "message": userQuestion});
      });

      _controller.clear();
      _saveChatHistory();

      try {
        Map<String, String> chatbotResponse =
        await ChatbotService.getChatbotResponse(userQuestion, selectedLanguage);

        setState(() {
          _messages.add({"sender": "bot", "message": chatbotResponse["answer"]!});
        });

        _saveChatHistory();
      } catch (e) {
        print("Chatbot API Error: $e");
      }
    }
  }

  void _toggleLanguage() {
    setState(() {
      selectedLanguage = selectedLanguage == "en" ? "ml" : "en";
    });
    _saveLanguagePreference();
  }

  void _clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Chatbot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(
              selectedLanguage == "en" ? "English" : "Malayalam",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.translate, color: Colors.white),
            onPressed: _toggleLanguage,
            tooltip: "Switch to ${selectedLanguage == "en" ? "Malayalam" : "English"}",
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _clearChatHistory,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                reverse: false,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final bool isUser = message["sender"] == "user";

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.green.shade300 : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: isUser ? Radius.circular(12) : Radius.zero,
                          bottomRight: isUser ? Radius.zero : Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message["message"]!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.green.shade700,
                  radius: 25,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green.shade100,
    );
  }
}