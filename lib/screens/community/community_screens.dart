import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF5A5A), Color(0xFFFF8A8A)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Latest Reports', 0, Icons.warning),
                    _buildTabButton('Nearby Alerts', 1, Icons.location_on),
                    _buildTabButton('Discussions', 2, Icons.chat),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _buildTabContent(),
                ),
              ),
              if (selectedTab == 2)
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Write your thought.....',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Icon(Icons.edit, color: Colors.grey),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index, IconData icon) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF5A5A) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 5),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 0:
        return _buildLatestReports();
      case 1:
        return _buildNearbyAlerts();
      case 2:
        return _buildDiscussions();
      default:
        return _buildLatestReports();
    }
  }

  Widget _buildLatestReports() {
    return SingleChildScrollView(
      child: Column(
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
            'Break-In Attempt',
            'May 6, 2025 • 7:40 PM | Jalan Reko',
            'Someone tried opening my gate while I was out. Neighbor\'s CCTV caught it.',
            'Verified',
            ['Break-In', 'Residential'],
            '@securehome88',
          ),
          _buildReportCard(
            'Vandalism at Park Playground',
            'May 6, 2025 • 6:00 PM | Taman Mesra',
            'Broken swings and spray paint found on the slide. Reported by local resident.',
            'Unverified',
            ['Vandalism', 'Public Area'],
            '@communitywatch',
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyAlerts() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAlertCard(
            'Accident Ahead',
            'Active Since: 8:00 PM | 600m from you',
            'Traffic accident reported near Jalan Reko traffic light',
            'Medium',
            Colors.orange,
          ),
          _buildAlertCard(
            'Fire detected near Taman Mesra',
            'Active Since: 5:15 PM | 800m from you',
            'Thick smoke reported from an abandoned factory building. Fire department is responding.',
            'High',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussions() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDiscussionCard(
            '@SafeWalker22',
            '8h',
            'What\'s the safest jogging route around here?',
            'I\'m new to the area--any tips for well-lit or well-patrolled paths?',
            4,
            4,
            4,
          ),
          _buildDiscussionCard(
            '@NightOwl',
            '8h',
            'Community patrol volunteers?',
            'Thinking of organizing a weekend watch group. Who\'s in?',
            4,
            4,
            4,
          ),
          _buildDiscussionCard(
            '@ConcernedResident',
            '8h',
            'Strangers knocking on doors at night',
            'Two men were knocking randomly on houses asking vague questions. Anyone else experienced this?',
            0,
            0,
            0,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String datetime, String description,
      String status, List<String> tags, String reporter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            datetime,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Status: $status | Tags: ',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              ...tags.map((tag) => Text(
                    '[$tag] ',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  )),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Reported by: $reporter',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String title, String time, String description,
      String urgency, Color urgencyColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Urgency: ',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: urgencyColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  urgency,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text(
                '[View on Map] [Save Alert]',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionCard(String username, String time, String title,
      String content, int likes, int comments, int shares) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey[400],
                child: Icon(Icons.person, size: 15, color: Colors.grey[600]),
              ),
              const SizedBox(width: 10),
              Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(content),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildInteractionButton(Icons.favorite_border, likes),
              const SizedBox(width: 20),
              _buildInteractionButton(Icons.comment, comments),
              const SizedBox(width: 20),
              _buildInteractionButton(Icons.share, shares),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 5),
        Text(
          count.toString(),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}
