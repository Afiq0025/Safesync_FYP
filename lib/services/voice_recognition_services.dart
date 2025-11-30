import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class VoiceRecognitionService {
  final SpeechToText _speechToText = SpeechToText();
  bool _userIntentToListen = false; // Flag for the user's desired state (button on/off)
  bool _speechEnabled = false;
  bool _isHandlingEmergency = false; // Debounce flag
  final VoidCallback onEmergencyPhraseDetected;
  final Function(bool) onStatusChanged;

  final List<String> _emergencyKeywords = ["help", "tulong", "tolong", "too long"];

  VoiceRecognitionService({
    required this.onEmergencyPhraseDetected,
    required this.onStatusChanged,
  });

  // Expose the user's intent, not the actual listening state of the plugin
  bool get isListening => _userIntentToListen;

  Future<void> initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: _statusListener,
        onError: (error) => debugPrint("Speech Error: $error"),
        debugLogging: true,
      );
      if (!_speechEnabled) {
        debugPrint("Speech recognition setup failed or permissions denied.");
        if (_userIntentToListen) {
          _userIntentToListen = false;
          onStatusChanged(false);
        }
      }
    } catch (e) {
      debugPrint("Error initializing speech recognition: $e");
      _speechEnabled = false;
       if (_userIntentToListen) {
          _userIntentToListen = false;
          onStatusChanged(false);
      }
    }
  }

  // Called by the UI to turn the feature ON.
  void startListening() {
    if (_userIntentToListen) return; // Already on.
    _userIntentToListen = true;
    onStatusChanged(true); // Update UI immediately
    _internalStartListening();
    debugPrint("VoiceRecognitionService: User toggled listening ON.");
  }

  // Called by the UI to turn the feature OFF.
  void stopListening() {
    if (!_userIntentToListen) return; // Already off.
    _userIntentToListen = false;
    _speechToText.stop(); // This will trigger the status listener to 'notListening'.
    onStatusChanged(false); // Update UI immediately
    debugPrint("VoiceRecognitionService: User toggled listening OFF.");
  }
  
  // Internal method to begin a single listening session.
  void _internalStartListening() {
    // Only start if the user wants to listen, speech is enabled, and it's not already listening.
    if (!_userIntentToListen || !_speechEnabled || _speechToText.isListening) return;
    
    debugPrint("VoiceRecognitionService: Starting a new listening session...");
    _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(minutes: 5), // Long duration
      pauseFor: const Duration(seconds: 5), // Time after speech before result is final
      listenOptions: SpeechListenOptions(
        partialResults: false, // Only process final results. This is more reliable.
        cancelOnError: false, // Let the status listener handle restarts.
        onDevice: false, // Use network for better accuracy.
        listenMode: ListenMode.search,
      ),
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    // We configured for final results only, but this is an extra safeguard.
    if (!result.finalResult) return;

    String recognizedWords = result.recognizedWords.toLowerCase();
    debugPrint("Recognized words (final): $recognizedWords");

    if (_isHandlingEmergency) return;

    for (final keyword in _emergencyKeywords) {
      final regex = RegExp(r'\b' + keyword + r'\b');
      if (regex.hasMatch(recognizedWords)) {
        debugPrint("EMERGENCY PHRASE '$keyword' DETECTED!");
        _isHandlingEmergency = true;
        onEmergencyPhraseDetected();
        
        Timer(const Duration(seconds: 10), () {
          debugPrint("Cooldown finished.");
          _isHandlingEmergency = false;
        });
        break; // Found a keyword, no need to check others.
      }
    }
  }

  void _statusListener(String status) {
    debugPrint("Speech status: $status");

    // When a listening session ends for any reason ('notListening' or 'done')...
    if (status == 'notListening' || status == 'done') {
      // ...and the user *still* wants to be listening (i.e., they haven't manually toggled it off)...
      if (_userIntentToListen) {
        debugPrint("Listener session ended, restarting in 1 second...");
        // ...restart it after a short delay to avoid spamming.
        Future.delayed(const Duration(seconds: 1), () {
          // Double-check the flag in case the user turned it off during the delay.
          if (_userIntentToListen) {
            _internalStartListening();
          }
        });
      }
    }
  }

  void dispose() {
    _userIntentToListen = false;
    _speechToText.cancel();
  }
}
