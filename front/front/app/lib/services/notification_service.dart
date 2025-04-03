import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize Notification Plugin
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    print("🔔 Initializing Notifications...");  // Debugging Line

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        print("🔔 Android 13+ Permission Granted: $granted");
      }
    }

    bool? initialized = await _notificationsPlugin.initialize(initializationSettings);
    print("✅ Notification Initialized: $initialized");
}


  // Show Immediate Notification
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel_id', 'Reminder Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }

  // Schedule a daily alarm at a fixed time
static Future<void> scheduleDailyAlarm(int id, String title, String body, TimeOfDay time) async {
  final now = DateTime.now();
  final scheduledDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );

  print("⏰ Scheduling daily alarm at: $scheduledDateTime for ID: $id"); // Debugging
  print("Current time (tz.local): ${tz.TZDateTime.now(tz.local)}");
  print("Scheduled time: $scheduledDateTime");


  await _notificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.now(tz.local).add(
    Duration(
        hours: time.hour - now.hour,
        minutes: time.minute - now.minute)),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder_channel', 'Daily Reminder',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Ensures alarm even in Doze Mode
    matchDateTimeComponents: DateTimeComponents.time, // Ensures it repeats daily
  );
  await NotificationService.showNotification(
    "Test Notification", "This should appear immediately!");

  print("✅ Daily alarm scheduled successfully!");
}

  // Cancel Scheduled Notification
  static Future<void> cancelNotification(int id) async {
    print("🛑 Cancelling notification with ID: $id");
    await _notificationsPlugin.cancel(id);
  }
}
