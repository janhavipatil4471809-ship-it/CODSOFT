import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/alarm.dart';

class AlarmService extends ChangeNotifier {
  List<Alarm> _alarms = [];
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Alarm> get alarms => _alarms;

  // Available alarm tones
  static const List<String> availableTones = [
    'Classic Beep',
    'Gentle Wake',
    'Morning Birds',
    'Digital Buzz',
    'Smooth Jazz',
  ];

  AlarmService() {
    tz.initializeTimeZones();
    _initializeNotifications();
    _loadAlarms();
  }

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification for Android
    const androidChannel = AndroidNotificationChannel(
      'alarm_channel',
      'Alarms',
      description: 'Alarm notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
  }

  // Load alarms from storage
  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getString('alarms');
    
    if (alarmsJson != null) {
      final List<dynamic> decoded = json.decode(alarmsJson);
      _alarms = decoded.map((json) => Alarm.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Save alarms to storage
  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = json.encode(_alarms.map((a) => a.toJson()).toList());
    await prefs.setString('alarms', alarmsJson);
  }

  // Add new alarm
  Future<void> addAlarm(Alarm alarm) async {
    _alarms.add(alarm);
    await _saveAlarms();
    await _scheduleNotification(alarm);
    notifyListeners();
  }

  // Update alarm
  Future<void> updateAlarm(String id, Alarm updatedAlarm) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alarms[index] = updatedAlarm;
      await _saveAlarms();
      
      // Cancel old notification 
      await _notifications.cancel(id.hashCode);
      if (updatedAlarm.isActive) {
        await _scheduleNotification(updatedAlarm);
      }
      notifyListeners();
    }
  }

  Future<void> toggleAlarm(String id) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      final updated = alarm.copyWith(isActive: !alarm.isActive);
      _alarms[index] = updated;
      
      await _saveAlarms();
      
      if (updated.isActive) {
        await _scheduleNotification(updated);
      } else {
        await _notifications.cancel(id.hashCode);
      }
      
      notifyListeners();
    }
  }

  Future<void> deleteAlarm(String id) async {
    _alarms.removeWhere((a) => a.id == id);
    await _saveAlarms();
    await _notifications.cancel(id.hashCode);
    notifyListeners();
  }

  Future<void> _scheduleNotification(Alarm alarm) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'alarm_sound.aiff',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      alarm.id.hashCode,
      'Alarm',
      alarm.label,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Play alarm sound
  Future<void> playAlarmSound(String tone) async {
    // placeholder for sound
    await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
  }

  // Stop alarm sound
  Future<void> stopAlarmSound() async {
    await _audioPlayer.stop();
  }

  Future<void> snoozeAlarm(String id) async {
    final alarm = _alarms.firstWhere((a) => a.id == id);
    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
    final snoozedAlarm = alarm.copyWith(time: snoozeTime);
    
    await updateAlarm(id, snoozedAlarm);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}