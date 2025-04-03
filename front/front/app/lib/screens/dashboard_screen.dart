import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onItemTapped;

  const DashboardScreen({Key? key, required this.onItemTapped}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> _fetchDashboardData() async {
    try {
      return await _authService.fetchDashboard();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[300]!, Colors.green[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchDashboardData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              });
              return const SizedBox();
            }

            String welcomeMessage = "Welcome, ${snapshot.data!['user']['name']}!";

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Centered Welcome Message
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      welcomeMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3, // Compact UI
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        _buildFeatureCard("Reminder", Icons.notifications_active, 1),
                        _buildFeatureCard("Usage Guide", Icons.video_library, 2),
                        _buildFeatureCard("Pain Tracker", Icons.healing, 3),
                        _buildFeatureCard("Prescriptions", Icons.description, 4),
                        _buildFeatureCard("Reports", Icons.picture_as_pdf, 5),
                        _buildFeatureCard("Chatbot", Icons.chat, 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // About Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "About MedWell",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "MedWell is your personal health assistant, offering medication reminders, pain tracking, and chatbot support to improve adherence to chronic disease treatments.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, int index) {
    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.green[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green[800]), // Increased icon size
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green[900]), // Larger text
            ),
          ],
        ),
      ),
    );
  }
}