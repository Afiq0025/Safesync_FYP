import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart'; // Import geolocator

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  
  // Remove _kGooglePlex, will be replaced by user's current location
  // static const CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(2.9331, 101.7980),
  //   zoom: 14.4746,
  // );
  
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  LatLng? _currentPosition; // To store current position

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Get current location on init
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      print('Location services are disabled.');
      // Optionally, set a default location or show an error
      _setDefaultLocationAndMarkers();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print('Location permissions are denied');
        _setDefaultLocationAndMarkers();
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      print('Location permissions are permanently denied, we cannot request permissions.');
      _setDefaultLocationAndMarkers();
      return;
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _setMarkersAndCircles(); // Update markers with current location
        _goToCurrentLocation(initial: true); // Move camera to current location
      });
    } catch (e) {
      print('Error getting location: $e');
      _setDefaultLocationAndMarkers();
    }
  }

  void _setDefaultLocationAndMarkers() {
    // Default to a predefined location if current location is unavailable
    setState(() {
      _currentPosition = const LatLng(2.9331, 101.7980); // Default location
       _setMarkersAndCircles();
       _goToCurrentLocation(initial: true);
    });
  }
  
  void _setMarkersAndCircles() {
    if (_currentPosition == null) return; // Don't do anything if position is not yet determined

    setState(() {
      _markers.clear(); // Clear existing markers
      _circles.clear(); // Clear existing circles

      // Add user current location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current position',
          ),
        ),
      );
      
      // Add circular zones (centered on current location or a fixed point)
      _circles.addAll([
        Circle(
          circleId: const CircleId('safe_circle'),
          center: _currentPosition!, // Center on current location
          radius: 300,
          fillColor: Colors.green.withOpacity(0.3),
          strokeColor: Colors.green,
          strokeWidth: 2,
        ),
        Circle(
          circleId: const CircleId('danger_circle'),
          // Example: Keep this circle at a fixed point, or also center it on user
          center: const LatLng(2.9363, 101.7980), // This could be another dynamic point or currentPosition
          radius: 150,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ),
      ]);
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
                  // final isLargeScreen = constraints.maxWidth > 600; // Not used currently
                  
                  final padding = EdgeInsets.all(isSmallScreen ? 12.0 : 20.0);
                  final controlSize = isSmallScreen ? 36.0 : 40.0;
                  final controlSpacing = isSmallScreen ? 6.0 : 8.0;
                  final legendPadding = EdgeInsets.all(isSmallScreen ? 8.0 : 12.0);
                  final legendFontSize = isSmallScreen ? 11.0 : 12.0;
                  final legendSpacing = isSmallScreen ? 6.0 : 8.0;

                  // Show a loading indicator until current position is determined
                  if (_currentPosition == null) {
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
                              // Set initial camera position to current location if available
                              initialCameraPosition: CameraPosition(
                                target: _currentPosition!,
                                zoom: 14.4746,
                              ),
                              markers: _markers,
                              circles: _circles,
                              onMapCreated: (GoogleMapController controller) {
                                if (!_controller.isCompleted) {
                                   _controller.complete(controller);
                                }
                              },
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false, // Disabled as we have a custom button
                              myLocationEnabled: true, // Shows the blue dot for current location
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
    if (!_controller.isCompleted) return;
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }
  
  Future<void> _zoomOut() async {
    if (!_controller.isCompleted) return;
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }
  
  Future<void> _goToCurrentLocation({bool initial = false}) async {
    if (_currentPosition == null || !_controller.isCompleted) return;
    
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition!,
          zoom: initial ? 14.4746 : 16.0, // Use initial zoom on first load
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
            color: color,
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

  Widget _buildNavItem(IconData icon, String label, int index, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: index == 1 ? const Color(0xFFF36060) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: index == 1 ? Colors.white : const Color(0xFFF36060),
              size: 22,
            ),
            if (index == 1) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
