import 'package:flutter/material.dart';
import 'package:safesync/models/discussion_post.dart';
import 'submit_report.dart';
import 'package:safesync/screens/community/report.dart'; // Import the Report model
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firestore

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _currentTab = 0; // 0: Report, 1: Alert, 2: Discussion
  // List<Report> _reports = []; // Removed: Reports will be handled by StreamBuilder
  List<DiscussionPost> _discussionPosts = [];
  final TextEditingController _discussionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _reports initialization removed.

    _discussionPosts = [
      // ... (your existing discussion posts initialization) ...
      DiscussionPost(
        content: 'Need more street lights on Jalan Bukit. There have been multiple incidents on this street. We need better lighting for safety.',
        author: 'Sarah L.',
        dateTime: 'May 6, 2025 • 10:00 AM',
        likes: 12,
        comments: 5,
      ),
      DiscussionPost(
        content: 'Managed to get the plate number of that black van: ABC 1234. Should we report to police?',
        author: 'Mike T.',
        dateTime: 'May 6, 2025 • 8:30 AM',
        likes: 8,
        comments: 3,
      ),
      DiscussionPost(
        content: 'Anyone else experiencing frequent power outages in the Taman Sri Muda area? Its been happening almost daily this week.',
        author: 'John D.',
        dateTime: 'May 7, 2025 • 11:15 AM',
        likes: 5,
        comments: 2,
      ),
      DiscussionPost(
        content: 'Lets organize a community clean-up drive for next weekend. Our park needs some attention.',
        author: 'Lisa P.',
        dateTime: 'May 7, 2025 • 2:00 PM',
        likes: 15,
        comments: 7,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of your build method is unchanged)
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
    // ... (this method is unchanged)
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // ... (this method is unchanged)
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
          // Listen to the 'reports' collection, order by timestamp
          stream: FirebaseFirestore.instance
              .collection('reports')
              .orderBy('timestamp', descending: true) // Order by server timestamp
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('StreamBuilder error: ${snapshot.error}'); // For debugging
              return Center(child: Text('Something went wrong! ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No reports yet. Be the first to submit!'));
            }

            // Map Firestore documents to Report objects
            final reports = snapshot.data!.docs
                .map((doc) => Report.fromFirestore(doc))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 80), // Keep padding for FAB
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
                // Navigate to SubmitReportScreen
                final newReportFromSubmitScreen = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubmitReportScreen(),
                  ),
                );

                // This local update is for optimistic UI update.
                // The StreamBuilder will eventually pick up the change from Firestore.
                if (newReportFromSubmitScreen != null && newReportFromSubmitScreen is Report) {
                  // No need to manually add to a local list if StreamBuilder is handling it.
                  // However, if SubmitReportScreen returns the Report object *after* it's
                  // successfully saved to Firestore, then Firestore will trigger the stream.
                  // If it returns *before* saving, then this optimistic update is useful
                  // until the stream catches up.
                  // For now, we'll assume SubmitReportScreen ensures data is in Firestore
                  // or the UI can wait for the stream.
                  // setState(() {
                  //   // _reports.insert(0, newReportFromSubmitScreen); // Not needed with StreamBuilder
                  // });
                }
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
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ... (Keep _buildAlertTab, _buildDiscussionTab, _buildReportCard, _buildAlertCard, _buildDiscussionPostCard, _getStatusColor, and dispose as they are)
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

  Widget _buildDiscussionTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: _discussionPosts.length,
            itemBuilder: (context, index) {
              final post = _discussionPosts[index];
              return _buildDiscussionPostCard(post);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Write your thought',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _discussionController, // Use the controller
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts with the community...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_discussionController.text.isNotEmpty) {
                        final newPost = DiscussionPost(
                          content: _discussionController.text,
                          author: 'Current User', // Replace with actual user later
                          dateTime: DateFormat('MMM d, yyyy • hh:mm a').format(DateTime.now()),
                        );
                        setState(() {
                          _discussionPosts.insert(0, newPost);
                          _discussionController.clear(); // Clear the TextField
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Post'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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
              ),
            ),
            const SizedBox(height: 12),
            Text(report.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: report.tags.map((tag) => Chip(
                label: Text(tag),
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
              ),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: tags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionPostCard(DiscussionPost post) { 
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
            Text(
              post.content, 
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${post.author} • ${post.dateTime}', 
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined),
                  onPressed: () {
                    setState(() {
                      post.likes++;
                    });
                  },
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text('${post.likes}'),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {},
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text('${post.comments}'),
              ],
            ),
          ],
        ),
      ),
    );
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
    super.dispose();
  }
}
