import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class VoiceRecognitionService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;
  bool _isHandlingEmergency = false; // Debounce flag
  final VoidCallback onEmergencyPhraseDetected;
  final Function(bool) onStatusChanged; // Callback to update UI

  // The keywords to trigger the emergency
  final List<String> _emergencyKeywords = ["help", "tulong", "tolong", "too long"];

  VoiceRecognitionService({
    required this.onEmergencyPhraseDetected,
    required this.onStatusChanged,
  });

  bool get isListening => _isListening;

  Future<void> initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: _statusListener,
        onError: (error) => debugPrint("Speech Error: $error"),
        debugLogging: true, // More verbose logging
      );
      debugPrint("Speech recognition initialized: $_speechEnabled");
    } catch (e) {
      debugPrint("Error initializing speech recognition: $e");
      _speechEnabled = false;
    }
    onStatusChanged(_isListening);
  }

  void startListening() {
    if (!_speechEnabled || _isListening) return;
    debugPrint("VoiceRecognitionService: Starting to listen...");
    _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 20),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: false, // Keep listening even on errors
        onDevice: true, // Use on-device recognition if possible
        listenMode: ListenMode.dictation, // Better for keyword spotting
      ),
    );
    _isListening = true;
    onStatusChanged(_isListening);
  }

  void stopListening() {
    if (!_isListening) return;
    debugPrint("VoiceRecognitionService: Stopping listening.");
    _speechToText.stop();
    _isListening = false;
    onStatusChanged(_isListening);
  }

  /// Callback for speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    String recognizedWords = result.recognizedWords.toLowerCase();
    debugPrint("Recognized words: $recognizedWords");

    if (_isHandlingEmergency) return; // Don't process if in cooldown

    for (final keyword in _emergencyKeywords) {
      if (recognizedWords.contains(keyword)) {
        debugPrint("EMERGENCY PHRASE '$keyword' DETECTED! Starting cooldown.");
        _isHandlingEmergency = true;
        onEmergencyPhraseDetected();
        
        // Cooldown period to prevent multiple triggers
        Timer(const Duration(seconds: 10), () {
          debugPrint("Cooldown finished. Ready to detect again.");
          _isHandlingEmergency = false;
        });
        break; // Exit loop once a keyword is found
      }
    }
  }

  /// Listener for the speech recognition status
  void _statusListener(String status) {
    debugPrint("Speech status: $status");
    if (status == 'notListening' && _isListening) {
      // If listening was unexpectedly stopped (e.g. timeout), restart it.
      debugPrint("Listener stopped, restarting...");
      // A small delay to avoid rapid-fire restarts
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isListening) { // Check if the user hasn't manually stopped it
          startListening();
        }
      });
    } else if (status == 'listening') {
      _isListening = true;
      onStatusChanged(_isListening);
    }
  }

  void dispose() {
    _speechToText.cancel();
    _isListening = false;
  }
}
