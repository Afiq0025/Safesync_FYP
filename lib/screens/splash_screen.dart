import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 350;
            final iconSize = isSmallScreen ? 48.0 : 60.0;
            final logoSize = isSmallScreen ? 80.0 : 120.0;
            final spacing = isSmallScreen ? 16.0 : 32.0;
            final fontSize = isSmallScreen ? 24.0 : 32.0;

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.security,
                          size: iconSize,
                          color: const Color(0xFFFF5A5A),
                        ),
                      ),
                      SizedBox(height: spacing),
                      Text(
                        'SafeSync',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF5A5A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
