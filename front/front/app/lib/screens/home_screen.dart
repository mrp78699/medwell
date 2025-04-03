import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'chatbot_screen.dart';
import 'inhaler_reminder_screen.dart';
import 'pain_tracker_screen.dart';
import 'prescription_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  String _userName = "User ";
  String _avatar = "assets/avatar/default_avatar.png";

  List<String> _availableAvatars = [
    "assets/avatar/photo1.png",
    "assets/avatar/photo2.png",
    "assets/avatar/photo3.png",
    "assets/avatar/photo4.png",
    "assets/avatar/photo5.png",
    "assets/avatar/default_avatar.png",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      DashboardScreen(onItemTapped: _onItemTapped), // Home
      InhalerReminderScreen(), // Reminder
      ChatbotScreen(), // Chatbot
      PainTrackerScreen(), // Pain Tracker
      PrescriptionListScreen(), // Prescription
    ];
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? "User ";
      _avatar = prefs.getString('avatar') ?? "assets/avatar/default_avatar.png";
    });
  }

  Future<void> _changeAvatar(String newAvatar) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar', newAvatar);
    setState(() {
      _avatar = newAvatar;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final AuthService _authService = AuthService();

  void _logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "MedWell",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Image.asset(
              'assets/logo.png',
              height: 30,
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[300]!, Colors.green[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      drawer: _buildDrawer(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildDrawerItems(),
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          _buildLogoutTile(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Container _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[800]!, Colors.green[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          GestureDetector(
            onTap: _showAvatarSelectionDialog,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(_avatar),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.edit, color: Colors.white70, size: 18),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            "$_userName",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text("Your Health Assistant", style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return [
      _buildDrawerItem("Dashboard", Icons.home, 0),
      _buildDrawerItem("Inhaler Reminder", Icons.medical_services, 1),
      _buildDrawerItem("Inhaler Usage Guide", Icons.video_library, 2),
      _buildDrawerItem("Pain Tracker", Icons.pie_chart, 3),
      _buildDrawerItem("Prescriptions", Icons.note, 4),
      _buildDrawerItem("Generate Report PDF", Icons.picture_as_pdf, 5),
      _buildDrawerItem("Chatbot", Icons.chat, 6),
    ];
  }

  ListTile _buildDrawerItem(String title, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? Colors.green[800] : Colors.black54),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      tileColor: _selectedIndex == index ? Colors.green.withOpacity(0.2) : Colors.transparent,
      selected: _selectedIndex == index,
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }

  ListTile _buildLogoutTile() {
    return ListTile(
      leading: Icon(Icons.logout, color: Colors.red),
      title: Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      onTap: () {
        _logout(context);
      },
    );
  }

  void _showAvatarSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select an Avatar"),
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _availableAvatars.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _changeAvatar(_availableAvatars[index]);
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(_availableAvatars[index]),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Reminder",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: "Chatbot",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart),
          label: "Pain Tracker",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.note),
          label: "Prescription",
        ),
      ],
    );
  }
}