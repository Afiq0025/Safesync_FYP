import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:safesync/services/permission_service.dart';
import 'package:gal/gal.dart'; // Added for saving to gallery

class VideoRecordingService {
  CameraController? _cameraController;
  final ValueNotifier<bool> isRecording = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isReady = ValueNotifier<bool>(false);
  Timer? _recordingTimer;

  // Public getter to expose the CameraController
  CameraController? get cameraController => _cameraController;

  Future<void> initCamera() async {
    if (isReady.value || _cameraController != null) return; // Already initialized or in process

    if (!await PermissionService.isCameraPermissionGranted() ||
        !await PermissionService.isMicrophonePermissionGranted()) {
      debugPrint("VideoRecordingService: Camera or microphone permissions not granted.");
      isReady.value = false;
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("VideoRecordingService: No cameras available.");
        isReady.value = false;
        return;
      }
      final firstCamera = cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      isReady.value = true;
      debugPrint("VideoRecordingService: Camera initialized and ready.");
    } catch (e) {
      debugPrint("Error initializing camera: $e");
      isReady.value = false;
      _cameraController = null; // Ensure controller is null on error
    }
  }

  Future<void> startVideoRecording({int durationInSeconds = 30}) async {
    if (isRecording.value) {
      debugPrint("VideoRecordingService: Already recording.");
      return;
    }

    // Lazily initialize camera if not ready. This will now run on every
    // recording after the first one has completed and been disposed.
    if (!isReady.value) {
      debugPrint("VideoRecordingService: Camera not ready. Initializing now...");
      await initCamera();
      if (!isReady.value) {
        debugPrint("VideoRecordingService: Failed to initialize camera. Aborting recording.");
        return;
      }
    }
    
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      debugPrint("VideoRecordingService: Camera controller is not available after initialization.");
      return;
    }

    try {
      await _cameraController!.startVideoRecording();
      isRecording.value = true;
      debugPrint("VideoRecordingService: Started recording.");

      _recordingTimer = Timer(Duration(seconds: durationInSeconds), () {
        stopVideoRecording();
      });
    } on CameraException catch (e) {
      debugPrint("Error starting video recording: $e");
      isRecording.value = false;
    }
  }

  Future<void> stopVideoRecording() async {
    if (!isRecording.value || _cameraController == null) {
      return;
    }

    _recordingTimer?.cancel();

    try {
      final XFile tempVideoFile = await _cameraController!.stopVideoRecording();
      debugPrint("VideoRecordingService: Stopped recording, now saving file...");

      // Save the file
      final List<Directory>? externalDirs = await getExternalStorageDirectories();
      if (externalDirs == null || externalDirs.isEmpty) {
        debugPrint("❌ Video save failed. Could not find external storage directory.");
        return; // Exits function, finally block will still run.
      }
      final Directory appDir = externalDirs.first;
      final Directory saveDir = Directory(path.join(appDir.path, 'SafeSync'));
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String newPath = path.join(saveDir.path, fileName);
      await tempVideoFile.saveTo(newPath);
      debugPrint("✅ Video saved successfully to app-specific directory: $newPath");

      // Save to gallery
      final bool hasGalleryAccess = await Gal.requestAccess();
      if (hasGalleryAccess) {
        try {
          await Gal.putVideo(newPath);
          debugPrint("✅ Video also saved to gallery.");
        } catch (galError) {
          debugPrint("❌ Error saving video to gallery with Gal.putVideo: $galError");
        }
      } else {
        debugPrint("⚠️ Gal permission not granted, video not saved to gallery.");
      }
    } catch (e) {
      debugPrint("Error during video stop or save: $e");
    } finally {
      isRecording.value = false;
      debugPrint("VideoRecordingService: Recording stopped. Disposing controller to ensure clean state for next use.");
      // Dispose the controller and reset state.
      // This ensures a fresh controller is created for the next recording.
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }
      isReady.value = false;
    }
  }

  void dispose() {
    _recordingTimer?.cancel();
    if (_cameraController != null) {
      _cameraController!.dispose();
      _cameraController = null;
    }
    isRecording.dispose();
    isReady.dispose();
  }

  void handleEmergencyTrigger() {
    startVideoRecording();
  }
}
