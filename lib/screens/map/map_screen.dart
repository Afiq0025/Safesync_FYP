import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
// Import Firestore and Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  LatLng? _currentPosition; // To store current device's position

  // Firestore stream subscription
  StreamSubscription? _liveLocationsSubscription;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
    _determinePosition(); // Get current location on init
    _listenToLiveLocations(); // Start listening to other users' locations
  }

  @override
  void dispose() {
    _liveLocationsSubscription?.cancel(); // Important to cancel subscription
    super.dispose();
  }

  Future<void> _determinePosition() async {
    // ... your existing _determinePosition() logic ...
    // (This remains largely the same, focusing on THIS device's location)
    // --- START OF EXISTING _determinePosition ---
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      _setDefaultLocationAndMarkers();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        _setDefaultLocationAndMarkers();
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied, we cannot request permissions.');
      _setDefaultLocationAndMarkers();
      return;
    } 

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          // _setMarkersAndCircles(); // We'll let _listenToLiveLocations handle markers primarily
                                 // or merge its logic carefully
          _updateMarkers(); // New method to consolidate marker updates
          _goToCurrentLocation(initial: true); 
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      _setDefaultLocationAndMarkers();
    }
    // --- END OF EXISTING _determinePosition ---
  }

  void _setDefaultLocationAndMarkers() {
    if (mounted) {
      setState(() {
        _currentPosition = const LatLng(2.9331, 101.7980); // Default location
        // _setMarkersAndCircles();
        _updateMarkers(); // New method
         _goToCurrentLocation(initial: true);
      });
    }
  }
  
  // New method to listen to Firestore for other users' locations
  void _listenToLiveLocations() {
    User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
        debugPrint("MapScreen: No current user for listening to live locations.");
        return;
    }

    _liveLocationsSubscription = FirebaseFirestore.instance
        .collection('user_live_locations')
        .where('isSharing', isEqualTo: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (mounted) {
        Set<Marker> newMarkers = {}; // Temporary set for new markers from Firestore

        // Add this device's own location marker first (if position is known)
        if (_currentPosition != null) {
          newMarkers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: _currentPosition!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Current user marker
              infoWindow: const InfoWindow(
                title: 'Your Location',
              ),
            ),
          );
        }

        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          GeoPoint geoPoint = data['location'] as GeoPoint;
          String userId = data['userId'] as String;
          String userEmail = data['userEmail'] as String? ?? 'N/A';

          // Don't add a marker from Firestore if it's the current user's own live location
          // (already handled by 'current_location' marker from GPS, or you can choose to only use Firestore)
          // For simplicity now, we rely on GPS for 'current_location' and skip Firestore for self.
          if (userId == currentUser.uid) {
            continue; 
          }

          newMarkers.add(
            Marker(
              markerId: MarkerId(userId),
              position: LatLng(geoPoint.latitude, geoPoint.longitude),
              infoWindow: InfoWindow(
                title: userEmail.split('@').first, // Or a display name if available
                snippet: 'Lat: ${geoPoint.latitude.toStringAsFixed(4)}, Lng: ${geoPoint.longitude.toStringAsFixed(4)}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Other users' marker
            ),
          );
        }
        setState(() {
          _markers = newMarkers; // Replace all markers
          _updateCircles(); // Also update circles if they depend on _currentPosition
        });
      }
    }, onError: (error) {
      debugPrint("MapScreen: Error listening to live locations: $error");
    });
  }

  // Renamed and slightly modified to only handle circles, markers are now primary handled by _listenToLiveLocations
  void _updateCircles() {
    if (_currentPosition == null) return;
    if (!mounted) return;

    Set<Circle> newCircles = {};
    newCircles.addAll([
      Circle(
        circleId: const CircleId('safe_circle'),
        center: _currentPosition!,
        radius: 300,
        fillColor: Colors.green.withOpacity(0.3),
        strokeColor: Colors.green,
        strokeWidth: 2,
      ),
      Circle(
        circleId: const CircleId('danger_circle'),
        center: const LatLng(2.9363, 101.7980), // This could be another dynamic point or currentPosition
        radius: 150,
        fillColor: Colors.red.withOpacity(0.3),
        strokeColor: Colors.red,
        strokeWidth: 2,
      ),
    ]);
    setState(() {
        _circles = newCircles;
    });
  }

  // New consolidated method to update all markers and circles
  void _updateMarkers() {
      // This method can be called after _determinePosition or when _currentPosition changes
      // It mainly ensures the 'current_location' marker and circles are up-to-date.
      // Other users' markers are handled by _listenToLiveLocations.
      if (!mounted) return;
      if (_currentPosition == null) return;

      Set<Marker> updatedMarkerSet = Set.from(_markers); // Start with existing markers from Firestore stream

      // Remove old 'current_location' marker if it exists, then add the new one
      updatedMarkerSet.removeWhere((m) => m.markerId == const MarkerId('current_location'));
      updatedMarkerSet.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Current user
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
      );
      
      setState(() {
          _markers = updatedMarkerSet;
          _updateCircles();
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B6B),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  const Text(
                    'Map',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 350;
                  final padding = EdgeInsets.all(isSmallScreen ? 12.0 : 20.0);
                  final controlSize = isSmallScreen ? 36.0 : 40.0;
                  final controlSpacing = isSmallScreen ? 6.0 : 8.0;
                  final legendPadding = EdgeInsets.all(isSmallScreen ? 8.0 : 12.0);
                  final legendFontSize = isSmallScreen ? 11.0 : 12.0;
                  final legendSpacing = isSmallScreen ? 6.0 : 8.0;

                  if (_currentPosition == null && _markers.isEmpty) { // Show loading if no position AND no markers from Firestore yet
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  return Padding(
                    padding: padding,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
                            child: GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition( // Camera now centers on current device or default
                                target: _currentPosition ?? const LatLng(2.9331, 101.7980),
                                zoom: 14.4746,
                              ),
                              markers: _markers, // These now include other users
                              circles: _circles,
                              onMapCreated: (GoogleMapController controller) {
                                if (!_mapControllerCompleter.isCompleted) {
                                   _mapControllerCompleter.complete(controller);
                                }
                              },
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false, 
                              myLocationEnabled: false, // Set to false if you are using a custom 'current_location' marker
                                                       // or true if you want the blue dot AND your custom marker.
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                              buildingsEnabled: true,
                              trafficEnabled: false,
                              liteModeEnabled: false,
                              tiltGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                            ),
                          ),
                          Positioned(
                            top: isSmallScreen ? 12.0 : 20.0,
                            right: isSmallScreen ? 12.0 : 20.0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMapControl(Icons.zoom_in, _zoomIn, controlSize),
                                SizedBox(height: controlSpacing),
                                _buildMapControl(Icons.zoom_out, _zoomOut, controlSize),
                                SizedBox(height: controlSpacing),
                                _buildMapControl(Icons.my_location, () => _goToCurrentLocation(), controlSize),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: isSmallScreen ? 12.0 : 20.0,
                            left: isSmallScreen ? 12.0 : 20.0,
                            child: Container(
                              padding: legendPadding,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildMapLegend('Safe Zone Area', Colors.green.shade400, legendFontSize),
                                  SizedBox(height: legendSpacing),
                                  _buildMapLegend('High-Risk Zone Area', Colors.red.shade400, legendFontSize),
                                   // You might want to add a legend for 'Your Location' and 'Other Users'
                                  SizedBox(height: legendSpacing),
                                  _buildMapLegend('Your Location', Colors.green, legendFontSize), // Example
                                  SizedBox(height: legendSpacing),
                                  _buildMapLegend('Other Users', Colors.blue, legendFontSize), // Example
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _zoomIn() async {
    if (!_mapControllerCompleter.isCompleted) return;
    final GoogleMapController controller = await _mapControllerCompleter.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }
  
  Future<void> _zoomOut() async {
    if (!_mapControllerCompleter.isCompleted) return;
    final GoogleMapController controller = await _mapControllerCompleter.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }
  
  Future<void> _goToCurrentLocation({bool initial = false}) async {
    if (_currentPosition == null) return;
    // Check if controller is completed before accessing .future
    if (!_mapControllerCompleter.isCompleted) return; 
    final GoogleMapController controller = await _mapControllerCompleter.future;
    // No need to check controller for null if we awaited a completed future
    
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition!,
          zoom: initial ? 14.4746 : 16.0, 
        ),
      ),
    );
  }

  Widget _buildCircleMarker(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap, [double? size]) {
    final controlSize = size ?? 40.0;
    final iconSize = controlSize * 0.5;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: controlSize,
        height: controlSize,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.grey[700], size: iconSize),
      ),
    );
  }

  Widget _buildMapLegend(String text, Color color, [double? fontSize]) {
    final textSize = fontSize ?? 12.0;
    final circleSize = textSize * 1.25;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            // If using for user markers, maybe use a different shape or icon
            color: color, // Marker color
            shape: BoxShape.circle, 
            border: Border.all(color: Colors.white, width: 1.5)
          ),
        ),
        SizedBox(width: textSize * 0.67),
        Text(
          text,
          style: TextStyle(fontSize: textSize, color: Colors.black87),
        ),
      ],
    );
  }

  // _buildNavItem is not used in MapScreen directly, it seems to be from a parent/different widget.
  // Widget _buildNavItem(IconData icon, String label, int index, VoidCallback onTap) { ... }
}
