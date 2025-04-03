import 'package:flutter/material.dart';
import 'package:frontend/screens/onboarding_screen.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/pdf_report_generation_screen.dart';
import 'package:frontend/screens/pdf_viewer_screen.dart';
import 'package:frontend/screens/upload_prescription_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/auth_check_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationService.initialize(); // Ensure notifications are initialized
  } catch (e) {
    debugPrint("Error initializing notifications: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasSeenOnboarding = prefs.getBool('seenOnboarding');

    setState(() {
      _showOnboarding = hasSeenOnboarding == null || !hasSeenOnboarding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedWell',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(showOnboarding: _showOnboarding),
      initialRoute: '/',
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/pdf-generation': (context) => GeneratePDFReportScreen(),
        '/upload-prescription': (context) => UploadPrescriptionScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/pdf-viewer') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args != null && args.containsKey('fileUrl')) {
            return MaterialPageRoute(
              builder: (context) => PDFViewerScreen(fileUrl: args['fileUrl']),
            );
          }
        }
        return MaterialPageRoute(builder: (context) => LoginScreen());
      },
      builder: (context, child) {
        return child ?? const SizedBox();
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final bool showOnboarding;
  const SplashScreen({required this.showOnboarding, Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.showOnboarding
              ? OnboardingScreen()
              : AuthCheckScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Center(
            child: Column(
              children: [
                Image.asset("assets/logo.png", width: 150),
                SizedBox(height: 20),
                Text(
                  "MedWell",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Image.asset("assets/google.png", width: 75),
                Text(
                  "Developed by Google",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ]
            )
          ),
        ],
      ),
    );
  }
}
