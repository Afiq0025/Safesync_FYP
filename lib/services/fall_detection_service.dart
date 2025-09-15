import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // For @required
import 'package:sensors_plus/sensors_plus.dart';

class FallDetectionService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  static const double _fallThreshold = 25.0; // m/s^2, adjust as needed
  bool _isFallCooldown = false;
  Timer? _fallCooldownTimer;
  static const Duration _fallCooldownDuration = Duration(seconds: 5); // Cooldown after a fall is detected

  final Function(DateTime) onFallDetected;

  FallDetectionService({
    required this.onFallDetected,
  });

  void initAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      double x = event.x;
      double y = event.y;
      double z = event.z;
      double accelerationMagnitude = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));
      // final int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;

      // Log all magnitudes for debugging
      // debugPrint('FallDetectionService: Current acceleration magnitude: $accelerationMagnitude m/s^2');

      // --- Fall Detection Logic ---
      bool potentialFallMagnitude = accelerationMagnitude > _fallThreshold;

      if (potentialFallMagnitude) {
        if (_isFallCooldown) {
          // debugPrint('FallDetectionService: Potential fall magnitude ($accelerationMagnitude m/s^2), but already in fall cooldown.');
        } else {
          debugPrint('FallDetectionService: Potential fall detected! Magnitude: $accelerationMagnitude');
          onFallDetected(DateTime.now());
          _isFallCooldown = true; // Activate fall cooldown
          _fallCooldownTimer?.cancel();
          _fallCooldownTimer = Timer(_fallCooldownDuration, () {
            debugPrint('FallDetectionService: Fall cooldown finished.');
            _isFallCooldown = false;
          });
        }
      }
    });
  }

  void dispose() {
    _accelerometerSubscription?.cancel();
    _fallCooldownTimer?.cancel();
  }
}
