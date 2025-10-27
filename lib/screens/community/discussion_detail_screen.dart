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
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    _isLiked = currentUser != null && widget.post.likes.contains(currentUser.uid);
    _likeCount = widget.post.likes.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title), // Using post title in app bar
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildPostContent()),
                SliverToBoxAdapter(child: const Divider(thickness: 1)),
                _buildCommentsSliverList(), // This now returns the StreamBuilder which builds SliverList
              ],
            ),
          ),
          _buildCommentInputField(),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(widget.post.author.isNotEmpty ? widget.post.author[0].toUpperCase() : 'A'),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Posted by ${widget.post.author}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatTimestamp(widget.post.timestamp),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.post.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.post.content,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                color: _isLiked ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onPressed: _likePost,
            ),
            Text(_likeCount.toString()),
            // A downvote button can be added here if needed
          ],
        ),
        TextButton.icon(
          icon: const Icon(Icons.comment_outlined, size: 20),
          label: Text('${widget.post.commentCount} Comments'),
          onPressed: () { /* Maybe scroll to comments or focus input */ },
          style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () {
            // TODO: Implement share functionality
          },
        ),
      ],
    );
  }

  // Refactored to return a Sliver for CustomScrollView
  Widget _buildCommentsSliverList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('discussions')
          .doc(widget.post.id)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(child: const Center(child: Text('Something went wrong')));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(child: const Center(child: CircularProgressIndicator()));
        }

        final comments = snapshot.data!.docs
            .map((doc) => Comment.fromFirestore(doc))
            .toList();

        if (comments.isEmpty) {
          return SliverToBoxAdapter(
            child: const Center(
              child: Text('No comments yet. Be the first to comment!'),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final comment = comments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      child: Text(comment.author.isNotEmpty ? comment.author[0].toUpperCase() : 'A'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text(
                                _formatTimestamp(comment.timestamp),
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(comment.content),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: comments.length,
          ),
        );
      },
    );
  }

  Widget _buildCommentInputField() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              ),
              minLines: 1,
              // maxLines: 5, // Already removed
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _postComment,
          ),
        ],
      ),
    );
  }

  Future<void> _likePost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final postRef = FirebaseFirestore.instance.collection('discussions').doc(widget.post.id);

    setState(() {
      if (_isLiked) {
        _likeCount -= 1;
        _isLiked = false;
        postRef.update({'likes': FieldValue.arrayRemove([currentUser.uid])});
      } else {
        _likeCount += 1;
        _isLiked = true;
        postRef.update({'likes': FieldValue.arrayUnion([currentUser.uid])});
      }
    });
  }

  Future<void> _postComment() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || _commentController.text.trim().isEmpty) {
      return;
    }

    final postRef = FirebaseFirestore.instance.collection('discussions').doc(widget.post.id);

    // Add the comment to the subcollection
    await postRef.collection('comments').add({
      'content': _commentController.text.trim(),
      'author': currentUser.displayName ?? currentUser.email ?? 'Anonymous',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Increment the comment count on the post
    await postRef.update({'commentCount': FieldValue.increment(1)});

    _commentController.clear();
    FocusScope.of(context).unfocus(); // Dismiss keyboard
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d, yyyy • hh:mm a').format(dateTime);
  }
}
