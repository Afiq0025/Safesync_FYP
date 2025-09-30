import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Added for DateFormat

// Firebase Imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:safesync/screens/community/report_screen.dart';
import 'package:safesync/screens/emergency/emergency_contacts.dart';
import 'package:safesync/widgets/pulse_icon.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/smartwatch_detail.dart';
import 'screens/settings/recording_settings.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/home/pair_smart_devices.dart';
import 'screens/map/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart'; // For Fall Detection & Shake
import 'dart:math'; // For sqrt, pow
import 'package:provider/provider.dart';
import 'providers/battery_provider.dart';

// Services
import 'services/fall_detection_service.dart';
import 'services/shake_detection_service.dart'; // Import the new service
import 'services/emergency_service.dart';
import 'services/lockscreen_service.dart';
import 'services/location_service.dart';
import 'services/auto_call_service.dart';

// Initialize flutter_local_notifications plugin instance globally
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


Future<void> main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize flutter_local_notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: (id, title, body, payload) async {
    // Handle notification tapped logic here if needed for older iOS versions
  });
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
    // Handle notification tapped logic here
  });

  runZonedGuarded(() {
    runApp(const SafeSyncApp());
  }, (error, stackTrace) {
    print('App Error: $error');
    print('Stack Trace: $stackTrace');
  });
}

