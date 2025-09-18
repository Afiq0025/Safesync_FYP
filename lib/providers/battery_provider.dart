// lib/providers/battery_provider.dart
import 'package:flutter/foundation.dart';

class BatteryProvider extends ChangeNotifier {
  int _batteryLevel = 0;
  int get batteryLevel => _batteryLevel;

  void updateBattery(int value) {
    _batteryLevel = value;
    notifyListeners();
  }
}
