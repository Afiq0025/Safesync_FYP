import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  static Future<void> requestAllPermissions() async {
    // Request permissions based on the platform and what's needed.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage, // General storage
      Permission.videos,  // Specific to videos for scoped storage
      Permission.audio,   // For audio recording
    ].request();

    // You can optionally check the status of each permission
    // and handle cases where the user denied the request.
    statuses.forEach((permission, status) {
      if (status.isDenied) {
        // Handle denied permissions if necessary
        print('$permission was denied');
      }
    });
  }

  static Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  static Future<bool> isMicrophonePermissionGranted() async {
    return await Permission.microphone.isGranted;
  }

  static Future<void> requestStoragePermission() async {
    // On modern Android (SDK 33+), you need to request specific media types.
    // On older versions, you might need the broader `storage` permission.
    // Requesting both is a safe approach.
    final statuses = await [Permission.storage, Permission.videos].request();

    if (statuses[Permission.storage]!.isPermanentlyDenied || statuses[Permission.videos]!.isPermanentlyDenied) {
      // The user has permanently denied the permission. Open app settings.
      openAppSettings();
    }
  }
}
