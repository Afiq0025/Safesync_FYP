import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // For @required and debugPrint
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectionService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Shake Detection Parameters
  static const double _shakeThreshold = 25.0; // m/s^2, acceleration threshold for a single shake event
  static const int _shakeCountThreshold = 3; // Number of shakes required to trigger
  static const int _shakeTimeWindowMillis = 2000; // Time window (ms) to detect _shakeCountThreshold shakes
  final List<int> _shakeTimestamps = []; // Stores timestamps of detected shake events

  bool _isShakeCooldownActive = false; // Cooldown for *subsequent* shakes
  Timer? _shakeCooldownTimer;
  static const Duration _shakeCooldownDuration = Duration(seconds: 10); // Cooldown period

  // Callbacks and getters
  final VoidCallback onShakeDetectedVigorous;
  final ValueGetter<bool> isEmergencyModeActive;

  ShakeDetectionService({
    required this.onShakeDetectedVigorous,
    required this.isEmergencyModeActive,
  });

  void initAccelerometer() {
    debugPrint("ShakeDetectionService: Initializing accelerometer...");
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {

      double x = event.x;
      double y = event.y;
      double z = event.z;
      double accelerationMagnitude = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));
      final int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;

      // Clean up old shake timestamps
      _shakeTimestamps
          .removeWhere((timestamp) => currentTimeMillis - timestamp > _shakeTimeWindowMillis);

      if (accelerationMagnitude > _shakeThreshold) {
        // Debounce individual shake events (e.g., ignore if too close to the last one)
        if (_shakeTimestamps.isEmpty ||
            (currentTimeMillis - _shakeTimestamps.last > 250)) { // 250ms debounce
          _shakeTimestamps.add(currentTimeMillis);
          debugPrint(
              'ShakeDetectionService: Shake event registered. Count: ${_shakeTimestamps.length}');
        }

        if (_shakeTimestamps.length >= _shakeCountThreshold) {
          if (!_isShakeCooldownActive && isEmergencyModeActive()) {
            debugPrint(
                'ShakeDetectionService: VIGOROUS SHAKE DETECTED and Emergency Mode is ON!');
            onShakeDetectedVigorous();
            _shakeTimestamps.clear(); // Clear timestamps: shake confirmed and processed

            // Activate shake cooldown to prevent immediate re-triggering
            _isShakeCooldownActive = true;
            _shakeCooldownTimer?.cancel();
            _shakeCooldownTimer = Timer(_shakeCooldownDuration, () {
              debugPrint('ShakeDetectionService: Shake cooldown finished.');
              _isShakeCooldownActive = false;
            });
          } else if (_isShakeCooldownActive) {
            debugPrint(
                'ShakeDetectionService: Shake detected, but in cooldown. Count: ${_shakeTimestamps.length}');
            // Do not clear timestamps here, let them expire or a new sequence start after cooldown
          } else if (!isEmergencyModeActive()) {
            debugPrint(
                'ShakeDetectionService: Shake detected, but Emergency Mode is OFF. Clearing timestamps. Count: ${_shakeTimestamps.length}');
            _shakeTimestamps.clear(); // Clear attempts if emergency mode is off
          }
        }
      }
    });
    debugPrint("ShakeDetectionService: Accelerometer subscription started.");
  }

  void dispose() {
    debugPrint("ShakeDetectionService: Disposing accelerometer subscription.");
    _accelerometerSubscription?.cancel();
    _shakeCooldownTimer?.cancel();
    debugPrint("ShakeDetectionService: Disposed.");
  }
}
