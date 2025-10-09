import 'package:flutter/material.dart';

class FakeCallPage extends StatefulWidget {
  // A field to hold the dynamic station name.
  final String stationName;

  // The constructor now accepts a station name, with a default value for fallback.
  const FakeCallPage({
    super.key,
    this.stationName = 'Nearby Police Station', // Default value
  });

  @override
  State<FakeCallPage> createState() => _FakeCallPageState();
}

class _FakeCallPageState extends State<FakeCallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.call,
              color: Colors.green,
              size: 80.0,
            ),
            const SizedBox(height: 20),
            // The Text widget now uses the stationName passed to the widget.
            Text(
              'Calling ${widget.stationName}...',
              textAlign: TextAlign.center, // Good for potentially long names
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Connecting...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'End Call',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
