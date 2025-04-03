import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Welcome to MedWell",
            body: "Your personal assistant for better health and medication adherence.",
            image: Center(child: Image.asset("assets/logo.png", width: 250)),
            decoration: getPageDecoration(),
          ),
          PageViewModel(
            title: "Track Your Health",
            body: "Monitor your medication and symptoms easily.",
            image: Center(child: Image.asset("assets/avatar/photo1.png", width: 250)),
            decoration: getPageDecoration(),
          ),
          PageViewModel(
            title: "Stay on Schedule",
            body: "Never miss a dose with our reminders and tracking features.",
            image: Center(child: Image.asset("assets/avatar/photo2.png", width: 250)),
            decoration: getPageDecoration(),
          ),
        ],
        done: Text("Get Started", style: TextStyle(fontWeight: FontWeight.bold)),
        onDone: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('seenOnboarding', true); // Mark onboarding as completed
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
        },
        next: Icon(Icons.arrow_forward),
        showSkipButton: true,
        skip: Text("Skip"),
        dotsDecorator: DotsDecorator(
          size: Size(10, 10),
          activeSize: Size(22, 10),
          activeColor: Colors.green[700]!,
          color: Colors.grey,
          spacing: EdgeInsets.symmetric(horizontal: 3),
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
    );
  }

  PageDecoration getPageDecoration() {
    return PageDecoration(
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
      bodyTextStyle: TextStyle(fontSize: 16, color: Colors.black),
      imagePadding: EdgeInsets.all(20),
      pageColor: Colors.white,
    );
  }
}
