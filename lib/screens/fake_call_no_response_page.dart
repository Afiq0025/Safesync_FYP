import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class FakeCallNoResponsePage extends StatefulWidget {
  final String stationName;

  const FakeCallNoResponsePage({
    super.key,
    this.stationName = 'Nearby Police Station',
  });

  @override
  State<FakeCallNoResponsePage> createState() => _FakeCallNoResponsePageState();
}

class _FakeCallNoResponsePageState extends State<FakeCallNoResponsePage> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    // Play the audio once the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playOperatorVoice();
    });
  }

  void _playOperatorVoice() async {
    try {
      // Corrected the path to your audio file in the assets
      await _audioPlayer.play(AssetSource('sounds/operator.mp3'));
      // Set the release mode to loop so the audio repeats
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  void dispose() {
    // Stop and dispose of the audio player to free up resources
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

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
            Text(
              'Calling ${widget.stationName}...',
              textAlign: TextAlign.center,
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
