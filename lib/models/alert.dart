import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String id;
  final String location;
  final String message;
  final String priority;
  final String status;
  final Timestamp timestamp;
  final String title;

  Alert({
    required this.id,
    required this.location,
    required this.message,
    required this.priority,
    required this.status,
    required this.timestamp,
    required this.title,
  });

  factory Alert.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Alert(
      id: doc.id,
      location: data['location'] ?? '',
      message: data['message'] ?? '',
      priority: data['priority'] ?? 'medium',
      status: data['status'] ?? 'active',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      title: data['title'] ?? '',
    );
  }
}
