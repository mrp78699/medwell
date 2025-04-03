import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PainTrackerScreen extends StatefulWidget {
  @override
  _PainTrackerScreenState createState() => _PainTrackerScreenState();
}

class _PainTrackerScreenState extends State<PainTrackerScreen> {
  final List<String> _painAreas = ['Head', 'Leg', 'Hand'];
  String _selectedArea = 'Head';
  double _painLevel = 5;
  TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _painEntries = [];

  @override
  void initState() {
    super.initState();
    _fetchPainEntries();
  }

  Future<void> _fetchPainEntries() async {
    try {
      var entries = await AuthService().fetchPainEntries();
      setState(() {
        _painEntries = entries ?? [];
      });
    } catch (e) {
      print("Error fetching pain entries: $e");
    }
  }

  Future<void> _submitPainEntry() async {
    setState(() => _isLoading = true);

    bool success = await AuthService().addPainEntry(
      _selectedArea,
      _painLevel.toInt(),
      _notesController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      _fetchPainEntries();
      _notesController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pain entry recorded successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to record pain entry.")),
      );
    }
  }

  Future<void> _deletePainEntry(int entryId) async {
    bool success = await AuthService().deletePainEntry(entryId);

    if (success) {
      setState(() {
        _painEntries.removeWhere((entry) => entry['id'] == entryId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pain entry deleted successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete pain entry.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pain Tracker", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Pain Area:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                    SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: _selectedArea,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.green.shade100,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedArea = value!;
                        });
                      },
                      items: _painAreas.map((area) {
                        return DropdownMenuItem<String>(
                          value: area,
                          child: Text(area, style: TextStyle(color: Colors.green.shade900)),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 15),
                    Text("Pain Level (1-10):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                    Slider(
                      value: _painLevel,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: Colors.green.shade700,
                      inactiveColor: Colors.green.shade200,
                      label: _painLevel.toString(),
                      onChanged: (value) {
                        setState(() {
                          _painLevel = value;
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    Text("Additional Notes (Optional):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: "Enter pain notes...",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.green.shade100,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 15),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                        ),
                        onPressed: _submitPainEntry,
                        child: Text("Record Pain Entry", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Pain History:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900)),
            Expanded(
              child: _painEntries.isEmpty
                  ? Center(child: Text("No pain entries recorded.", style: TextStyle(color: Colors.green.shade700)))
                  : ListView.builder(
                itemCount: _painEntries.length,
                itemBuilder: (context, index) {
                  var entry = _painEntries[index];
                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("${entry['pain_area']} - Level: ${entry['pain_level']}",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                      subtitle: Text("Notes: ${entry['pain_notes'] ?? 'No notes'}\nDate: ${entry['timestamp']}",
                          style: TextStyle(color: Colors.green.shade700)),
                      leading: Icon(Icons.healing, color: Colors.green.shade700),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePainEntry(entry['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}