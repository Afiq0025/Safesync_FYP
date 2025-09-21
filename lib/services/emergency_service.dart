import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback
import '../screens/fake_call_page.dart'; // Import for FakeCallPage

class EmergencyService {
  final BuildContext context;
  final ValueGetter<bool> isLocationSharingActive;
  final VoidCallback onStartLocationSharing;
  final VoidCallback onInitiateAutoCall;
  final ValueGetter<bool> isEmergencyButtonActive; // To check if the main emergency button is on

  EmergencyService({
    required this.context,
    required this.isLocationSharingActive,
    required this.onStartLocationSharing,
    required this.onInitiateAutoCall,
    required this.isEmergencyButtonActive,
  });

  Future<void> handleEmergencyTrigger() async {
    if (!isEmergencyButtonActive()) {
      debugPrint("EmergencyService: Triggered, but Emergency Mode feature is not active. No dialog shown.");
      return;
    }

    // Check if a dialog is already active to prevent stacking (simple check)
    // It's important to use a context that can find the Navigator.
    // If 'context' is from a widget deep in the tree, this check might be problematic.
    // Consider using a GlobalKey<NavigatorState> if issues arise.
    if (ModalRoute.of(context)?.isCurrent != true) {
      debugPrint("EmergencyService: Another route is current, potentially a dialog. Aborting.");
      return;
    }

    bool? confirmed;
    try {
      if (!Navigator.of(context).mounted) return; // Ensure context is valid

      HapticFeedback.heavyImpact(); // Vibration when dialog appears
      confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirm Emergency'),
            content: const Text('Are you sure you want to activate emergency mode? Respond within 10 seconds.'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  if (Navigator.of(dialogContext).canPop()) Navigator.of(dialogContext).pop(false);
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  if (Navigator.of(dialogContext).canPop()) Navigator.of(dialogContext).pop(true);
                },
              ),
            ],
          );
        },
      ).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      debugPrint("EmergencyService: Confirmation timed out.");
      // Ensure the dialog is dismissed before navigating.
      // Use rootNavigator: true if the dialog was shown with it, or if navigating from a context that isn't the primary navigator.
      if (Navigator.of(context).mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop(); 
      }
      
      // Navigate to FakeCallPage on timeout
      if (Navigator.of(context).mounted) { // Check again if context is still valid
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FakeCallPage()));
      }
      onInitiateAutoCall(); // Initiate auto call
      return;
    } catch (e) {
      debugPrint("EmergencyService: Error showing dialog: $e");
      return;
    }

    if (confirmed == true) {
      debugPrint("EmergencyService: Emergency sequence ACTIVATED!");
      // Navigate to FakeCallPage on "Yes"
      if (Navigator.of(context).mounted) { // Check if context is still valid
         Navigator.push(context, MaterialPageRoute(builder: (context) => const FakeCallPage()));
      }
      onInitiateAutoCall(); // Initiate auto call

      if (isLocationSharingActive()) {
        onStartLocationSharing();
      } else {
        debugPrint("EmergencyService: Location Sharing feature is not toggled on, so not starting it.");
      }
    } else if (confirmed == false) {
      debugPrint("EmergencyService: Emergency activation CANCELLED by user.");
    }
  }
}
