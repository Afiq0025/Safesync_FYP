import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        _buildAlertCard(
          'Accident Ahead',
          'Active Since: 8:00 PM | 600m from you',
          'Traffic accident reported near Jalan Reko traffic light',
          'Medium',
          Colors.orange,
        ),
        const SizedBox(height: 15),
        _buildAlertCard(
          'Fire detected near Taman Mesra',
          'Active Since: 5:15 PM | 800m from you',
          'Thick smoke reported from an abandoned factory building. Fire department is responding.',
          'High',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildAlertCard(String title, String activeInfo, String description, String urgency, Color urgencyColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            activeInfo,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Urgency: $urgency',
                style: TextStyle(
                  color: urgencyColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  '[View on Map]',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  urgency == 'High' ? '[Mark as Safe]' : '[Save Alert]',
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
