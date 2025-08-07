import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:safesync/screens/emergency/emergency_contacts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/smartwatch_detail.dart';
import 'screens/settings/recording_settings.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/home/pair_smart_devices.dart';
import 'screens/map/map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
        '/profile': (context) => const ProfileScreen(),
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
              width: 800,
              height: 800,
              child: Image.asset('assets/images/logo.png', width: 50, height: 50),
            ),
            const SizedBox(height: 1),
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

  // Define screens as a getter to ensure fresh instances
  List<Widget> get screens => [
    const HomeScreen(),
    const MapScreen(),
    const EmergencyContactsScreen(), // Temporary test widget
    const CommunityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Debug: Print what screen should be shown
    print('Building MainScreen with currentIndex: $currentIndex');
    print('Screen at index $currentIndex: ${screens[currentIndex].runtimeType}');

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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
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

        // Enhanced debug prints
        print('Navigating to index: $index');
        print('Current screen: ${screens[index].runtimeType}');
        if (index == 2) {
          print('Should show EmergencyContactsScreen');
          print('Actual screen type: ${screens[2].runtimeType}');
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isLockscreenAccess = false;
  int heartRate = 79;
  String heartStatus = "Normal";
  late AnimationController _pulseController;

  // Track pressed state for each button
  Map<String, bool> buttonPressed = {
    'emergency': false,
    'voice': false,
    'call': false,
    'location': false,
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleButton(String buttonKey) {
    setState(() {
      buttonPressed[buttonKey] = !buttonPressed[buttonKey]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF36060),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Top status bar with time and profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
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

              const SizedBox(height: 40),

              // Heart rate display with animated icon
              Lottie.asset(
                'assets/images/heartbeat.json',
                width: 100,
                height: 100,
                repeat: true,
                animate: true,
              ),

              const SizedBox(height: 10),

              // Heart rate text
              Text(
                '$heartRate BpM',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Heart Rate - $heartStatus',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 30),

              // Activity indicators
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

              const SizedBox(height: 50),

              // Feature cards (now as interactive buttons)
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
                              "Always listening for distress",
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

                      // Status cards
                      _buildStatusCard("Last Fall Detected", "Never"),
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
    Widget content = Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lockscreen Access',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Show medical information on lock screen',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Switch(
            value: isLockscreenAccess,
            onChanged: (value) {
              setState(() {
                isLockscreenAccess = value;
              });
            },
            activeColor: const Color(0xFFDD0000),
          ),
        ],
      ),
    );
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF36060),
      appBar: AppBar(
        title: const Text('Community', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF36060),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'Community Screen',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}