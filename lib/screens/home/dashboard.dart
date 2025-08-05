import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
            // DO NOT mark this Column as const because it contains GestureDetector
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                  Row(
                    children: const [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(Icons.mic, color: Colors.black),
                      ),
                      SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(Icons.call, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Heart Rate Display
              Container(
                child: const Column(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '79 BpM',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Heart Rate - Normal',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Add Smartwatch image with tap navigation
              GestureDetector(
                onTap: () {
                  print('Smartwatch image tapped');
                  Navigator.pushNamed(context, '/smartwatch');
                },
                child: Image.asset(
                  'assets/images/watch.jpg',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              // Feature Icons Row
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.videocam, color: Colors.white, size: 30),
                      SizedBox(height: 5),
                      Text(
                        'Automatic\nRecording',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.watch, color: Colors.white, size: 30),
                      SizedBox(height: 5),
                      Text(
                        'Pair Smart\nDevices',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Feature Cards
              _buildFeatureCard(
                'Emergency Mode',
                'Triple press to activate',
                Icons.warning,
                context,
              ),
              const SizedBox(height: 15),
              _buildFeatureCard(
                'AI Voice Recognition',
                'Detects distress through voice commands',
                Icons.mic,
                context,
              ),
              const SizedBox(height: 15),
              _buildFeatureCard(
                'Auto Call',
                'Auto dials 999 if no response for 30 sec',
                Icons.phone,
                context,
              ),
              const SizedBox(height: 15),
              _buildFeatureCard(
                'Location Sharing',
                'Share real-time location',
                Icons.location_on,
                context,
              ),
              const SizedBox(height: 20),
              // Additional Status
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last Fall Detected : Never',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lockscreen Access',
                      style: TextStyle(color: Colors.white),
                    ),
                    Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, String subtitle, IconData icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
