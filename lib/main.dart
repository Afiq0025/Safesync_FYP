import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Added for DateFormat
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:safesync/services/permission_service.dart';

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

// Services
import 'services/fall_detection_service.dart';
import 'services/shake_detection_service.dart'; 
import 'services/emergency_service.dart';
import 'services/lockscreen_service.dart';
import 'services/location_service.dart';
import 'services/auto_call_service.dart';
import 'services/video_recording_service.dart';

// Initialize flutter_local_notifications plugin instance globally
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Load the .env file
    await dotenv.load(fileName: ".env");

    await MediaStore.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

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

    runApp(const SafeSyncApp());
  }, (error, stackTrace) {
    debugPrint('App Error: $error', wrapWidth: 1024);
    debugPrint('Stack Trace: $stackTrace', wrapWidth: 1024);
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
      initialRoute: '/', 
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/': (context) => const SplashScreen(), 
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
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return; 
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted) return; 
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
        Navigator.pushReplacementNamed(context, '/login'); 
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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int currentIndex = 0;
  int _batteryLevel = 0;
  String _name = "User Name"; 
  String _phoneNumber = "N/A"; 
  String _email = "N/A"; 
  String _address = "Address Default"; 
  String _bloodType = "Blood Type Default"; 
  String _allergies = "Allergies Default"; 
  String _medicalConditions = "Conditions Default"; 
  String _medications = "Medications Default"; 
  bool _isInitialDataLoaded = false; 
  static const platform = MethodChannel('com.fyp.safesync.safesync/heartrate');
  int _heartRate = 0;
  String _heartStatus = "Connecting...";
  DateTime? _lastUpdated;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupMethodChannelHandler();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialDataLoaded) {
      debugPrint("MainScreen: didChangeDependencies, initial data load.");
      _loadData();
      _isInitialDataLoaded = true; 
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("MainScreen: App resumed, reloading data.");
      _loadData(); 
    }
  }

  Future<void> _loadData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint("MainScreen (_loadData): No current user. Navigating to login.");
      if (mounted) {
         WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pushReplacementNamed(context, '/login');
        });
      }
      return;
    }

    debugPrint("MainScreen (_loadData): Reloading data from Auth/Firestore for UID: ${currentUser.uid}");
    Map<String, dynamic> firestoreData = {};
    User? freshCurrentUser = currentUser;
    try {
      await freshCurrentUser.reload(); 
      freshCurrentUser = FirebaseAuth.instance.currentUser; 
      if (freshCurrentUser == null) { // User might have been disabled/deleted
         debugPrint("MainScreen (_loadData): CurrentUser became null after reload. Navigating to login.");
         if (mounted) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pushReplacementNamed(context, '/login');
          });
        }
        return;
      }
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(freshCurrentUser.uid).get();
      if (userDoc.exists) {
        firestoreData = userDoc.data() as Map<String, dynamic>;
      } else {
        debugPrint("MainScreen (_loadData): Firestore document not found for UID: ${freshCurrentUser.uid}.");
      }
    } catch (e) {
      debugPrint("MainScreen (_loadData): Error fetching from Auth/Firestore: $e");
    }

    if (mounted && freshCurrentUser != null) {
      _updateStateWithUserData(firestoreData, freshCurrentUser, "Auth/Firestore reload");
    }
  }

  void _updateStateWithUserData(Map<String, dynamic> userData, User currentUser, String? source) {
    if (!mounted) return;
    setState(() {
      _email = currentUser.email ?? userData['email'] as String? ?? _email;
      _name = currentUser.displayName ?? userData['fullName'] as String? ?? _name; 
      _phoneNumber = userData['phoneNumber'] as String? ?? _phoneNumber;
      _address = userData['address'] as String? ?? _address;
      _bloodType = userData['bloodType'] as String? ?? _bloodType;
      _allergies = userData['allergies'] as String? ?? _allergies;
      _medicalConditions = userData['medicalConditions'] as String? ?? _medicalConditions;
      _medications = userData['medications'] as String? ?? _medications;
    });
    debugPrint("MainScreen (_updateStateWithUserData): State updated from $source. Name: $_name, Phone: $_phoneNumber");
  }

  void _setupMethodChannelHandler() {
    platform.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'heartRateUpdate':
          final Map<dynamic, dynamic> data = call.arguments;
          if (mounted) {
            setState(() {
              _heartRate = data['bpm'] as int;
              _lastUpdated = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
              _heartStatus = (_heartRate > 0) ? "Watch Connected" : "Watch Connected (No BPM)";
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
  
  void requestReload() {
    debugPrint("MainScreen: Reload requested by HomeScreen.");
    _loadData();
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
        onProfileScreenClosed: requestReload,
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
  final VoidCallback? onProfileScreenClosed;

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
    this.lastWatchUpdate,
    required this.currentBatteryLevel,
    this.onProfileScreenClosed,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isLockscreenAccessEnabled = false;
  DateTime? _lastFallTime;
  Map<String, bool> buttonPressed = {
    'emergency': false,
    'voice': false,     
    'call': false,      
    'location': false,  
  };
  late FallDetectionService _fallDetectionService;
  late ShakeDetectionService _shakeDetectionService;
  late EmergencyService _emergencyService;
  late LockscreenService _lockscreenService;
  late LocationService _locationService;
  late AutoCallService _autoCallService;
  final VideoRecordingService _videoRecordingService = VideoRecordingService();
  bool _didLoadLockscreenStateInitial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService.requestAllPermissions();
    });
    _locationService = LocationService();
    _autoCallService = AutoCallService();
    _videoRecordingService.initCamera();
    _videoRecordingService.isRecording.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _videoRecordingService.isReady.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _lockscreenService = LockscreenService(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      getName: () => widget.name,
      getPhoneNumber: () => widget.phoneNumber,
      getBloodType: () => widget.bloodType,
      getAllergies: () => widget.allergies,
      getMedicalConditions: () => widget.medicalConditions,
      getMedications: () => widget.medications,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _lockscreenService.requestPermissions(context);
      }
    });

    _emergencyService = EmergencyService(
      context: context,
      locationService: _locationService,
      isLocationSharingActive: () => buttonPressed['location'] ?? false,
      onStartLocationSharing: _locationService.startSharingLocation,
      onInitiateAutoCall: _autoCallService.initiateFakeAutoCallToPolice,
      isEmergencyButtonActive: () => buttonPressed['emergency'] ?? false,
      isAutoCallActive: () => buttonPressed['call'] ?? false, // Add this line
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadLockscreenStateInitial) {
      debugPrint("HomeScreen: didChangeDependencies - calling _loadLockscreenState()");
      _loadLockscreenState();
      _didLoadLockscreenStateInitial = true;
    }
  }

  void _handleVigorousShake() {
    if (mounted) {
      debugPrint("HomeScreen: Vigorous shake detected. Triggering emergency.");
      _emergencyService.handleEmergencyTrigger();
    }
  }

  Future<void> _loadLockscreenState() async {
    debugPrint("HomeScreen: _loadLockscreenState START");
    debugPrint("HomeScreen: _lockscreenService instance hash: ${_lockscreenService.hashCode}");

    bool initiallyEnabled = await _lockscreenService.isLockscreenAccessEnabled();
    debugPrint("HomeScreen: _loadLockscreenState - Value from isLockscreenAccessEnabled(): $initiallyEnabled");

    if (mounted) {
      setState(() {
        _isLockscreenAccessEnabled = initiallyEnabled;
        debugPrint("HomeScreen: _loadLockscreenState - setState completed. _isLockscreenAccessEnabled is now: $_isLockscreenAccessEnabled");
      });
    } else {
      debugPrint("HomeScreen: _loadLockscreenState - Component not mounted before setState. Aborting.");
      return; 
    }

    if (initiallyEnabled) {
      debugPrint("HomeScreen: Lockscreen determined to be ENABLED. Calling _lockscreenService.saveSwitchStateAndMedicalInfo(true) to refresh data and notification.");
      await _lockscreenService.saveSwitchStateAndMedicalInfo(true);
      debugPrint("HomeScreen: _loadLockscreenState - Call to _lockscreenService.saveSwitchStateAndMedicalInfo(true) COMPLETED.");
    } else {
      debugPrint("HomeScreen: Lockscreen determined to be DISABLED. Calling _lockscreenService.saveSwitchStateAndMedicalInfo(false) to ensure notification is cancelled.");
      await _lockscreenService.saveSwitchStateAndMedicalInfo(false);
      debugPrint("HomeScreen: _loadLockscreenState - Call to _lockscreenService.saveSwitchStateAndMedicalInfo(false) COMPLETED.");
    }
    debugPrint("HomeScreen: _loadLockscreenState END");
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
    _videoRecordingService.dispose();
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

  void _toggleButton(String buttonKey) async {
    if (buttonKey == 'emergency') {
      if (!_videoRecordingService.isReady.value) {
        debugPrint("HomeScreen: Emergency button pressed, but camera is not ready.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera not ready yet, please wait.')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final isAutoRecordingEnabled = prefs.getBool('auto_recording') ?? false;

      setState(() {
        buttonPressed[buttonKey] = !buttonPressed[buttonKey]!;
        bool isEmergencyActive = buttonPressed['emergency']!;
        buttonPressed['location'] = isEmergencyActive;
        if (isEmergencyActive) {
          debugPrint("HomeScreen: Emergency Mode ARMED. Location Sharing also ACTIVATED.");
          _locationService.startSharingLocation();
          if (isAutoRecordingEnabled) {
            _videoRecordingService.handleEmergencyTrigger();
          }
        } else {
          debugPrint("HomeScreen: Emergency Mode DISARMED. Location Sharing also DEACTIVATED.");
          _locationService.stopSharingLocation();
        }
      });
    } else {
      setState(() {
        buttonPressed[buttonKey] = !buttonPressed[buttonKey]!;
        if (buttonKey == 'location') {
          if (buttonPressed['location']!) {
            debugPrint("HomeScreen: Location Sharing ACTIVATED independently.");
            _locationService.startSharingLocation();
          } else {
            debugPrint("HomeScreen: Location Sharing DEACTIVATED independently.");
            _locationService.stopSharingLocation();
          }
        } else if (buttonKey == 'call') {
          // The logic for auto-call is handled in the EmergencyService,
          // so we don't need to do anything special here other than toggle the state.
        }
      });
    }
  }

  String _formatDateTimeLocal(DateTime dt) {
    return DateFormat.Hm().format(dt); // Simpler time format for display
  }

  @override
  Widget build(BuildContext context) {
    String lastFallDisplayStatus = _lastFallTime != null ? DateFormat.yMd().add_jm().format(_lastFallTime!) : "Never";

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
                    onTap: () async { 
                      await Navigator.pushNamed(
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
                      debugPrint("HomeScreen: ProfileScreen closed. Calling onProfileScreenClosed callback.");
                      widget.onProfileScreenClosed?.call();
                    },
                    child: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(30)), // 20% opacity white
                      child: const Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/smartwatch',
                            arguments: {
                              'heartRate': widget.currentHeartRate,
                              'connectionStatus': widget.currentHeartStatus,
                              'batteryLevel': widget.currentBatteryLevel,
                            },
                          );
                        },
                        child: Container(
                          width: 45, height: 45,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22.5)),
                          child: Image.asset('assets/images/watch.jpg', width: 24, height: 24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              PulseIcon(icon: Icons.favorite, pulseColor: Colors.white70, iconColor: Colors.redAccent, iconSize: 40, innerSize: 45, pulseSize: 116, pulseCount: 3),
              const SizedBox(height: 10),
              Text(widget.currentHeartRate > 0 ? '${widget.currentHeartRate} BpM' : '-- BpM', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Heart Rate - ${widget.currentHeartStatus}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
              if (widget.lastWatchUpdate != null) Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('Last Watch Update: ${_formatDateTimeLocal(widget.lastWatchUpdate!)}', style: const TextStyle(fontSize: 10, color: Colors.white60))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActivityIndicator(Icons.emergency_recording_rounded, "Automatic\nRecording", onTap: () => Navigator.pushNamed(context, '/recording-settings')),
                   if (_videoRecordingService.isRecording.value)
                    _buildActivityIndicator(Icons.videocam, "Recording..."),
                  if (!_videoRecordingService.isReady.value && !_videoRecordingService.isRecording.value)
                    _buildActivityIndicator(Icons.videocam_off, "Camera not ready"),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(children: [Expanded(child: _buildFeatureButton("Emergency Mode", "Tap panic to activate", Icons.warning_amber, 'emergency')), const SizedBox(width: 12), Expanded(child: _buildFeatureButton("AI Voice Recognition", "Always listen for distress", Icons.graphic_eq, 'voice'))]),
                      const SizedBox(height: 12),
                      Row(children: [Expanded(child: _buildFeatureButton("Auto Call", "If there is no response", Icons.phone_callback, 'call')), const SizedBox(width: 12), Expanded(child: _buildFeatureButton("Location Sharing", "Real-time GPS tracking", Icons.my_location, 'location'))]),
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

  Widget _buildActivityIndicator(IconData icon, String label, {VoidCallback? onTap}) {
    Widget content = Column(children: [Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(30)), child: Icon(icon, color: Colors.white, size: 28)), const SizedBox(height: 8), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12))]);
    return onTap != null ? GestureDetector(onTap: onTap, child: content) : content;
  }

  Widget _buildFeatureButton(String title, String subtitle, IconData icon, String buttonKey) {
    bool isPressed = buttonPressed[buttonKey] ?? false;
    bool isCameraReady = _videoRecordingService.isReady.value;
    // Disable the button if it's the emergency button and the camera isn't ready.
    bool isDisabled = buttonKey == 'emergency' && !isCameraReady;

    return GestureDetector(
      onTap: isDisabled ? null : () => _toggleButton(buttonKey),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: AnimatedContainer(duration: const Duration(milliseconds: 200), height: 80, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isPressed ? const Color(0xFFDD0000) : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: isPressed ? Colors.white : const Color(0xFFDD0000), size: 20), const Spacer(), if (isPressed) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))]), const SizedBox(height: 4), Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isPressed ? Colors.white : Colors.black)), Text(subtitle, style: TextStyle(fontSize: 10, color: isPressed ? Colors.white70 : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)]),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String status) {
    return Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]), child: Text('$title : $status', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)));
  }

  Widget _buildLockscreenCard() {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 350;
      return Container(width: double.infinity, padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 6 : 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Lockscreen Access', style: TextStyle(fontSize: isSmallScreen ? 13 : 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis), Text('Show medical information on lock screen', style: TextStyle(fontSize: isSmallScreen ? 10 : 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis)])), const SizedBox(width: 8), Switch(value: _isLockscreenAccessEnabled, onChanged: _saveLockscreenState, activeColor: const Color(0xFFDD0000), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)])
      );
    });
  }
}