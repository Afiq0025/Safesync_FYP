import 'package:flutter/material.dart';

class DiscussionScreen extends StatelessWidget {
  const DiscussionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        _buildDiscussionPost(
          '@SafeWalker22',
          '8h',
          'What\'s the safest jogging route around here?',
          'I\'m new to the area—any tips for well-lit or well-patrolled paths?',
          4,
          4,
          4,
        ),
        const SizedBox(height: 15),
        _buildDiscussionPost(
          '@NightOwl',
          '8h',
          'Community patrol volunteers?',
          'Thinking of organizing a weekend watch group. Who\'s in?',
          4,
          4,
          4,
        ),
        const SizedBox(height: 15),
        _buildDiscussionPost(
          '@ConcernedResident',
          '8h',
          'Strangers knocking on doors at night',
          'Two men were knocking randomly on houses asking vague questions. Anyone else experienced this?',
          0,
          0,
          0,
        ),
        const SizedBox(height: 15),

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

  Widget _buildDiscussionPost(String username, String time, String title, String content, int likes, int comments, int shares) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.w600),
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('$likes'),
              const SizedBox(width: 15),
              Icon(Icons.comment, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('$comments'),
              const SizedBox(width: 15),
              Icon(Icons.share, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('$shares'),
            ],
          ),
        ],
      ),
    );
  }
}
