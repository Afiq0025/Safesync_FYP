import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LockscreenService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static const String _prefLockscreenAccessKey = 'lockscreenAccessEnabled';
  static const String _prefMedicalName = 'medicalName';
  static const String _prefMedicalPhoneNumber = 'medicalPhoneNumber';
  static const String _prefMedicalBloodType = 'medicalBloodType';
  static const String _prefMedicalAllergies = 'medicalAllergies';
  static const String _prefMedicalConditions = 'medicalConditions';
  static const String _prefMedicalMedications = 'medicalMedications';
  static const int _medicalInfoNotificationId = 0;

  final ValueGetter<String> getName;
  final ValueGetter<String> getPhoneNumber;
  final ValueGetter<String> getBloodType;
  final ValueGetter<String> getAllergies;
  final ValueGetter<String> getMedicalConditions;
  final ValueGetter<String> getMedications;

  LockscreenService({
    required this.flutterLocalNotificationsPlugin,
    required this.getName,
    required this.getPhoneNumber,
    required this.getBloodType,
    required this.getAllergies,
    required this.getMedicalConditions,
    required this.getMedications,
  });

  Future<bool> isLockscreenAccessEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefLockscreenAccessKey) ?? false;
  }

  Future<void> loadSwitchStateAndShowNotification() async {
    if (await isLockscreenAccessEnabled()) {
      debugPrint("LockscreenService: Access enabled, showing notification on load.");
      await _showMedicalInfoNotification();
    }
  }

  Future<void> saveSwitchStateAndMedicalInfo(bool isEnabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefLockscreenAccessKey, isEnabled);

    if (isEnabled) {
      debugPrint("LockscreenService: Saving medical info and showing notification.");
      await prefs.setString(_prefMedicalName, getName());
      await prefs.setString(_prefMedicalPhoneNumber, getPhoneNumber());
      await prefs.setString(_prefMedicalBloodType, getBloodType());
      await prefs.setString(_prefMedicalAllergies, getAllergies());
      await prefs.setString(_prefMedicalConditions, getMedicalConditions());
      await prefs.setString(_prefMedicalMedications, getMedications());
      await _showMedicalInfoNotification();
    } else {
      debugPrint("LockscreenService: Cancelling notification.");
      await _cancelMedicalInfoNotification();
    }
  }

  Future<void> _showMedicalInfoNotification() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefMedicalName) ?? getName();
    final phone = prefs.getString(_prefMedicalPhoneNumber) ?? getPhoneNumber();
    final blood = prefs.getString(_prefMedicalBloodType) ?? getBloodType();
    final allergies = prefs.getString(_prefMedicalAllergies) ?? getAllergies();
    final conditions = prefs.getString(_prefMedicalConditions) ?? getMedicalConditions();
    final medications = prefs.getString(_prefMedicalMedications) ?? getMedications();

    String fullBody = '''Name: $name
Emergency Contact: $phone
Blood Type: $blood
Allergies: $allergies
Medical Conditions: $conditions
Medications: $medications''';
    String collapsedSummaryText = 'Name: $name - Tap for medical details';
    debugPrint("LockscreenService: Showing notification. Collapsed: '$collapsedSummaryText'. Full: '$fullBody'");

    final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      fullBody,
      htmlFormatBigText: false,
      contentTitle: 'Medical Information (Full)',
      htmlFormatContentTitle: false,
      summaryText: 'Medical Details',
      htmlFormatSummaryText: false,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medical_info_channel',
      'Medical Information',
      channelDescription: 'Displays critical medical information on lockscreen.',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      styleInformation: bigTextStyleInformation,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.show(
        _medicalInfoNotificationId,
        'Medical Information Access Enabled',
        collapsedSummaryText,
        platformChannelSpecifics,
        payload: 'MedicalInfoNotification',
      );
      debugPrint("LockscreenService: Notification shown successfully.");
    } catch (e) {
      debugPrint("LockscreenService: Error showing notification: $e");
    }
  }

  Future<void> _cancelMedicalInfoNotification() async {
    await flutterLocalNotificationsPlugin.cancel(_medicalInfoNotificationId);
    debugPrint("LockscreenService: Notification cancelled.");
  }

  // This method is needed for main.dart to initialize the global plugin instance
  // It's a bit of a workaround for not using DI.
  void setNotificationPlugin(FlutterLocalNotificationsPlugin plugin) {
    // flutterLocalNotificationsPlugin = plugin;
  }
   Future<void> requestPermissions(BuildContext context) async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        debugPrint('LockscreenService: Requesting Android notification permission...');
        final bool? granted = await androidImplementation.requestPermission();
        debugPrint('LockscreenService: Android Notification permission granted: $granted');
      }
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      debugPrint('LockscreenService: Requesting iOS notification permissions...');
      final bool? resultIOS = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      debugPrint("LockscreenService: iOS Notification permission granted: $resultIOS");
    }
  }
}
