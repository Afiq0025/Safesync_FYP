import 'package:cloud_firestore/cloud_firestore.dart'; // Added for DocumentSnapshot

class Report {
  final String title;
  final String description;
  final String dateTime;
  final String location;
  final String status;
  final List<String> tags;
  final String author;
  // final String? id; // Optional: if you need the document ID

  Report({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.status,
    required this.tags,
    required this.author,
    // this.id,
  });

  // Factory constructor to create a Report from a Firestore document
  factory Report.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Report(
      // id: doc.id, // Optional: store document ID
      title: data?['reportTitle'] ?? 'No Title',
      description: data?['reportDescription'] ?? 'No Description',
      dateTime: data?['submittedDateTimeString'] ?? 'No Date/Time',
      location: data?['locationString'] ?? 'Unknown Location',
      status: data?['status'] ?? 'Unverified',
      tags: List<String>.from(data?['tags'] ?? []),
      author: data?['userName'] ?? 'Anonymous',
    );
  }
}
