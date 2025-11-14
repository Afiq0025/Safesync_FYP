import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  String? _connectedDeviceId;

  final _connectionStateController = StreamController<DeviceConnectionState>.broadcast();
  Stream<DeviceConnectionState> get connectionStateStream => _connectionStateController.stream;

  String? get connectedDeviceId => _connectedDeviceId;
  bool get isConnected => _connectedDeviceId != null;

  Future<void> connectToDevice(String deviceId) async {
    await disconnectDevice(); 

    _connectionStateController.add(DeviceConnectionState.connecting);
    _connectionSubscription = _ble.connectToDevice(id: deviceId).listen(
      (update) {
        print('Connection state update: ${update.connectionState}');
        _connectionStateController.add(update.connectionState);
        if (update.connectionState == DeviceConnectionState.connected) {
          _connectedDeviceId = deviceId;
        } else {
          _connectedDeviceId = null;
        }
      },
      onError: (dynamic error) {
        print('Connection error: $error');
        _connectionStateController.add(DeviceConnectionState.disconnected);
      },
    );
  }

  Future<void> disconnectDevice() async {
    if (_connectionSubscription != null) {
      await _connectionSubscription!.cancel();
      _connectionSubscription = null;
      _connectedDeviceId = null;
      _connectionStateController.add(DeviceConnectionState.disconnected);
      print("Bluetooth device disconnected.");
    }
  }

  void dispose() {
    _connectionStateController.close();
  }
}
