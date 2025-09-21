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
      // Optionally, prompt user to enable location services
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
      // Optionally, direct user to app settings
      return false;
    }
    return true;
  }

  Future<void> startSharingLocation() async {
    if (_isSharing) {
      debugPrint("LocationService: Already sharing location.");
      return;
    }

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      debugPrint("LocationService: No permission to access location.");
      return;
    }

    if (currentUser == null) {
      debugPrint("LocationService: User not logged in. Cannot share location.");
      return;
    }

    _isSharing = true;
    debugPrint("LocationService: Starting location sharing for user ${currentUser!.uid}");

    // Get initial position
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _updateUserLocationInFirestore(position);
    } catch (e) {
      debugPrint("LocationService: Error getting initial position: $e");
    }

    // Start listening to position updates
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Notify only when location changes by 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        if (position != null && _isSharing) {
          debugPrint("LocationService: Location update - Lat: ${position.latitude}, Lng: ${position.longitude}");
          _updateUserLocationInFirestore(position);
        }
      },
      onError: (error) {
        debugPrint("LocationService: Error in location stream: $error");
        stopSharingLocation(); // Stop sharing on stream error
      }
    );
    debugPrint("LocationService: User's location is now being actively shared via stream.");
  }

  Future<void> _updateUserLocationInFirestore(Position position) async {
    if (currentUser == null) return;

    String userId = currentUser!.uid;
    GeoPoint userLocation = GeoPoint(position.latitude, position.longitude);

    try {
      await _firestore.collection('user_live_locations').doc(userId).set({
        'location': userLocation,
        'lastUpdated': Timestamp.now(),
        'userId': userId,
        'userEmail': currentUser!.email, // Optional: for easier identification
        'isSharing': true,
      }, SetOptions(merge: true)); // Use merge to avoid overwriting other fields if any
      debugPrint("LocationService: Updated location for $userId to Firestore.");
    } catch (e) {
      debugPrint("LocationService: Error updating location to Firestore: $e");
    }
  }

  Future<void> stopSharingLocation() async {
    if (!_isSharing) {
      debugPrint("LocationService: Location sharing is not active.");
      return;
    }

    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isSharing = false;
    debugPrint("LocationService: Stopped location sharing for user ${currentUser?.uid}.");

    if (currentUser != null) {
      String userId = currentUser!.uid;
      try {
        // Option 1: Mark as not sharing
        await _firestore.collection('user_live_locations').doc(userId).update({
          'isSharing': false,
          'lastUpdated': Timestamp.now(), // Good to know when they stopped
        });
        debugPrint("LocationService: Marked user $userId as not sharing in Firestore.");

        // Option 2: Delete the document (if you don't need to keep a record of them ever sharing)
        // await _firestore.collection('user_live_locations').doc(userId).delete();
        // debugPrint("LocationService: Deleted location document for $userId from Firestore.");

      } catch (e) {
        debugPrint("LocationService: Error updating/deleting location status in Firestore: $e");
      }
    }
  }

  bool isCurrentlySharing() {
    return _isSharing;
  }
}
