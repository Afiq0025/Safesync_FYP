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
  Set<Marker> _liveMarkers = {}; // Markers for other users
  Set<Circle> _circles = {};
  LatLng? _currentPosition;

  StreamSubscription? _liveLocationsSubscription;
  StreamSubscription<Position>? _positionStreamSubscription; // For user's own location
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _subscribeToLocationUpdates();
    _listenToLiveLocations();
  }

  @override
  void dispose() {
    _liveLocationsSubscription?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _subscribeToLocationUpdates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
        ));
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permission is required to show your position.'),
          ));
        }
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied, we cannot request permissions.');
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permissions are permanently denied. Please enable them in your phone settings.'),
          ));
        }
      return;
    } 

    // Get the initial position and move the camera for a fast first view
    try {
      Position initialPosition = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(initialPosition.latitude, initialPosition.longitude);
          _updateCurrentUserMarker();
          _goToCurrentLocation(initial: true); 
        });
      }
    } catch (e) {
      debugPrint('Error getting initial location: $e');
    }

    // Subscribe to continuous location updates
    _positionStreamSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
            _updateCurrentUserMarker();
          });
        }
      },
      onError: (e) {
        debugPrint('Error in location stream: $e');
      }
    );
  }
  
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
        _updateLiveMarkers(snapshot.docs);
      }
    }, onError: (error) {
      debugPrint("MapScreen: Error listening to live locations: $error");
    });
  }

  void _updateLiveMarkers(List<QueryDocumentSnapshot> docs) {
    Set<Marker> newLiveMarkers = {};
    User? currentUser = _firebaseAuth.currentUser;

    for (var doc in docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final String userId = data['userId'];
        
        // Don't draw a marker for the current user from the live collection,
        // as we are drawing it based on the real-time device location stream.
        if (userId == currentUser?.uid) continue;

        final GeoPoint location = data['location'];
        final String name = data['name'] ?? 'Anonymous User';

        newLiveMarkers.add(
          Marker(
            markerId: MarkerId(userId),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(title: name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      } catch (e) {
        debugPrint("Error processing live location document: $e");
      }
    }

    if(mounted) {
      setState(() {
        _liveMarkers = newLiveMarkers;
      });
    }
  }

  void _updateCurrentUserMarker() {
    if (!mounted || _currentPosition == null) return;

    setState(() {
       _markers.removeWhere((m) => m.markerId.value == 'current_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    });
  }


  Future<void> _goToCurrentLocation({bool initial = false}) async {
    if (_currentPosition == null) {
      // If position is somehow null, try to refetch it.
      await _subscribeToLocationUpdates();
      return;
    }
    final GoogleMapController controller = await _mapControllerCompleter.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _currentPosition!,
        zoom: 12.0,
      ),
    ));
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Legend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              const Text('Your Location', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              const Text('Other Users', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.circle, color: Colors.green.withOpacity(0.7), size: 20),
              const SizedBox(width: 8),
              const Text('Safe Zone', style: TextStyle(fontSize: 12)),
            ],
          ),
           const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.circle, color: Colors.red.withOpacity(0.7), size: 20),
              const SizedBox(width: 8),
              const Text('Danger Zone', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
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

                  return Padding(
                    padding: padding,
                    child: Container(
                      clipBehavior: Clip.hardEdge, // Ensures child respects border radius
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
                      ),
                      child: Stack(
                        children: [
                          if (_currentPosition != null)
                            GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: _currentPosition!,
                                zoom: 12.0,
                              ),
                              markers: _markers.union(_liveMarkers),
                              circles: _circles,
                              onMapCreated: (GoogleMapController controller) {
                                if (!_mapControllerCompleter.isCompleted) {
                                   _mapControllerCompleter.complete(controller);
                                }
                              },
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false, // We use a custom FAB
                              myLocationEnabled: true,
                              compassEnabled: true,
                              mapToolbarEnabled: false,
                            )
                          else
                            const Center(child: CircularProgressIndicator()),
                          
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: FloatingActionButton(
                              onPressed: _goToCurrentLocation,
                              child: const Icon(Icons.my_location),
                              backgroundColor: Colors.white,
                            ),
                          ),
                           Positioned(
                            bottom: 20,
                            left: 20,
                            child: _buildLegend(),
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
}
