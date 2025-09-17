import 'package:flutter/material.dart';
import 'package:safesync/screens/community/report.dart'; // Added import

// Report class definition removed from here

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({Key? key}) : super(key: key);

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // TODO: Add a TextEditingController for location if you want to make it an input field
  // final TextEditingController _locationController = TextEditingController();
  
  String selectedDate = 'Jun 10, 2024';
  String selectedTime = '9:41 AM';
  
  List<String> selectedTags = [];
  
  final List<String> availableTags = [
    'Theft', 'Suspicion', 'Burglary', 'Break-in',
    'Vandalism', 'Assault', 'Noise', 'Traffic',
    'Emergency', 'Missing Person', 'Fire', 'Night'
  ];

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
                // Header with back button
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
                
                // Main content
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
                            // Title
                            Text(
                              'Submit Report',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: spacing),
                            
                            // Date and Time Row
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
                            
                            // Title field
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
                            
                            // Description field
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
                            
                            // Tags
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
                            
                            SizedBox(height: spacing),
                            
                            // Submit button
                            Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _submitReport();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Submit report',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
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
    if (picked != null) {
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

  void _submitReport() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newReport = Report(
      title: _titleController.text,
      description: _descriptionController.text,
      dateTime: '$selectedDate • $selectedTime', // Using a bullet for separator
      tags: List<String>.from(selectedTags), // Create a new list from selectedTags
      location: 'Unknown Location', // Added default location
      status: 'Unverified', author: '', // Added default status
      // author: 'Me', // Defaulted in class
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context, newReport); // Pass the new report back
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    // _locationController.dispose(); // If you add a location field
    super.dispose();
  }
}
