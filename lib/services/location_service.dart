import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isSharing = false;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("LocationService: Location services are disabled. Please enable the services");
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("LocationService: Location permissions are denied");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("LocationService: Location permissions are permanently denied, we cannot request permissions.");
      return false;
    }
    return true;
  }

  Future<void> startSharingLocation() async {
    // Log instance hash and initial state
    debugPrint("LocationService: startSharingLocation() called. Instance hash: ${this.hashCode}. Current _isSharing status: $_isSharing");

    if (_isSharing) {
      debugPrint("LocationService (hash: ${this.hashCode}): startSharingLocation attempted, but _isSharing was already true.");
      return;
    }

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      debugPrint("LocationService (hash: ${this.hashCode}): No permission to access location for startSharingLocation.");
      return;
    }

    if (currentUser == null) {
      debugPrint("LocationService (hash: ${this.hashCode}): User not logged in. Cannot start sharing location.");
      return;
    }

    _isSharing = true; // Set flag first
    debugPrint("LocationService (hash: ${this.hashCode}): Set _isSharing to true for user ${currentUser!.uid}");

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (_isSharing) {
         debugPrint("LocationService (hash: ${this.hashCode}): Got initial position for ${currentUser!.uid}");
        _updateUserLocationInFirestore(position);
      } else {
        debugPrint("LocationService (hash: ${this.hashCode}): _isSharing became false before initial position update could be sent.");
      }
    } catch (e) {
      debugPrint("LocationService (hash: ${this.hashCode}): Error getting initial position: $e");
    }

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    await _positionStreamSubscription?.cancel(); // Cancel any existing before starting new
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        if (position != null && _isSharing) {
          debugPrint("LocationService (hash: ${this.hashCode}): Stream sent new position for ${currentUser?.uid}. _isSharing: $_isSharing");
          _updateUserLocationInFirestore(position);
        } else if (position != null && !_isSharing) {
          debugPrint("LocationService (hash: ${this.hashCode}): Stream sent new position, but _isSharing is false. Update skipped.");
        }
      },
      onError: (error) {
        debugPrint("LocationService (hash: ${this.hashCode}): Error in location stream: $error");
      }
    );
    debugPrint("LocationService (hash: ${this.hashCode}): Location stream started. _isSharing: $_isSharing. Stream is null: ${_positionStreamSubscription == null}");
  }

  Future<void> _updateUserLocationInFirestore(Position position) async {
    // Added instance hash for consistency in logging, though not strictly necessary here if stop/start are main concerns
    debugPrint("LocationService (hash: ${this.hashCode}): _updateUserLocationInFirestore called. _isSharing is: $_isSharing, User: ${currentUser?.uid}");

    if (currentUser == null) {
      debugPrint("LocationService (hash: ${this.hashCode}): Update to Firestore blocked because currentUser is null.");
      return;
    }
    if (!_isSharing) {
      debugPrint("LocationService (hash: ${this.hashCode}): Update to Firestore blocked because _isSharing is false.");
      return;
    }

    String userId = currentUser!.uid;
    GeoPoint userLocation = GeoPoint(position.latitude, position.longitude);

    try {
      await _firestore.collection('user_live_locations').doc(userId).set({
        'location': userLocation,
        'lastUpdated': Timestamp.now(),
        'userId': userId,
        'userEmail': currentUser!.email,
        'isSharing': true, 
      }, SetOptions(merge: true));
      debugPrint("LocationService (hash: ${this.hashCode}): Updated location for $userId to Firestore. (isSharing was true during this update)");
    } catch (e) {
      debugPrint("LocationService (hash: ${this.hashCode}): Error updating location to Firestore: $e");
    }
  }

  Future<void> stopSharingLocation() async {
    // Log instance hash and initial state
    debugPrint("LocationService: stopSharingLocation() called. Instance hash: ${this.hashCode}. Current _isSharing status: $_isSharing");

    if (!_isSharing) {
      debugPrint("LocationService (hash: ${this.hashCode}): stopSharingLocation attempted, but _isSharing was already false.");
      return;
    }

    // Set _isSharing to false as early as possible after the initial check.
    _isSharing = false; 
    debugPrint("LocationService (hash: ${this.hashCode}): _isSharing IMMEDIATELY set to false.");

    // Now, attempt to cancel the stream.
    try {
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null; 
      debugPrint("LocationService (hash: ${this.hashCode}): Stream cancelled and set to null. _isSharing is $_isSharing (should be false).");
    } catch (e) {
      debugPrint("LocationService (hash: ${this.hashCode}): Error during _positionStreamSubscription.cancel(): $e");
    }

    // Update Firestore
    if (currentUser != null) {
      String userId = currentUser!.uid;
      try {
        await _firestore.collection('user_live_locations').doc(userId).update({
          'isSharing': false, 
          'lastUpdated': Timestamp.now(),
        });
        debugPrint("LocationService (hash: ${this.hashCode}): Marked user $userId as not sharing (isSharing: false) in Firestore.");
      } catch (e) {
        debugPrint("LocationService (hash: ${this.hashCode}): Error updating 'isSharing' to false in Firestore: $e");
      }
    } else {
      debugPrint("LocationService (hash: ${this.hashCode}): currentUser is null in stopSharingLocation, cannot update Firestore 'isSharing' field.");
    }
  }

  bool isCurrentlySharing() {
    return _isSharing;
  }
}
