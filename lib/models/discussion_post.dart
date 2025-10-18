import 'package:cloud_firestore/cloud_firestore.dart';

class DiscussionPost {
  final String id;
  final String content;
  final String author;
  final Timestamp timestamp; // Still non-nullable here for consistency after processing
  final List<String> likes; 
  final int commentCount;

  DiscussionPost({
    required this.id,
    required this.content,
    required this.author,
    required this.timestamp,
    this.likes = const [],
    this.commentCount = 0,
  });

  factory DiscussionPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DiscussionPost(
      id: doc.id,
      content: data['content'] ?? '',
      author: data['author'] ?? 'Anonymous',
      // Safely handle potentially null timestamp from Firestore
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'author': author,
      'timestamp': timestamp,
      'likes': likes,
      'commentCount': commentCount,
    };
  }
}
