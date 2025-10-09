import 'dart:async';
import 'dart:convert'; // Required for jsonDecode
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http; // Import the http package

class LocationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isSharing = false;

  // --- IMPORTANT: PASTE YOUR API KEY HERE ---
  final String _googleApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';

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

  Future<String> findNearestPoliceStation() async {
    debugPrint("LocationService: Attempting to find nearest police station.");
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission || _googleApiKey == 'YOUR_GOOGLE_PLACES_API_KEY') {
      debugPrint("LocationService: No location permission or API key is missing.");
      return "Nearby Police Station"; // Fallback name
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      debugPrint("LocationService: Got user position: Lat: ${position.latitude}, Lng: ${position.longitude}");

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=5000&type=police&key=$_googleApiKey');
      
      debugPrint("LocationService: Calling Places API...");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final String stationName = data['results'][0]['name'];
          debugPrint("LocationService: Found station: $stationName");
          return stationName;
        } else {
           debugPrint("LocationService: Places API call OK, but no results found. Status: ${data['status']}");
           return "Regional Police Department"; // Fallback if no stations are found
        }
      } else {
        debugPrint("LocationService: Error calling Places API. Status code: ${response.statusCode}");
        return "Nearby Police Station"; // Fallback on API error
      }
    } catch (e) {
      debugPrint("LocationService: Error getting location or processing API call: $e");
      return "Nearby Police Station"; // Fallback on general error
    }
  }

  Future<void> startSharingLocation() async {
    if (_isSharing) {
      return;
    }

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      return;
    }

    if (currentUser == null) {
      return;
    }

    _isSharing = true; 
    debugPrint("LocationService: Set _isSharing to true for user ${currentUser!.uid}");

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (_isSharing) {
        _updateUserLocationInFirestore(position);
      }
    } catch (e) {
      debugPrint("LocationService: Error getting initial position: $e");
    }

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        if (position != null && _isSharing) {
          _updateUserLocationInFirestore(position);
        }
      },
      onError: (error) {
        debugPrint("LocationService: Error in location stream: $error");
      }
    );
  }

  Future<void> _updateUserLocationInFirestore(Position position) async {
    if (currentUser == null || !_isSharing) {
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
    } catch (e) {
      debugPrint("LocationService: Error updating location to Firestore: $e");
    }
  }

  Future<void> stopSharingLocation() async {
    if (!_isSharing) {
      return;
    }
    _isSharing = false; 

    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null; 

    if (currentUser != null) {
      String userId = currentUser!.uid;
      try {
        await _firestore.collection('user_live_locations').doc(userId).update({
          'isSharing': false, 
          'lastUpdated': Timestamp.now(),
        });
      } catch (e) {
        debugPrint("LocationService: Error updating 'isSharing' to false in Firestore: $e");
      }
    }
  }

  bool isCurrentlySharing() {
    return _isSharing;
  }
}
