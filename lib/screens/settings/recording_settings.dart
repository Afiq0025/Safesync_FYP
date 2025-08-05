import 'package:flutter/material.dart';

class RecordingSettingsScreen extends StatefulWidget {
  const RecordingSettingsScreen({Key? key}) : super(key: key);

  @override
  State<RecordingSettingsScreen> createState() => _RecordingSettingsScreenState();
}

class _RecordingSettingsScreenState extends State<RecordingSettingsScreen> {
  String selectedFps = 'Select Fps';
  String selectedResolution = 'Select Resolutions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF36060), // Coral red background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recording Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Main settings card
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FPS Section
                    const Text(
                      'Fps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownButton(
                      selectedFps,
                      ['30 FPS', '60 FPS', '120 FPS'],
                      (value) => setState(() => selectedFps = value!),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Graphic Section
                    const Text(
                      'Graphic',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownButton(
                      selectedResolution,
                      ['720p HD', '1080p Full HD', '4K Ultra HD'],
                      (value) => setState(() => selectedResolution = value!),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Storage Location Section
                    const Text(
                      'Storage Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '/Android/data/com.safesync.app/files/recordings/',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton(String currentValue, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(currentValue) ? currentValue : null,
          hint: Text(
            currentValue,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          isExpanded: true,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE57373) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey[600],
        size: 24,
      ),
    );
  }
}
