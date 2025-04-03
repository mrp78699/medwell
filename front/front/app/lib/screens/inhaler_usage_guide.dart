import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class InhalerUsageGuideScreen extends StatefulWidget {
  @override
  _InhalerUsageGuideScreenState createState() => _InhalerUsageGuideScreenState();
}

class _InhalerUsageGuideScreenState extends State<InhalerUsageGuideScreen> {
  late YoutubePlayerController _controller1;
  late YoutubePlayerController _controller2;
  bool _isVideo1Playing = false;
  bool _isVideo2Playing = false;
  bool _isMalayalam = false; // State variable for language toggle

  @override
  void initState() {
    super.initState();
    _controller1 = YoutubePlayerController(
      initialVideoId: "2i9_DelNqs4",
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );

    _controller2 = YoutubePlayerController(
      initialVideoId: "0tkEIRDGb4c",
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inhaler Usage Guide", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
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
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              SizedBox(height: 10),
              _buildLanguageToggleButton(), // Language Toggle Button
              SizedBox(height: 20),
              _buildStepSection(),
              SizedBox(height: 20),
              _buildVideoSection("General Inhaler Guide", _controller1, _isVideo1Playing, () {
                setState(() => _isVideo1Playing = !_isVideo1Playing);
              }),
              SizedBox(height: 20),
              _buildVideoSection("Proper Inhaler Technique", _controller2, _isVideo2Playing, () {
                setState(() => _isVideo2Playing = !_isVideo2Playing);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isMalayalam ? "ഇൻഹെയ്ലർ എങ്ങനെ ഉപയോഗിക്കാം" : "How to Use an Inhaler",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green[800]),
        ),
        SizedBox(height: 10),
        Text(
          _isMalayalam ? "നിങ്ങളുടെ ഇൻഹെയ്ലർ ശരിയായി ഉപയോഗിക്കാൻ ഈ ചുവടെയുള്ള ഘട്ടങ്ങൾ പാലിക്കൂ:" :
          "Follow these steps to use your inhaler properly:",
          style: TextStyle(fontSize: 16, color: Colors.green[700]),
        ),
      ],
    );
  }

  Widget _buildLanguageToggleButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _isMalayalam = !_isMalayalam;
          });
        },
        icon: Icon(Icons.language, color: Colors.white),
        label: Text(_isMalayalam ? "Switch to English" : "മലയാളത്തിലേക്ക് മാറുക"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildStepSection() {
    List<String> stepsEnglish = [
      "Shake the inhaler well before use.",
      "Remove the cap and hold the inhaler upright.",
      "Exhale completely before placing the inhaler in your mouth.",
      "Press the inhaler and inhale deeply at the same time.",
      "Hold your breath for 10 seconds before exhaling.",
      "Rinse your mouth after using the inhaler to prevent irritation."
    ];

    List<String> stepsMalayalam = [
      "ഉപയോഗത്തിനുമുമ്പ് ഇൻഹെയ്ലർ നന്നായി കുലുക്കുക.",
      "ക്യാപ് നീക്കംചെയ്ത് ഇൻഹെയ്ലർ നേരെയായി പിടിക്കുക.",
      "ഇൻഹെയ്ലർ വായിൽ ഇട്ടതിനു മുമ്പ് മുഴുവൻ വായു പുറന്തള്ളുക.",
      "ഇൻഹെയ്ലർ അമർത്തിയോടൊപ്പം ആഴത്തിൽ ശ്വസിക്കുക.",
      "പുറത്തൊഴിയുന്നതിനു മുമ്പ് 10 സെക്കന്റ് ശ്വാസം പിടിച്ചു വെക്കുക.",
      "ഇൻഹെയ്ലർ ഉപയോഗിച്ചതിന് ശേഷം വായ് കഴുകുക."
    ];

    List<String> selectedSteps = _isMalayalam ? stepsMalayalam : stepsEnglish;

    return Column(
      children: selectedSteps.asMap().entries.map((entry) => _buildStepCard(entry.key + 1, entry.value)).toList(),
    );
  }

  Widget _buildStepCard(int stepNumber, String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green[700],
            child: Text(
              stepNumber.toString(),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green[900], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(String title, YoutubePlayerController controller, bool isPlaying, VoidCallback onPlayPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800])),
        SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: isPlaying
              ? YoutubePlayer(controller: controller, showVideoProgressIndicator: true)
              : GestureDetector(
            onTap: onPlayPressed,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  "https://img.youtube.com/vi/${controller.initialVideoId}/0.jpg",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Icon(Icons.play_circle_outline, size: 60, color: Colors.green[700]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}