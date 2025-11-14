
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safesync/models/alert.dart';
import 'package:safesync/main.dart'; // Ensure flutterLocalNotificationsPlugin is accessible
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;

  BackgroundService._internal();

  StreamSubscription<QuerySnapshot>? _alertSubscription;
  List<Alert> _previousAlerts = [];

  void start() {
    _alertSubscription?.cancel();
    _alertSubscription = FirebaseFirestore.instance
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final currentAlerts = snapshot.docs.map((doc) => Alert.fromFirestore(doc)).toList();
      _checkForNewAlerts(currentAlerts);
      _previousAlerts = currentAlerts;
    });
  }

  void stop() {
    _alertSubscription?.cancel();
  }

  void _checkForNewAlerts(List<Alert> currentAlerts) {
    final newAlerts = currentAlerts.where((alert) =>
    !_previousAlerts.any((prevAlert) => prevAlert.id == alert.id)).toList();

    for (var alert in newAlerts) {
      _showNotification(alert);
    }
  }

  void _showNotification(Alert alert) {
    flutterLocalNotificationsPlugin.show(
      alert.id.hashCode, // Use a unique id for each notification
      'New Alert: ${alert.priority} Priority',
      '${alert.message} at ${alert.location}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          channelDescription: 'channel_description',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: alert.id,
    );
  }
}
