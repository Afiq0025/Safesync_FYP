import 'package:flutter/material.dart';

class SmartwatchDetailScreen extends StatelessWidget {
  const SmartwatchDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final heartRate = args?['heartRate'] as int? ?? 0;
    final connectionStatus = args?['connectionStatus'] as String? ?? 'Not Connected';
    final batteryLevel = args?['batteryLevel'] as int? ?? 0;

    final isConnected = connectionStatus == 'Watch Connected' && heartRate > 0;
    final statusText = isConnected
        ? 'Current Heart Rate: $heartRate BpM\nBattery Level: $batteryLevel %\nConnection Status: Connected'
        : 'Connection Status: Not Connected';


    return Scaffold(
      backgroundColor: const Color(0xFFF36A6A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.03),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                const Center(
                  child: Text(
                    'Samsung Galaxy Watch 4',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Serif',
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.10),
                Center(
                  child: Image.asset(
                    'assets/images/watch.jpg',
                    width: screenWidth * 0.55,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Text(
                  statusText,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'Serif',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
