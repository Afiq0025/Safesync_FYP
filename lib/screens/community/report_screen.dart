import 'package:flutter/material.dart';
import 'package:safesync/models/discussion_post.dart';
import 'package:safesync/screens/community/submit_report.dart';
import 'package:safesync/screens/community/report.dart';
import 'package:safesync/screens/community/discussion_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _currentTab = 0; // 0: Report, 1: Alert, 2: Discussion
  final TextEditingController _discussionController = TextEditingController();
  final TextEditingController _discussionTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B6B),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Text(
                    'Community',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'YourCustomFont',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildTab('Report', 0),
                  _buildTab('Alert', 1),
                  _buildTab('Discussion', 2),
                ],
              ),
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _currentTab == index
                ? Colors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _currentTab == index ? Colors.red : Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'YourCustomFont',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentTab) {
      case 0:
        return _buildReportTab();
      case 1:
        return _buildAlertTab();
      case 2:
        return _buildDiscussionTab();
      default:
        return _buildReportTab();
    }
  }

  Widget _buildReportTab() {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('reports')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong! ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No reports yet. Be the first to submit!'));
            }

            final reports = snapshot.data!.docs
                .map((doc) => Report.fromFirestore(doc))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 80),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _buildReportCard(report);
              },
            );
          },
        ),
        Positioned(
          bottom: 15,
          left: 15,
          right: 15,
          child: Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubmitReportScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: const BorderSide(color: Colors.red, width: 2),
                ),
                elevation: 5,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Text(
                'Submit Report',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'YourCustomFont',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertTab() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        _buildAlertCard(
          'ACTIVE ALERT',
          'High Risk Area - Jalan Sentosa',
          'Multiple break-in reports in past 48 hours. Avoid area after 10 PM.',
          'High',
          ['Break-in', 'Night Patrol'],
        ),
        _buildAlertCard(
          'COMMUNITY NOTICE',
          'Neighborhood Watch Meeting',
          'Emergency meeting scheduled for tomorrow 8 PM at Community Hall.',
          'Medium',
          ['Meeting', 'Community'],
        ),
      ],
    );
  }

  void _showDiscussionBottomSheet(User? currentUser) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Start a New Discussion',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'YourCustomFont',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _discussionTitleController,
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _discussionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts with the community...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'YourCustomFont',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await _postDiscussion(currentUser);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        fontFamily: 'YourCustomFont',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiscussionTab() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('discussions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No discussions yet. Start one!',
                style: TextStyle(color: Colors.black54, fontFamily: 'YourCustomFont'),
              ),
            );
          }

          final posts = snapshot.data!.docs
              .map((doc) => DiscussionPost.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 80), // Padding for FAB
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildDiscussionPostCard(post, currentUser);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDiscussionBottomSheet(currentUser),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _postDiscussion(User? currentUser) async {
    if (_discussionController.text.isEmpty || _discussionTitleController.text.isEmpty) return;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('discussions').add({
      'title': _discussionTitleController.text,
      'content': _discussionController.text,
      'author': currentUser.displayName ?? currentUser.email ?? 'Anonymous',
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
      'repostedBy': [],
      'commentCount': 0,
    });

    _discussionController.clear();
    _discussionTitleController.clear();
  }

  Future<void> _toggleLike(DiscussionPost post, User? currentUser) async {
    if (currentUser == null) return;

    final postRef = FirebaseFirestore.instance.collection('discussions').doc(post.id);
    final currentLikes = List<String>.from(post.likes);

    if (currentLikes.contains(currentUser.uid)) {
      currentLikes.remove(currentUser.uid);
    } else {
      currentLikes.add(currentUser.uid);
    }

    await postRef.update({'likes': currentLikes});
  }

  Future<void> _toggleRepost(DiscussionPost post, User? currentUser) async {
    if (currentUser == null) return;

    final postRef = FirebaseFirestore.instance.collection('discussions').doc(post.id);
    final currentReposts = List<String>.from(post.repostedBy);

    if (currentReposts.contains(currentUser.uid)) {
      currentReposts.remove(currentUser.uid);
    } else {
      currentReposts.add(currentUser.uid);
    }

    await postRef.update({'repostedBy': currentReposts});
  }

  Widget _buildReportCard(Report report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'YourCustomFont',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'YourCustomFont',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${report.dateTime} | ${report.location}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: 'YourCustomFont',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              report.description,
              style: const TextStyle(
                fontFamily: 'YourCustomFont',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: report.tags.map((tag) => Chip(
                label: Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: 'YourCustomFont',
                  ),
                ),
                backgroundColor: Colors.grey[200],
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Reported by: ${report.author}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                fontFamily: 'YourCustomFont',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(String title, String location, String description, String urgency, List<String> tags) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: urgency == 'High' ? Colors.red[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'YourCustomFont',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgency == 'High' ? Colors.red : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    urgency,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'YourCustomFont',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              location,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontFamily: 'YourCustomFont',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'YourCustomFont',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: tags.map((tag) => Chip(
                label: Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: 'YourCustomFont',
                  ),
                ),
                backgroundColor: Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionPostCard(DiscussionPost post, User? currentUser) {
    final bool isLiked = currentUser != null && post.likes.contains(currentUser.uid);
    final bool isReposted = currentUser != null && post.repostedBy.contains(currentUser.uid);

    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column for avatar
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE1D5E7),
                      child: Text(
                        post.author.isNotEmpty ? post.author[0].toUpperCase() : 'A',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                // Right column for content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author and timestamp
                      Row(
                        children: [
                          Text(
                            post.author,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'YourCustomFont'),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTimestamp(post.timestamp),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontFamily: 'YourCustomFont'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Title and content
                      Text(
                        post.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'YourCustomFont'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.content,
                        style: const TextStyle(fontSize: 15, fontFamily: 'YourCustomFont'),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      // Action buttons
                      Row(
                        children: [
                          // Like button
                          IconButton(
                            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey, size: 20),
                            onPressed: () => _toggleLike(post, currentUser),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 4),
                          Text('${post.likes.length}', style: const TextStyle(fontFamily: 'YourCustomFont')),
                          const SizedBox(width: 24),
                          // Comment button
                          IconButton(
                            icon: const Icon(Icons.mode_comment_outlined, size: 20, color: Colors.grey),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DiscussionDetailScreen(post: post)),
                              );
                            },
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 4),
                          Text('${post.commentCount}', style: const TextStyle(fontFamily: 'YourCustomFont')),
                          const SizedBox(width: 24),
                          // Repost button
                          IconButton(
                            icon: Icon(Icons.repeat, color: isReposted ? Colors.green : Colors.grey, size: 20),
                            onPressed: () => _toggleRepost(post, currentUser),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 4),
                          Text('${post.repostedBy.length}', style: const TextStyle(fontFamily: 'YourCustomFont')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d, yyyy • hh:mm a').format(dateTime);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'under investigation':
        return Colors.orange;
      case 'unverified':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    _discussionController.dispose();
    _discussionTitleController.dispose();
    super.dispose();
  }
}
