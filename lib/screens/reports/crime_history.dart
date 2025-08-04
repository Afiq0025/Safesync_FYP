import 'package:flutter/material.dart';

class CrimeHistoryScreen extends StatelessWidget {
  const CrimeHistoryScreen({super.key});

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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Crime History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You are now at Kajang, Selangor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text(
                          'Crime history at your place',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        _buildCrimeStatistic('Theft', '1200', '780', '420'),
                        _buildCrimeStatistic('Burglary', '850', '510', '340'),
                        _buildCrimeStatistic('Assault', '450', '290', '160'),
                        _buildCrimeStatistic('Sexual Harassment', '250', '160', '90'),
                        _buildCrimeStatistic('Drug Offense', '600', '390', '210'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCrimeStatistic(String crime, String reported, String solved, String unsolved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            crime,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reported Cases', style: TextStyle(color: Colors.grey)),
              Text(reported, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Solved Cases', style: TextStyle(color: Colors.grey)),
              Text(solved, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Unsolved Cases', style: TextStyle(color: Colors.grey)),
              Text(unsolved, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(thickness: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }
}