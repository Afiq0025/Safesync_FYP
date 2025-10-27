import 'package:cloud_firestore/cloud_firestore.dart';

class DiscussionPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final Timestamp timestamp;
  final List<String> likes;
  final List<String> repostedBy; // To track reposts
  final int commentCount;

  DiscussionPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.timestamp,
    this.likes = const [],
    this.repostedBy = const [], // Default to empty list
    this.commentCount = 0,
  });

  factory DiscussionPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DiscussionPost(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? 'Anonymous',
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
      repostedBy: List<String>.from(data['repostedBy'] ?? []), // Added reposts
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'author': author,
      'timestamp': timestamp,
      'likes': likes,
      'repostedBy': repostedBy,
      'commentCount': commentCount,
    };
  }
}
