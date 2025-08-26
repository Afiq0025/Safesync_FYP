import 'package:flutter/material.dart';
import 'submit_report.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _currentTab = 0; // 0: Report, 1: Alert, 2: Discussion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B6B),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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

            // Tab Navigation
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
            
            // Content
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
        ListView(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 80), // Bottom padding for floating button
          children: [
        _buildReportCard(
          'Suspicious Vehicle Spotted',
          'May 6, 2025 • 9:15 PM | Taman Kajang Utama',
          'A black van was parked for hours with the engine running. No clear activity.',
          'Unverified',
          ['Suspicious', 'Night'],
          'Anonymous',
        ),
        _buildReportCard(
          'Break-in Attempt',
          'May 5, 2025 • 2:30 AM | Jalan Bukit',
          'Heard someone trying to force open the back door. Dog barked and scared them away.',
          'Verified',
          ['Break-in', 'Night'],
          'Sarah L.',
        ),
        _buildReportCard(
          'Gathering of Suspicious Individuals',
          'May 4, 2025 • 7:45 PM | Near Shell Station',
          'Group of 5-6 men hanging around for 2+ hours, making residents uncomfortable.',
          'Under Investigation',
          ['Suspicious', 'Group'],
          'Mike T.',
        ),
          ],
        ),
        // Floating Submit Report Button
        Positioned(
          bottom: 15,
          left: 15,
          right: 15,
          child: Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
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

  Widget _buildDiscussionTab() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        _buildDiscussionPost(
          'Need more street lights on Jalan Bukit',
          'Sarah L. • 2 hours ago',
          'There have been multiple incidents on this street. We need better lighting for safety.',
          12,
          5,
        ),
        _buildDiscussionPost(
          'Suspicious vehicle license plate number',
          'Mike T. • 4 hours ago',
          'Managed to get the plate number of that black van: ABC 1234. Should we report to police?',
          8,
          3,
        ),
        const SizedBox(height: 20),
        
        // Write your thought section
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
                    onPressed: () {},
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

  Widget _buildReportCard(String title, String subtitle, String description, String status, List<String> tags, String author) {
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
              crossAxisAlignment: CrossAxisAlignment.start, // Added for better alignment if title wraps
              children: [
                Expanded( // Wrapped the Text widget with Expanded
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Added some spacing
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
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
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: tags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: Colors.grey[200],
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Reported by: $author',
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
                Expanded( // Also wrapped title here for consistency and safety
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Added some spacing
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

  Widget _buildDiscussionPost(String title, String author, String content, int likes, int comments) {
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
            Text( // Consider wrapping this with Expanded if titles can be very long
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              author,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(content),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined),
                  onPressed: () {},
                  iconSize: 20,
                ),
                Text('$likes'),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {},
                  iconSize: 20,
                ),
                Text('$comments'),
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
}
