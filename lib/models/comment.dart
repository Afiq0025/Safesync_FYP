import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String content;
  final String author;
  final Timestamp timestamp;

  Comment({
    required this.id,
    required this.content,
    required this.author,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      content: data['content'] ?? '',
      author: data['author'] ?? 'Anonymous',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
