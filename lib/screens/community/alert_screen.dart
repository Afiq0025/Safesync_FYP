import 'package:flutter/material.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({Key? key}) : super(key: key);

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B6B), // Same as ReportScreen
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(15),
              child: const Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    'Alerts', // Updated title
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
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
                  // Example from original alert_screen.dart, adapted
                  _buildAlertCard(
                    'Accident Ahead',
                    'Jalan Reko traffic light', // Simplified location
                    'Traffic accident reported near Jalan Reko traffic light. Active Since: 8:00 PM | 600m from you',
                    'Medium',
                    ['Traffic', 'Accident'],
                  ),
                  _buildAlertCard(
                    'Fire Detected',
                    'Near Taman Mesra', // Simplified location
                    'Thick smoke reported from an abandoned factory building. Fire department is responding. Active Since: 5:15 PM | 800m from you',
                    'High',
                    ['Fire', 'Emergency'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusing _buildAlertCard from report_screen.dart structure
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
                color: Colors.red, // Consistent with report_screen's alert card
              ),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: tags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: Colors.white, // Consistent
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Reusing _getStatusColor (though not directly used by _buildAlertCard,
  // it's good practice to keep helper functions if they might be used or for consistency)
  // However, _buildAlertCard uses urgency directly for color, so this might not be strictly needed here.
  // For now, I'll keep it as it's part of the "template" from report_screen.
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'under investigation':
        return Colors.orange;
      case 'unverified':
        return Colors.grey;
      // Added cases for alert urgency, though _buildAlertCard handles its own color
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
