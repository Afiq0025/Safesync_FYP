import 'package:flutter/material.dart';

class PairSmartDevicesScreen extends StatefulWidget {
  const PairSmartDevicesScreen({Key? key}) : super(key: key);

  @override
  State<PairSmartDevicesScreen> createState() => _PairSmartDevicesScreenState();
}

class _PairSmartDevicesScreenState extends State<PairSmartDevicesScreen> {
  List<Device> pairedDevices = [
    Device(name: "Samsung Smart Ring", isPaired: true),
    Device(name: "Apple Smart watch", isPaired: true),
  ];

  List<Device> availableDevices = [
    Device(name: "Xiaomi Band 6", isPaired: false),
    Device(name: "AOLON Ring Gen3", isPaired: false),
    Device(name: "Samsung Galaxy Watch7", isPaired: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF36060),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF36060),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pair Smart Devices',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Paired Devices Section
                  const Text(
                    'Paired Devices',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Paired devices list
                  ...pairedDevices.map((device) => _buildDeviceCard(device, true)),

                  const SizedBox(height: 24),

                  // Divider line
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                  ),

                  const SizedBox(height: 24),

                  // Available Devices Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Devices',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Refresh available devices
                          setState(() {
                            // Simulate refresh
                          });
                        },
                        child: const Text(
                          'Refresh',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF007AFF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Available devices list
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: availableDevices.map((device) => _buildDeviceCard(device, false)).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Device device, bool isPaired) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              device.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          if (!isPaired)
            GestureDetector(
              onTap: () {
                _pairDevice(device);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Pair',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _pairDevice(Device device) {
    setState(() {
      // Remove from available devices
      availableDevices.remove(device);
      // Add to paired devices
      device.isPaired = true;
      pairedDevices.add(device);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${device.name} paired successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class Device {
  String name;
  bool isPaired;

  Device({required this.name, required this.isPaired});
}
