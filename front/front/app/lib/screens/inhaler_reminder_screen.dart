import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for formatting time
import 'package:frontend/services/notification_service.dart';
import '../services/api_service.dart';

class InhalerReminderScreen extends StatefulWidget {
  @override
  _InhalerReminderScreenState createState() => _InhalerReminderScreenState();
}

class _InhalerReminderScreenState extends State<InhalerReminderScreen> {
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  List<dynamic> _reminders = [];

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    try {
      var reminders = await AuthService().fetchReminders();
      setState(() {
        _reminders = reminders ?? [];
      });
    } catch (e) {
      print("Error fetching reminders: $e");
    }
  }

  Future<void> _setReminder() async {
    if (_selectedTime != null) {
      setState(() => _isLoading = true);

      bool success = await AuthService().addReminder(_selectedTime!);

      setState(() => _isLoading = false);

      if (success) {
        _fetchReminders();

        int reminderId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

        await NotificationService.scheduleDailyAlarm(
          reminderId,
          "Inhaler Reminder",
          "It's time to use your inhaler!",
          _selectedTime!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Daily reminder set for ${_formatTime(_selectedTime!)}!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to set reminder.")),
        );
      }
    }
  }

  Future<void> _deleteReminder(int reminderId) async {
    bool success = await AuthService().deleteReminder(reminderId);

    if (success) {
      await NotificationService.cancelNotification(reminderId);
      _fetchReminders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reminder deleted successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete reminder.")),
      );
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final formattedTime = DateFormat('hh:mm a').format(
      DateTime(now.year, now.month, now.day, time.hour, time.minute),
    );
    return formattedTime;
  }

  String _formatStringTime(String timeString) {
    try {
      final parsedTime = DateFormat("HH:mm").parse(timeString); // Convert from 24-hour format
      return DateFormat("hh:mm a").format(parsedTime); // Convert to 12-hour format
    } catch (e) {
      return timeString; // Return as is if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inhaler Reminders", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                icon: Icon(Icons.access_time, color: Colors.green[700]),
                label: Text(
                  "Pick Reminder Time",
                  style: TextStyle(color: Colors.green[800]),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(color: Colors.green[700]!),
                ),
              ),
            ),
            if (_selectedTime != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Selected Time: ${_formatTime(_selectedTime!)}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green[800]),
                ),
              ),
            SizedBox(height: 10),
            _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : ElevatedButton(
              onPressed: _setReminder,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.green[700],
              ),
              child: Text("Set Daily Reminder", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _reminders.isEmpty
                  ? Center(
                child: Text(
                  "No reminders set yet.",
                  style: TextStyle(color: Colors.green[800], fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.green[100],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.notifications_active, color: Colors.green[700]),
                      title: Text(
                        "Reminder at ${_formatStringTime(_reminders[index]['reminder_time'])}",
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green[900]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteReminder(_reminders[index]['id']),
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