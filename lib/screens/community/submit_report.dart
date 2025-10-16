import 'package:flutter/material.dart';
import 'package:safesync/screens/community/report.dart'; // Existing import
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firebase
import 'package:firebase_auth/firebase_auth.dart'; // Added for Firebase Auth
import 'package:geolocator/geolocator.dart'; // Added for location services
import 'package:geocoding/geocoding.dart'; // Added for converting coordinates to address

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({Key? key}) : super(key: key);

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  
  String selectedDate = 'Jun 10, 2024'; 
  String selectedTime = '9:41 AM'; 
  
  List<String> selectedTags = [];
  
  final List<String> availableTags = [
    'Theft', 'Suspicion', 'Burglary', 'Break-in',
    'Vandalism', 'Assault', 'Noise', 'Traffic',
    'Emergency', 'Missing Person', 'Fire', 'Night', 'Safety Hazard', 'Suggestion'
  ];

  bool _isSubmitting = false; // To prevent multiple submissions

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = '${_getMonthName(now.month)} ${now.day}, ${now.year}';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          selectedTime = TimeOfDay.fromDateTime(now).format(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B6B),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 350;
            final padding = EdgeInsets.all(isSmallScreen ? 12.0 : 20.0);
            final cardPadding = EdgeInsets.all(isSmallScreen ? 16.0 : 20.0);
            final fontSize = isSmallScreen ? 14.0 : 16.0;
            final titleFontSize = isSmallScreen ? 20.0 : 24.0;
            final spacing = isSmallScreen ? 12.0 : 16.0;

            return Column(
              children: [
                Padding(
                  padding: padding,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: isSmallScreen ? 24.0 : 28.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: padding,
                      child: Container(
                        width: double.infinity,
                        padding: cardPadding,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isSmallScreen ? 20 : 25),
                            topRight: Radius.circular(isSmallScreen ? 20 : 25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submit Report',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: spacing),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 12 : 15,
                                        vertical: isSmallScreen ? 12 : 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                                      ),
                                      child: Text(
                                        selectedDate,
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                          fontSize: fontSize,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 8 : 15),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectTime(context),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 12 : 15,
                                        vertical: isSmallScreen ? 12 : 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                                      ),
                                      child: Text(
                                        selectedTime,
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                          fontSize: fontSize,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: spacing),
                            Text(
                              'Title',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: spacing * 0.5),
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText: 'Enter report title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                                ),
                              ),
                              style: TextStyle(fontSize: fontSize),
                            ),
                            SizedBox(height: spacing),
                            Text(
                              'Category',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: spacing * 0.5),
                            TextField(
                              controller: _categoryController,
                              decoration: InputDecoration(
                                hintText: 'E.g., Safety Concern, Suspicious Activity',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                                ),
                              ),
                              style: TextStyle(fontSize: fontSize),
                            ),
                            SizedBox(height: spacing),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: spacing * 0.5),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Describe the incident',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                                ),
                              ),
                              style: TextStyle(fontSize: fontSize),
                            ),
                            SizedBox(height: spacing),
                            Text(
                              'Tags',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: spacing * 0.5),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: availableTags.map((tag) {
                                bool isSelected = selectedTags.contains(tag);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedTags.remove(tag);
                                      } else {
                                        selectedTags.add(tag);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 12 : 15,
                                      vertical: isSmallScreen ? 8 : 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue : Colors.blue[50],
                                      borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.blue,
                                        fontWeight: FontWeight.w500,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: spacing * 2),
                            Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitReport, // Disable button while submitting
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                      )
                                    : const Text(
                                        'Submit Report',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: spacing),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = '${_getMonthName(picked.month)} ${picked.day}, ${picked.year}';
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        selectedTime = picked.format(context);
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

 Future<String> _getCurrentLocationString() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled. Please enable them.')),
        );
      }
      return 'Location services disabled';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
        }
        return 'Location permissions denied';
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')),
        );
      }
      return 'Location permissions permanently denied';
    } 

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Collect potential address parts (which can be String?)
        List<String?> potentialParts = [
          place.street,
          place.locality,
          // place.subLocality, // You can add other parts if needed
          place.postalCode,
          place.country
        ];

        // Filter out nulls and empty strings, then join.
        List<String> validParts = potentialParts
            .where((part) => part != null && part.isNotEmpty)
            .cast<String>() 
            .toList();
        
        String address = validParts.join(', ');
        
        return address.isEmpty ? "Near current location (details unavailable)" : address;
      } else {
        return "Current location (address unavailable)";
      }
    } catch (e) {
      print("Error getting location: $e");
      return "Could not fetch location";
    }
  }

  Future<void> _submitReport() async {
    if (_titleController.text.isEmpty || 
        _descriptionController.text.isEmpty ||
        _categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields: Title, Category, and Description.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit a report.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final String userName = currentUser.displayName ?? currentUser.email ?? 'Anonymous User';
    final String userId = currentUser.uid;
    final String combinedDateTime = '$selectedDate • $selectedTime';
    final String locationString = await _getCurrentLocationString(); // Fetch location

    try {
      Map<String, dynamic> reportData = {
        'userId': userId,
        'fullName': userName,
        'reportTitle': _titleController.text,
        'reportDescription': _descriptionController.text,
        'category': _categoryController.text,
        'tags': List<String>.from(selectedTags),
        'locationString': locationString, // Use fetched location
        'submittedDateTimeString': combinedDateTime,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'unverified',
        'adminNotes': '',
      };

      await FirebaseFirestore.instance.collection('reports').add(reportData);

      final newReportForUI = Report(
        title: _titleController.text,
        description: _descriptionController.text,
        dateTime: combinedDateTime,
        tags: List<String>.from(selectedTags),
        location: locationString, // Use fetched location
        status: 'unverified',
        author: userName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, newReportForUI);
      }

    } catch (e) {
      print('Error submitting report: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
