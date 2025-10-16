import 'package:flutter/material.dart';
import 'package:safesync/models/discussion_post.dart';
import 'package:safesync/models/comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DiscussionDetailScreen extends StatefulWidget {
  final DiscussionPost post;

  const DiscussionDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _DiscussionDetailScreenState createState() => _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState extends State<DiscussionDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.content,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.post.author} • ${_formatTimestamp(widget.post.timestamp)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('discussions')
                  .doc(widget.post.id)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comments = snapshot.data!.docs
                    .map((doc) => Comment.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text(comment.content),
                      subtitle: Text(
                          '${comment.author} • ${_formatTimestamp(comment.timestamp)}'),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _postComment() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || _commentController.text.isEmpty) {
      return;
    }

    final postRef = FirebaseFirestore.instance.collection('discussions').doc(widget.post.id);

    // Add the comment to the subcollection
    await postRef.collection('comments').add({
      'content': _commentController.text,
      'author': currentUser.displayName ?? currentUser.email ?? 'Anonymous',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Increment the comment count on the post
    await postRef.update({'commentCount': FieldValue.increment(1)});

    _commentController.clear();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d, yyyy • hh:mm a').format(dateTime);
  }
}