class SafeSyncApp extends StatelessWidget {
  const SafeSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFFF36060),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // SplashScreen will handle auth check and navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/': (context) => const SplashScreen(), // Initial route
        '/main': (context) => const MainScreen(),
        '/smartwatch': (context) => const SmartwatchDetailScreen(),
        '/recording-settings': (context) => const RecordingSettingsScreen(),
        '/pair-smart-devices': (context) => const PairSmartDevicesScreen(),
        '/profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return ProfileScreen(
            name: args?['name'] as String? ?? 'User Name Default',
            phoneNumber: args?['phoneNumber'] as String? ?? 'N/A Default',
            email: args?['email'] as String? ?? 'N/A Default',
            address: args?['address'] as String? ?? 'Address Default',
            bloodType: args?['bloodType'] as String? ?? 'Blood Type Default',
            allergies: args?['allergies'] as String? ?? 'Allergies Default',
            medicalConditions: args?['medicalConditions'] as String? ??
                'Conditions Default',
            medications:
                args?['medications'] as String? ?? 'Medications Default',
          );
        },
        '/contacts': (context) => const EmergencyContactsScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAppAndListenToAuth();
  }

  Future<void> _initializeAppAndListenToAuth() async {
    // Optional: Keep a minimum display time for the splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return; // Check if the widget is still in the tree

    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted) return; // Check again before navigating

      if (user == null) {
        debugPrint('SplashScreen: User is currently signed out! Navigating to /login.');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        debugPrint('SplashScreen: User is signed in! UID: ${user.uid}. Navigating to /main.');
        Navigator.pushReplacementNamed(context, '/main');
      }
    }, onError: (error) {
      debugPrint('SplashScreen: Error in authStateChanges stream: $error');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login'); // Fallback to login on stream error
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 600,
              height: 600,
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 5),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  int _batteryLevel = 0;
  String _name = "User Name"; // Default
  String _phoneNumber = "N/A"; // Default
  String _email = "N/A"; // Default
  String _address = "Address Default"; // Default
  String _bloodType = "Blood Type Default"; // Default
  String _allergies = "Allergies Default"; // Default
  String _medicalConditions = "Conditions Default"; // Default
  String _medications = "Medications Default"; // Default

  bool _isInitialDataLoaded = false; // Flag

  static const platform = MethodChannel('com.fyp.safesync.safesync/heartrate');
  int _heartRate = 0;
  String _heartStatus = "Connecting...";
  DateTime? _lastUpdated;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _setupMethodChannelHandler();
    // Data loading will be initiated by didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialDataLoaded) {
      _loadData();
      _isInitialDataLoaded = true; // Set flag after initiating load
    }
  }

  Future<void> _loadData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      debugPrint("MainScreen (_loadData): No current user. Navigating to login.");
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    Map<String, dynamic>? dataToUse;
    String? source; // For debugging: "args" or "firestore"

    // Attempt to get route arguments first
    final route = ModalRoute.of(context);
    if (route?.settings.arguments != null) {
      dataToUse = route!.settings.arguments as Map<String, dynamic>;
      source = "route arguments";
    }

    // If no arguments, fetch from Firestore
    if (dataToUse == null) {
      source = "Firestore";
      debugPrint("MainScreen (_loadData): No route arguments. Fetching from Firestore for UID: ${currentUser.uid}");
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          dataToUse = userDoc.data() as Map<String, dynamic>;
        } else {
          debugPrint("MainScreen (_loadData): Firestore document not found for UID: ${currentUser.uid}. Will use fallbacks.");
          dataToUse = {}; // Use empty map to signify fallback necessary
        }
      } catch (e) {
        debugPrint("MainScreen (_loadData): Error fetching from Firestore: $e. Will use fallbacks.");
        dataToUse = {}; // Use empty map to signify fallback necessary on error
      }
    }

    if (mounted) {
      _updateStateWithUserData(dataToUse ?? {}, currentUser, source);
    }
  }

  void _updateStateWithUserData(Map<String, dynamic> userData, User currentUser, String? source) {
    if (!mounted) return;

    setState(() {
      // Prioritize data from args/Firestore, then Auth, then existing defaults
      _email = currentUser.email ?? userData['email'] as String? ?? _email;
      _name = userData['name'] as String? ?? // 'name' from args
              userData['fullName'] as String? ?? // 'fullName' from Firestore
              currentUser.displayName ??
              _name;
      _phoneNumber = userData['phoneNumber'] as String? ?? _phoneNumber;
      _address = userData['address'] as String? ?? _address;
      _bloodType = userData['bloodType'] as String? ?? _bloodType;
      _allergies = userData['allergies'] as String? ?? _allergies;
      _medicalConditions = userData['medicalConditions'] as String? ?? _medicalConditions;
      _medications = userData['medications'] as String? ?? _medications;
    });
    debugPrint("MainScreen (_updateStateWithUserData): State updated from $source. Name: $_name, Email: $_email");
  }

  void _setupMethodChannelHandler() {
    platform.setMethodCallHandler((MethodCall call) async {
      // ... (your existing method channel handler code)
      switch (call.method) {
        case 'heartRateUpdate':
          final Map<dynamic, dynamic> data = call.arguments;
          if (mounted) {
            setState(() {
              _heartRate = data['bpm'] as int;
              _lastUpdated = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
              if (_heartRate > 0) {
                _heartStatus = "Watch Connected";
              } else {
                _heartStatus = "Watch Connected (No BPM)";
              }
            });
          }
          break;
        case 'batteryUpdate':
          final Map<dynamic, dynamic> data = call.arguments;
          if (mounted) {
            setState(() {
              _batteryLevel = data['battery'] as int;
            });
          }
          break;
        default:
          debugPrint('MainScreen: Unknown method ${call.method}');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel any subscriptions or platform channel listeners if necessary
  }

  List<Widget> get screens {
    return [
      HomeScreen(
        name: _name,
        phoneNumber: _phoneNumber,
        email: _email,
        address: _address,
        bloodType: _bloodType,
        allergies: _allergies,
        medicalConditions: _medicalConditions,
        medications: _medications,
        currentHeartRate: _heartRate,
        currentHeartStatus: _heartStatus,
        lastWatchUpdate: _lastUpdated,
        currentBatteryLevel: _batteryLevel,
      ),
      const MapScreen(),
      const EmergencyContactsScreen(),
      const ReportScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_filled, "Home", 0),
              _buildNavItem(Icons.map_outlined, "Map", 1),
              _buildNavItem(Icons.person_outline, "Contacts", 2),
              _buildNavItem(Icons.groups, "Community", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            currentIndex = index;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF36060) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFFF36060),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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

class HomeScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final String bloodType;
  final String allergies;
  final String medicalConditions;
  final String medications;
  final int currentHeartRate;
  final String currentHeartStatus;
  final DateTime? lastWatchUpdate;
  final int currentBatteryLevel;

  const HomeScreen({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.bloodType,
    required this.allergies,
    required this.medicalConditions,
    required this.medications,
    required this.currentHeartRate,
    required this.currentHeartStatus,
    required this.currentBatteryLevel,
    this.lastWatchUpdate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isLockscreenAccessEnabled = false;
  DateTime? _lastFallTime;

  Map<String, bool> buttonPressed = {
    'emergency': false,
    'voice': false,     // AI Voice Recognition - Placeholder
    'call': false,      // Auto Call - Placeholder
    'location': false,  // Location Sharing - Placeholder
  };

  // Services
  late FallDetectionService _fallDetectionService;
  late ShakeDetectionService _shakeDetectionService;
  late EmergencyService _emergencyService;
  late LockscreenService _lockscreenService;
  late LocationService _locationService;
  late AutoCallService _autoCallService;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _autoCallService = AutoCallService();

    _lockscreenService = LockscreenService(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      getName: () => widget.name,
      getPhoneNumber: () => widget.phoneNumber,
      getBloodType: () => widget.bloodType,
      getAllergies: () => widget.allergies,
      getMedicalConditions: () => widget.medicalConditions,
      getMedications: () => widget.medications,
    );
    _lockscreenService.requestPermissions(context);
    _loadLockscreenState();

    _emergencyService = EmergencyService(
      context: context,
      isLocationSharingActive: () => buttonPressed['location'] ?? false,
      onStartLocationSharing: _locationService.startSharingLocation,
      onInitiateAutoCall: _autoCallService.initiateFakeAutoCallToPolice,
      isEmergencyButtonActive: () => buttonPressed['emergency'] ?? false,
    );

    _fallDetectionService = FallDetectionService(
      onFallDetected: _updateLastFallDetected,
    );
    _fallDetectionService.initAccelerometer();

    _shakeDetectionService = ShakeDetectionService(
      onShakeDetectedVigorous: _handleVigorousShake,
      isEmergencyModeActive: () => buttonPressed['emergency'] ?? false,
    );
    _shakeDetectionService.initAccelerometer();
  }

  void _handleVigorousShake() {
    if (mounted) {
      debugPrint("HomeScreen: Vigorous shake detected via ShakeDetectionService. Triggering emergency.");
      _emergencyService.handleEmergencyTrigger();
    }
  }

  Future<void> _loadLockscreenState() async {
    await _lockscreenService.loadSwitchStateAndShowNotification();
    if (mounted) {
      bool isEnabled = await _lockscreenService.isLockscreenAccessEnabled();
      setState(() {
        _isLockscreenAccessEnabled = isEnabled;
      });
    }
  }

  Future<void> _saveLockscreenState(bool isEnabled) async {
    await _lockscreenService.saveSwitchStateAndMedicalInfo(isEnabled);
    if (mounted) {
      setState(() {
        _isLockscreenAccessEnabled = isEnabled;
      });
    }
  }

  @override
  void dispose() {
    _fallDetectionService.dispose();
    _shakeDetectionService.dispose();
    // It's good practice to also stop location sharing if active when HomeScreen disposes
    // if this is the primary screen managing that state.
    // However, ensure this doesn't conflict with background location needs if any.
    if (_locationService.isCurrentlySharing()) {
      debugPrint("HomeScreen disposing: Stopping location sharing.");
      _locationService.stopSharingLocation();
    }
    super.dispose();
  }

  void _updateLastFallDetected(DateTime fallTime) {
    if (mounted) {
      setState(() {
        _lastFallTime = fallTime;
      });
      debugPrint("HomeScreen: Fall detected at: $fallTime. UI should update.");
    }
  }

  void _toggleButton(String buttonKey) {
    setState(() {
      buttonPressed[buttonKey] = !buttonPressed[buttonKey]!;

      if (buttonKey == 'emergency') {
        bool isEmergencyActive = buttonPressed['emergency']!;
        // Link location sharing state to emergency mode state
        buttonPressed['location'] = isEmergencyActive;

        if (isEmergencyActive) {
          debugPrint("HomeScreen: Emergency Mode ARMED. Location Sharing also ACTIVATED (state set). LocationService hash: ${_locationService.hashCode}");
          // Ensure location sharing actually starts.
          _locationService.startSharingLocation();
          debugPrint("HomeScreen: Call to _locationService.startSharingLocation() for emergency arm completed (method is async).");

        } else {
          debugPrint("HomeScreen: Emergency Mode DISARMED. Location Sharing also DEACTIVATED (state set). Calling _locationService.stopSharingLocation(). LocationService hash: ${_locationService.hashCode}");
          _locationService.stopSharingLocation();
          debugPrint("HomeScreen: Call to _locationService.stopSharingLocation() for emergency disarm completed (method is async).");
        }
      } else if (buttonKey == 'location') {
        // This is for the independent location button
        if (buttonPressed['location']!) {
          debugPrint("HomeScreen: Location Sharing ACTIVATED independently. Calling _locationService.startSharingLocation(). LocationService hash: ${_locationService.hashCode}");
          _locationService.startSharingLocation();
          debugPrint("HomeScreen: Call to _locationService.startSharingLocation() for independent activation completed (method is async).");
        } else {
          // This is the "Location Sharing DEACTIVATED independently" path
          debugPrint("HomeScreen: Location Sharing DEACTIVATED independently. Preparing to call _locationService.stopSharingLocation(). LocationService hash: ${_locationService.hashCode}");
          _locationService.stopSharingLocation();
          debugPrint("HomeScreen: Call to _locationService.stopSharingLocation() for independent deactivation completed (method is async).");
        }
      }
    });
  }

  String _formatDateTimeLocal(DateTime dt) {
    String hour = dt.hour.toString().padLeft(2, '0');
    String minute = dt.minute.toString().padLeft(2, '0');
    String second = dt.second.toString().padLeft(2, '0');
    return "$hour:$minute:$second";
  }

  @override
  Widget build(BuildContext context) {
    String lastFallDisplayStatus;
    if (_lastFallTime != null) {
      lastFallDisplayStatus = DateFormat.yMd().add_jm().format(_lastFallTime!);
    } else {
      lastFallDisplayStatus = "Never";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF36060),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/profile',
                        arguments: {
                          'name': widget.name,
                          'phoneNumber': widget.phoneNumber,
                          'email': widget.email,
                          'address': widget.address,
                          'bloodType': widget.bloodType,
                          'allergies': widget.allergies,
                          'medicalConditions': widget.medicalConditions,
                          'medications': widget.medications,
                        },
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((255 * 0.2).round()),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/smartwatch',
                            arguments: {
                              'heartRate': widget.currentHeartRate,
                              'connectionStatus': widget.currentHeartStatus,
                              'batteryLevel': widget.currentBatteryLevel,
                            },
                          );
                        },
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22.5),
                          ),
                          child: Image.asset('assets/images/watch.jpg',
                              width: 24, height: 24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              PulseIcon(
                icon: Icons.favorite,
                pulseColor: Colors.white70,
                iconColor: Colors.redAccent,
                iconSize: 40,
                innerSize: 45,
                pulseSize: 116,
                pulseCount: 3,
              ),
              const SizedBox(height: 10),
              Text(
                widget.currentHeartRate > 0 ? '${widget.currentHeartRate} BpM' : '-- BpM',                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Heart Rate - ${widget.currentHeartStatus}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              if (widget.lastWatchUpdate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Last Watch Update: ${_formatDateTimeLocal(widget.lastWatchUpdate!)}',
                    style: const TextStyle(fontSize: 10, color: Colors.white60),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActivityIndicator(
                    Icons.emergency_recording_rounded,
                    "Automatic\nRecording",
                    onTap: () {
                      Navigator.pushNamed(context, '/recording-settings');
                    },
                  ),
                  _buildActivityIndicator(
                    Icons.watch_rounded,
                    "Pair Smart\nDevices",
                    onTap: () {
                      Navigator.pushNamed(context, '/pair-smart-devices');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureButton(
                              "Emergency Mode",
                              "Tap panic to activate",
                              Icons.warning_amber,
                              'emergency',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFeatureButton(
                              "AI Voice Recognition",
                              "Always listen for distress",
                              Icons.graphic_eq,
                              'voice',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureButton(
                              "Auto Call",
                              "Emergency contact",
                              Icons.phone_callback,
                              'call',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFeatureButton(
                              "Location Sharing",
                              "Real-time GPS tracking",
                              Icons.my_location,
                              'location',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatusCard("Last Fall Detected", lastFallDisplayStatus),
                      const SizedBox(height: 12),
                      _buildLockscreenCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityIndicator(IconData icon, String label,
      {VoidCallback? onTap}) {
    Widget content = Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((255 * 0.2).round()),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }

  Widget _buildFeatureButton(
      String title, String subtitle, IconData icon, String buttonKey) {
    bool isPressed = buttonPressed[buttonKey] ?? false;
    return GestureDetector(
      onTap: () => _toggleButton(buttonKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPressed ? const Color(0xFFDD0000) : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isPressed ? Colors.white : const Color(0xFFDD0000),
                  size: 20,
                ),
                const Spacer(),
                if (isPressed)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isPressed ? Colors.white : Colors.black,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isPressed ? Colors.white70 : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$title : $status',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLockscreenCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lockscreen Access',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Show medical information on lock screen',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        color: Colors.grey,
                      ),
                      maxLines: 2, // <<< CORRECTED HERE
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _isLockscreenAccessEnabled,
                onChanged: _saveLockscreenState,
                activeColor: const Color(0xFFDD0000),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        );
      },
    );
  }
}
