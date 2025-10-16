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
    _createDummyZones();
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

  void _createDummyZones() {
    final List<Map<String, dynamic>> zones = [
      // Bangi Area Mix
      {'id': 'bangi_danger_1', 'lat': 2.9200, 'lng': 101.7550, 'radius': 500.0, 'type': 'danger'},
      {'id': 'bangi_safe_1', 'lat': 2.9100, 'lng': 101.7450, 'radius': 300.0, 'type': 'safe'},
      {'id': 'bangi_danger_2', 'lat': 2.9250, 'lng': 101.7600, 'radius': 400.0, 'type': 'danger'},
      {'id': 'bangi_safe_2', 'lat': 2.9050, 'lng': 101.7500, 'radius': 600.0, 'type': 'safe'},

      // Kajang Area Mix
      {'id': 'kajang_safe_1', 'lat': 2.9900, 'lng': 101.7900, 'radius': 500.0, 'type': 'safe'},
      {'id': 'kajang_danger_1', 'lat': 3.0000, 'lng': 101.7850, 'radius': 350.0, 'type': 'danger'},
      {'id': 'kajang_safe_2', 'lat': 2.9850, 'lng': 101.7800, 'radius': 450.0, 'type': 'safe'},
      {'id': 'kajang_danger_2', 'lat': 2.9980, 'lng': 101.7950, 'radius': 550.0, 'type': 'danger'},
    ];

    Set<Circle> dummyCircles = {};

    for (var zone in zones) {
      final bool isSafe = zone['type'] == 'safe';
      dummyCircles.add(Circle(
        circleId: CircleId(zone['id'] as String),
        center: LatLng(zone['lat'] as double, zone['lng'] as double),
        radius: zone['radius'] as double,
        fillColor: isSafe ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        strokeColor: isSafe ? Colors.green : Colors.red,
        strokeWidth: 2,
      ));
    }

    setState(() {
      _circles.addAll(dummyCircles);
    });
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
