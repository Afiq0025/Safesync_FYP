import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final String bloodType;
  final String allergies;
  final String medicalConditions;
  final String medications;

  const ProfileScreen({
    Key? key,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.bloodType,
    required this.allergies,
    required this.medicalConditions,
    required this.medications,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, bool> expandedSections = {
    'address': false,
    'bloodType': false,
    'allergies': false,
    'medicalConditions': false,
    'medications': false,
  };

  @override
  Widget build(BuildContext context) {
    print('ProfileScreen build: Displaying Name: ${widget.name}, Phone: ${widget.phoneNumber}, Email: ${widget.email}, Address: ${widget.address}, BloodType: ${widget.bloodType}, Allergies: ${widget.allergies}, Conditions: ${widget.medicalConditions}, Medications: ${widget.medications}');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Header
            Column(
              children: [
                // Profile Picture
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Color(0xFF666666),
                  ),
                ),

                const SizedBox(height: 20),

                // Name
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Phone Number
                Text(
                  widget.phoneNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),

                const SizedBox(height: 4),

                // Email Address
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Expandable Sections using widget data
            _buildExpandableSection('Address', 'address', widget.address),
            const SizedBox(height: 12),

            _buildExpandableSection('Blood Type', 'bloodType', widget.bloodType),
            const SizedBox(height: 12),

            _buildExpandableSection('Allergies', 'allergies', widget.allergies),
            const SizedBox(height: 12),

            _buildExpandableSection(
                'Medical Conditions', 'medicalConditions', widget.medicalConditions),
            const SizedBox(height: 12),

            _buildExpandableSection('Medications', 'medications', widget.medications),

            const SizedBox(height: 60),

            // Log out button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, String key, String content) {
    bool isExpanded = expandedSections[key] ?? false;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: Radius.circular(isExpanded ? 0 : 15),
                bottomRight: Radius.circular(isExpanded ? 0 : 15),
              ),
              onTap: () {
                setState(() {
                  expandedSections[key] = !isExpanded;
                });
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF666666),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 18, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content, // Content is now from widget.X
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Log Out',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route<dynamic> route) => false);
              },
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
