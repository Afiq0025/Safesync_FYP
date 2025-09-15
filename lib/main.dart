import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Added for DateFormat
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

  // Initialize flutter_local_notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Use your app icon
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
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Initialization error: $e');
    }
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
  String _name = "User Name";
  String _phoneNumber = "N/A";
  String _email = "N/A";
  String _address = "Address Default";
  String _bloodType = "Blood Type Default";
  String _allergies = "Allergies Default";
  String _medicalConditions = "Conditions Default";
  String _medications = "Medications Default";

  bool _didExtractArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didExtractArgs) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _name = args['name'] as String? ?? _name;
        _phoneNumber = args['phoneNumber'] as String? ?? _phoneNumber;
        _email = args['email'] as String? ?? _email;
        _address = args['address'] as String? ?? _address;
        _bloodType = args['bloodType'] as String? ?? _bloodType;
        _allergies = args['allergies'] as String? ?? _allergies;
        _medicalConditions =
            args['medicalConditions'] as String? ?? _medicalConditions;
        _medications = args['medications'] as String? ?? _medications;
      }
      _didExtractArgs = true;
    }
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
        setState(() {
          currentIndex = index;
        });
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
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isLockscreenAccessEnabled = false;
  int heartRate = 79;
  String heartStatus = "Normal";
  DateTime? _lastFallTime;

  Map<String, bool> buttonPressed = {
    'emergency': false,
    'voice': false,     // AI Voice Recognition - Placeholder
    'call': false,      // Auto Call - Placeholder
    'location': false,  // Location Sharing - Placeholder
  };

  // Services
  late FallDetectionService _fallDetectionService;
  late ShakeDetectionService _shakeDetectionService; // Declare ShakeDetectionService
  late EmergencyService _emergencyService;
  late LockscreenService _lockscreenService;
  late LocationService _locationService;
  late AutoCallService _autoCallService;

  @override
  void initState() {
    super.initState();
    // Initialize services
    _locationService = LocationService();
    _autoCallService = AutoCallService();

    _lockscreenService = LockscreenService(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin, // Pass the global instance
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
      // Corrected the setState call for _isLockscreenAccessEnabled
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
    _shakeDetectionService.dispose(); // Dispose ShakeDetectionService
    super.dispose();
  }

  void _updateLastFallDetected(DateTime fallTime) {
    if (mounted) {
      setState(() {
        _lastFallTime = fallTime;
      });
      debugPrint("HomeScreen: Fall detected at: $fallTime. UI should update.");
       // Potentially trigger emergency service if a fall is confirmed by other sensors/logic in future
      // For now, it just updates the UI.
    }
  }

  void _toggleButton(String buttonKey) {
    setState(() {
      buttonPressed[buttonKey] = !buttonPressed[buttonKey]!;
      if (buttonKey == 'emergency' && buttonPressed['emergency'] == true) {
        debugPrint("HomeScreen: Emergency Mode ARMED via button tap. Shake to activate.");
        // NOTE: No direct call to _emergencyService.handleEmergencyTrigger() here anymore.
        // Activation is now via shake when this button is true.
      } else if (buttonKey == 'emergency' && buttonPressed['emergency'] == false) {
        debugPrint("HomeScreen: Emergency Mode DISARMED via button tap.");
      }
    });
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
                          Navigator.pushNamed(context, '/smartwatch');
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
                '$heartRate BpM',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Heart Rate - $heartStatus',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _isLockscreenAccessEnabled,
                onChanged: _saveLockscreenState, // Updated to use the new method
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
